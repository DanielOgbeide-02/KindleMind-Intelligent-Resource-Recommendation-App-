import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recommender_nk/provider/resource_model/resource_model.dart';
import 'package:recommender_nk/provider/resource_model/resource_notifier.dart';
import 'package:recommender_nk/provider/resource_model/user_notifier_provider.dart';
import 'package:recommender_nk/provider/user_provider.dart';

import '../data/repositories/firebase_auth_repository.dart';

class AuthController extends StateNotifier<User?> {
  final FirebaseAuthRepository _authRepository;
  final Ref ref;

  AuthController(this._authRepository, this.ref) : super(null) {
    _authRepository.authStateChanges.listen((user) {
      state = user;
    });
  }
  Future<String?> signUp(
      String email,
      String password,
      String name,
      String username,
      List<ResourceModel> savedResources,
      List<ResourceModel> likedResources,
      List<ResourceModel> dislikedResources,
      List<ResourceModel> sharedResources
      ) async {
    try {
      User? user = await _authRepository.signUp(
        email: email,
        password: password,
        name: name,
        username: username,
        savedResources: savedResources,
        likedResources: likedResources,
        dislikedResources: dislikedResources,
        sharedResources: sharedResources,
      );

      state = user;
      if (user != null) {
        // Create UserModel with the signup data and set it locally
        final newUser = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          username: username,
          savedResources: savedResources,
          likedResources: likedResources,
          dislikedResources: dislikedResources,
          sharedResources: sharedResources,
          dailyStreaks: 1, // Initialize with 1 since signup counts as first streak
          // Preferences will be null initially, set later in preferences page
          age: null,
          gender: null,
          recoveryStage: null,
          preferredResourceTypes: [],
        );

        // Update local user state
        ref.read(userNotifierProvider.notifier).updateUser(newUser);
        // Update local resources state with saved resources
        if (savedResources.isNotEmpty) {
          ref.read(resourcesNotifierProvider.notifier).state = savedResources;
        }
      }

      return null;
    } on FirebaseAuthException catch (e) {
      return _getFriendlyErrorMessage(e);
    } on Exception catch (e) {
      return cleanFirebaseErrorMessage(e.toString());
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      User? user = await _authRepository.signIn(email, password);
      state = user;

      if (user != null) {
        // Fetch and set user profile data
        final userDetails = await getUserDetails();
        if (userDetails != null) {
          ref.read(userNotifierProvider.notifier).updateUser(userDetails);
        }

        // Fetch and set user resources
        final resourceResult = await ref.read(resourcesNotifierProvider.notifier)
            .fetchUserResources(user.uid);

        if (resourceResult != 'Success') {
          print('Warning: Failed to fetch user resources: $resourceResult');
        }

        return 'success';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _getFriendlyErrorMessage(e);
    } on Exception catch (e) {
      return cleanFirebaseErrorMessage(e.toString());
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  Future<String?> updateUserProfile({
    required String name,
    required String email,
    required String username,
    required List<ResourceModel> savedResources,
    required List<ResourceModel> likedResources,
    required List<ResourceModel> dislikedResources,
    required List<ResourceModel> sharedResources,
    String? age,
    String? gender,
    String? recoveryStage,
    List<String>? preferredResourceTypes,
    int? dailyStreaks, // Add dailyStreaks parameter
  }) async {
    try {
      if (state == null) return "No user signed in";

      final uid = state!.uid;
      final currentUser = await getUserDetails();
      if (currentUser == null) return "User not found";

      await _authRepository.updateUserProfile(
        uid: uid,
        name: name,
        email: email,
        username: username,
        savedResources: savedResources,
        likedResources: likedResources,
        dislikedResources: dislikedResources,
        sharedResources: sharedResources,
        age: age,
        gender: gender,
        recoveryStage: recoveryStage,
        preferredResourceTypes: preferredResourceTypes,
        dailyStreaks: dailyStreaks, // Pass dailyStreaks to repository
      );

      final updatedUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        username: username,
        savedResources: currentUser.savedResources,
        likedResources: currentUser.likedResources,
        dislikedResources: currentUser.dislikedResources,
        sharedResources: currentUser.sharedResources,
        dailyStreaks: dailyStreaks ?? currentUser.dailyStreaks, // Include dailyStreaks
        age: age ?? currentUser.age,
        gender: gender ?? currentUser.gender,
        recoveryStage: recoveryStage ?? currentUser.recoveryStage,
        preferredResourceTypes: preferredResourceTypes ?? currentUser.preferredResourceTypes,
      );

      ref.read(userNotifierProvider.notifier).updateUser(updatedUser);
      return null;
    } catch (e) {
      return "Error updating profile: ${e.toString()}";
    }
  }

  Future<UserModel?> getUserDetails() async {
    if (state == null) return null;
    final userData = await _authRepository.getUserDetails(state!.uid);
    print('the current user id: ${state!.uid}');
    if (userData.exists) {
      final data = userData.data()!;
      final filteredData = {
        'uid': data['uid'],
        'username': data['username'],
        'name': data['name'],
        'email': data['email'],
        'savedResources': data['savedResources'], // Fixed field name
        'likedResources': data['likedResources'], // Fixed field name
        'dislikedResources': data['dislikedResources'], // Fixed field name
        'sharedResources': data['sharedResources'], // Fixed field name
        'dailyStreaks': data['dailyStreaks'], // Add dailyStreaks
        'age': data['age'],
        'gender': data['gender'],
        'recoveryStage': data['recoveryStage'],
        'preferredResourceTypes': data['preferredResourceTypes'],
      };
      return UserModel.fromMap(filteredData);
    }
    print('state is null');
    return null;
  }

  Future<String?> updateEmail(String newEmail, String password) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return "No user signed in";

    final reauthResult =
    await _authRepository.reauthenticateUser(user.email!, password);
    if (reauthResult != "Reauthentication successful!") {
      return reauthResult;
    }

    final verificationResult =
    await _authRepository.verifyBeforeUpdateEmail(newEmail);
    if (!verificationResult['status']) {
      return verificationResult['message'];
    }

    return 'success';
  }

  Future<String> logout() async {
    try {
      await _authRepository.signOut();
      ref.read(userNotifierProvider.notifier).clearUser();
      return 'success';
    } catch (e) {
      return 'Logout failed: ${e.toString()}';
    }
  }

  Future<String> changePassword(String email) async {
    return await _authRepository.updatePassword(email);
  }

  String cleanFirebaseErrorMessage(String errorMessage) {
    if (errorMessage.startsWith("Exception: [firebase_auth/")) {
      int closingBracketPos = errorMessage.indexOf(']');
      if (closingBracketPos != -1) {
        return errorMessage.substring(closingBracketPos + 1).trim();
      }
    }
    return errorMessage;
  }

  String _getFriendlyErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return "The email address is invalid. Please enter a valid email.";
      case 'email-already-in-use':
        return "This email is already in use. Try signing in instead.";
      case 'weak-password':
        return "Your password is too weak. Try using a stronger one.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'user-not-found':
        return "No user found with this email. Please check and try again.";
      case 'user-disabled':
        return "This account has been disabled. Contact support.";
      case 'invalid-credential':
        return "The password is incorrect. Please enter a correct password.";
      default:
        return "An error occurred. Please try again.";
    }
  }
}

// AuthController Provider
final authControllerProvider = StateNotifierProvider<AuthController, User?>(
      (ref) => AuthController(ref.read(firebaseAuthRepositoryProvider),ref),
);

// Provider to get all users
final allUsersProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final authRepository = FirebaseAuthRepository();
  return await authRepository.getAllUsers();
});

// Provider to get users except current user
final usersExceptCurrentProvider = FutureProvider.family<List<Map<String, String>>, String>((ref, currentUserId) async {
  final authRepository = FirebaseAuthRepository();
  return await authRepository.getAllUsersExcept(currentUserId);
});

// FirebaseAuthRepository Provider
final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>(
      (ref) => FirebaseAuthRepository(),
);