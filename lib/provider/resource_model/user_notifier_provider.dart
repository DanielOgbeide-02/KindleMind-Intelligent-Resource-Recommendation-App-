import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../user_provider.dart';
// Import your UserModel

class UserNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
    return null; // Initially, no user is set
  }

  // Method to update user details
  void updateUser(UserModel user) {
    state = user;
  }

  // Method to clear user (e.g., logout)
  void clearUser() {
    state = null;
  }
}

// Notifier Provider
final userNotifierProvider = NotifierProvider<UserNotifier, UserModel?>(() {
  return UserNotifier();
});
