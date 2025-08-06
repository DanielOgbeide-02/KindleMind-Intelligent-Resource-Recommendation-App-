import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../../core/config.dart';
import '../../provider/resource_message/resource_message.dart';
import '../../provider/resource_model/resource_model.dart';
import '../../provider/user_provider.dart';

class FirebaseAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String flaskApiUrl = Config.apiUrl;

  // Stream to listen for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
    required String username,
    required List<ResourceModel> savedResources,
    required List<ResourceModel> likedResources,
    required List<ResourceModel> dislikedResources,
    required List<ResourceModel> sharedResources,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'username': username,
          'email': email,
          'savedResources': savedResources.map((resource) => resource.toMap()).toList(),
          'likedResources': likedResources.map((resource) => resource.toMap()).toList(),
          'dislikedResources': dislikedResources.map((resource) => resource.toMap()).toList(),
          'sharedResources': sharedResources.map((resource) => resource.toMap()).toList(),
          'dailyStreaks': 1, // Start with 1 since signing up counts as first day
        });
      }
      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Sign In with streak logic
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Update streak - increment by 1 each time user signs in
        await _updateDailyStreak(user.uid);
      }

      return user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Get a single user by UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!); // assumes fromMap exists
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }

  // Update daily streak logic - simple increment
  Future<void> _updateDailyStreak(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      int currentStreak = userData['dailyStreaks'] ?? 0;

      // Increment streak by 1 for each sign in
      currentStreak += 1;

      // Update the user document
      await _firestore.collection('users').doc(uid).update({
        'dailyStreaks': currentStreak,
      });

    } catch (e) {
      print('Error updating daily streak: $e');
    }
  }

  // Get User Details (includes streak)
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // Update User Profile (includes streak)
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String username,
    required String email,
    required List<ResourceModel> savedResources,
    required List<ResourceModel> likedResources,
    required List<ResourceModel> dislikedResources,
    required List<ResourceModel> sharedResources,
    String? age,
    String? gender,
    String? recoveryStage,
    List<String>? preferredResourceTypes,
    int? dailyStreaks, // Allow manual streak update if needed
  }) async {
    try {
      // Prepare the update data
      Map<String, dynamic> updateData = {
        'name': name,
        'email': email,
        'username': username,
        'savedResources': savedResources.map((resource) => resource.toMap()).toList(),
        'likedResources': likedResources.map((resource) => resource.toMap()).toList(),
        'dislikedResources': dislikedResources.map((resource) => resource.toMap()).toList(),
        'sharedResources': sharedResources.map((resource) => resource.toMap()).toList(),
      };

      // Add preference fields if they are provided
      if (age != null) {
        updateData['age'] = age;
      }
      if (gender != null) {
        updateData['gender'] = gender;
      }
      if (recoveryStage != null) {
        updateData['recoveryStage'] = recoveryStage;
      }
      if (preferredResourceTypes != null) {
        updateData['preferredResourceTypes'] = preferredResourceTypes;
      }
      if (dailyStreaks != null) {
        updateData['dailyStreaks'] = dailyStreaks;
      }

      await _firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

  // Get current streak for a user
  Future<int> getCurrentStreak(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data()?['dailyStreaks'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting current streak: $e');
      return 0;
    }
  }

  // Reset streak manually (if needed for testing or admin purposes)
  Future<void> resetStreak(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'dailyStreaks': 0,
        'lastLoginDate': null,
      });
    } catch (e) {
      throw Exception('Error resetting streak: $e');
    }
  }

// Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> reauthenticateUser(String email, String password) async {
    // Get the currently signed-in user
    User? user = FirebaseAuth.instance.currentUser;
    if(user == null){
      try{
        UserCredential result = (await signIn(email, password)) as UserCredential;
        if (result.user == null) {
          print('Incorrect password');
          return 'Incorrect Password';
        } else {
          print('User signed in successfully.');
          return 'User signed in successfully.';
        }
      } catch (e) {
        print('Error during sign in: $e');
        return 'Error during sign in: $e';
      }
    } else {
      // Create an AuthCredential using the provided email and password
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      try {
        // Reauthenticate the user
        await user.reauthenticateWithCredential(credential);
        // Success: Reauthentication completed
        print('Reauthentication successful!');
        return 'Reauthentication successful!';
      } on FirebaseAuthException catch (e) {
        // Handle errors such as invalid credentials or reauthentication failure
        print('Error during reauthentication: ${e.message}');
        return 'Error during reauthentication: ${e.message}';
      } catch (e) {
        // Handle any other errors
        print('Unknown error: $e');
        return 'Unknown error: $e';
      }
    }
  }


  Future<Map<String, dynamic>> verifyBeforeUpdateEmail(String newEmail) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await user.verifyBeforeUpdateEmail(newEmail);
        print("Verification email sent to $newEmail");
        return {'status': true, 'message': 'Verification email sent successfully'};
      } on FirebaseAuthException catch (e) {
        // Handle errors, such as invalid email or requires recent login
        print("Error: ${e.message}");
        return {'status': false, 'message': e.message};
      }
    } else {
      print("No user is signed in.");
      return {'status': false, 'message': 'No user is signed in'};
    }
  }

  // Update password
  Future<String> updatePassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'success';
    } on FirebaseAuthException catch (e) {
      print('Unable to send email, reason: ${e.message}');
      return 'Password reset failed: ${e.message}';
    } catch (e) {
      print('Unknown error: $e');
      return 'An unexpected error occurred: $e';
    }
  }

  // 🔹 Fetch saved resources for a user
  Future<List<ResourceModel>> fetchUserResources(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('resources')
        .get();

    return snapshot.docs.map((doc) => ResourceModel.fromMap(doc.data())).toList();
  }

  // 🔹 Add a resource to a user's collection
  Future<ResourceModel> saveUserResource(String userId, ResourceModel resource) async {
    final resourceRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('saved resources')
        .doc(resource.quote); // Assuming quote is unique, or use a UUID if needed

    final data = resource.toMap();

    await resourceRef.set(data);
    return resource;
  }

  // Add these methods to your Firebase Auth Repository class

// ✅ Like a resource
  Future<ResourceModel> likeUserResource(String userId, ResourceModel resource) async {
    final resourceRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('liked resources')
        .doc(resource.quote); // Assuming quote is unique, or use a UUID if needed
    final data = resource.toMap();
    await resourceRef.set(data);
    return resource;
  }

// ✅ Dislike a resource
  Future<ResourceModel> dislikeUserResource(String userId, ResourceModel resource) async {
    final resourceRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('disliked resources')
        .doc(resource.quote); // Assuming quote is unique, or use a UUID if needed
    final data = resource.toMap();
    await resourceRef.set(data);
    return resource;
  }

// ✅ Share a resource to another user
  Future<ResourceModel> shareResourceToUser(String fromUserId, String toUserId, ResourceModel resource) async {
    // Add to sender's shared resources
    final sharedResourceRef = _firestore
        .collection('users')
        .doc(fromUserId)
        .collection('shared resources')
        .doc('${resource.quote}_${toUserId}'); // Unique identifier with recipient

    final sharedData = {
      ...resource.toMap(),
      'sharedTo': toUserId,
      'sharedAt': FieldValue.serverTimestamp(),
    };
    await sharedResourceRef.set(sharedData);

    // Add to recipient's received resources
    final receivedResourceRef = _firestore
        .collection('users')
        .doc(toUserId)
        .collection('received resources')
        .doc('${resource.quote}_${fromUserId}'); // Unique identifier with sender

    final receivedData = {
      ...resource.toMap(),
      'sharedFrom': fromUserId,
      'receivedAt': FieldValue.serverTimestamp(),
    };
    await receivedResourceRef.set(receivedData);

    return resource;
  }

// ✅ Get user's saved resources
  Future<List<ResourceModel>> getUserSavedResources(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved resources')
        .get();

    return snapshot.docs.map((doc) => ResourceModel.fromMap(doc.data())).toList();
  }

// ✅ Get user's liked resources
  Future<List<ResourceModel>> getUserLikedResources(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('liked resources')
        .get();

    return snapshot.docs.map((doc) => ResourceModel.fromMap(doc.data())).toList();
  }

// ✅ Get user's disliked resources
  Future<List<ResourceModel>> getUserDislikedResources(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('disliked resources')
        .get();

    return snapshot.docs.map((doc) => ResourceModel.fromMap(doc.data())).toList();
  }

// ✅ Get user's shared resources
  Future<List<Map<String, dynamic>>> getUserSharedResources(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('shared resources')
        .orderBy('sharedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

// ✅ Get user's received resources
  Future<List<Map<String, dynamic>>> getUserReceivedResources(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('received resources')
        .orderBy('receivedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

// ✅ Remove a saved resource
  Future<void> removeSavedResource(String userId, String resourceQuote) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved resources')
        .doc(resourceQuote)
        .delete();
  }

// ✅ Remove a liked resource
  Future<void> removeLikedResource(String userId, String resourceQuote) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('liked resources')
        .doc(resourceQuote)
        .delete();
  }

// ✅ Remove a disliked resource
  Future<void> removeDislikedResource(String userId, String resourceQuote) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('disliked resources')
        .doc(resourceQuote)
        .delete();
  }

// ✅ Check if resource is saved by user
  Future<bool> isResourceSaved(String userId, String resourceQuote) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('saved resources')
        .doc(resourceQuote)
        .get();

    return doc.exists;
  }

// ✅ Check if resource is liked by user
  Future<bool> isResourceLiked(String userId, String resourceQuote) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('liked resources')
        .doc(resourceQuote)
        .get();

    return doc.exists;
  }

// ✅ Check if resource is disliked by user
  Future<bool> isResourceDisliked(String userId, String resourceQuote) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('disliked resources')
        .doc(resourceQuote)
        .get();

    return doc.exists;
  }

  // 🔹 Update an existing resource
  Future<void> updateUserResource(String userId, ResourceModel resource) async {
    final resourceRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('resources')
        .doc(resource.quote); // Again, assuming quote is a unique ID

    await resourceRef.update(resource.toMap());
  }

  // Add these methods to your existing FirebaseAuthRepository class

// Send a resource message
  Future<void> sendResourceMessage(ResourceMessage message) async {
    await _firestore
        .collection('resource_messages')
        .doc(message.id)
        .set(message.toMap());
  }

// Fetch all messages for a user (both sent and received)
  Future<List<ResourceMessage>> fetchUserMessages(String userId) async {
    try {
      // Get messages where user is sender or receiver
      final sentQuery = await _firestore
          .collection('resource_messages')
          .where('fromUserId', isEqualTo: userId)
          .get();

      final receivedQuery = await _firestore
          .collection('resource_messages')
          .where('toUserId', isEqualTo: userId)
          .get();

      final List<ResourceMessage> messages = [];

      // Add sent messages
      for (var doc in sentQuery.docs) {
        messages.add(ResourceMessage.fromMap(doc.data()));
      }

      // Add received messages
      for (var doc in receivedQuery.docs) {
        messages.add(ResourceMessage.fromMap(doc.data()));
      }

      // Remove duplicates and sort by timestamp
      final uniqueMessages = messages.toSet().toList();
      uniqueMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return uniqueMessages;
    } catch (e) {
      throw Exception('Failed to fetch user messages: $e');
    }
  }

// Mark messages as read
  Future<void> markMessagesAsRead(String currentUserId, String otherUserId) async {
    try {
      final query = await _firestore
          .collection('resource_messages')
          .where('fromUserId', isEqualTo: otherUserId)
          .where('toUserId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();

      for (var doc in query.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
  }

// Get conversation messages between two users
  Future<List<ResourceMessage>> getConversationMessages(
      String userId1,
      String userId2,
      ) async {
    try {
      final query1 = await _firestore
          .collection('resource_messages')
          .where('fromUserId', isEqualTo: userId1)
          .where('toUserId', isEqualTo: userId2)
          .get();

      final query2 = await _firestore
          .collection('resource_messages')
          .where('fromUserId', isEqualTo: userId2)
          .where('toUserId', isEqualTo: userId1)
          .get();

      final List<ResourceMessage> messages = [];

      for (var doc in query1.docs) {
        messages.add(ResourceMessage.fromMap(doc.data()));
      }

      for (var doc in query2.docs) {
        messages.add(ResourceMessage.fromMap(doc.data()));
      }

      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    } catch (e) {
      throw Exception('Failed to get conversation messages: $e');
    }
  }



// Get all users for sharing (you might want to limit this or add pagination)
  Future<List<Map<String, String>>> getAllUsers() async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users') // Assuming you have a 'users' collection
          .get();

      final List<Map<String, String>> users = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        users.add({
          'id': doc.id, // Document ID as user ID
          'username': data['username'] ?? data['displayName'] ?? 'Unknown', // Adjust field name based on your Firestore structure
          'name': data['name'] ?? data['displayName'] ?? 'Unknown',
        });
      }

      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Alternative method if you want to exclude current user
  Future<List<Map<String, String>>> getAllUsersExcept(String currentUserId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .get();

      final List<Map<String, String>> users = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        users.add({
          'id': doc.id,
          'username': data['username'] ?? data['displayName'] ?? 'Unknown',
          'name': data['name'] ?? data['displayName'] ?? 'Unknown',
        });
      }

      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
}
