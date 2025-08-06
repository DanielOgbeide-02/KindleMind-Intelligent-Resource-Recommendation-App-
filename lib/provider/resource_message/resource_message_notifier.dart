import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recommender_nk/provider/resource_message/resource_message.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../resource_model/resource_model.dart';

class ResourceMessageNotifier extends StateNotifier<List<ResourceMessage>> {
  final FirebaseAuthRepository _authRepository;

  ResourceMessageNotifier(this._authRepository) : super([]);

  // Send a resource to another user
  Future<String> sendResourceToUser({
    required String fromUserId,
    required String fromUsername,
    required String toUserId,
    required String toUsername,
    required ResourceModel resource,
  }) async {
    try {
      final message = ResourceMessage(
        id: Uuid().v4(),
        fromUserId: fromUserId,
        fromUsername: fromUsername,
        toUserId: toUserId,
        toUsername: toUsername,
        resource: resource,
        timestamp: DateTime.now(),
      );

      // Save to Firebase (you'll need to implement this in your repository)
      await _authRepository.sendResourceMessage(message);

      // Update local state
      state = [...state, message];

      return 'Resource sent successfully';
    } catch (e) {
      return 'Failed to send resource: ${e.toString()}';
    }
  }

  // Fetch all messages for a user (both sent and received)
  Future<String> fetchUserMessages(String userId) async {
    try {
      final messages = await _authRepository.fetchUserMessages(userId);
      state = messages;
      return 'Success';
    } catch (e) {
      return 'Failed to fetch messages: ${e.toString()}';
    }
  }

  // Get conversation between current user and another user
  ResourceConversation? getConversationWith(
      String currentUserId,
      String otherUserId,
      String otherUsername,
      ) {
    final conversationMessages = state.where((message) =>
    (message.fromUserId == currentUserId && message.toUserId == otherUserId) ||
        (message.fromUserId == otherUserId && message.toUserId == currentUserId)
    ).toList();

    if (conversationMessages.isEmpty) return null;

    return ResourceConversation.fromMessages(
      currentUserId,
      otherUserId,
      otherUsername,
      conversationMessages,
    );
  }

  // Get all conversations for a user
  List<ResourceConversation> getAllConversations(String currentUserId) {
    // Group messages by conversation partners
    final Map<String, List<ResourceMessage>> conversationGroups = {};
    final Map<String, String> usernames = {}; // Cache usernames

    for (final message in state) {
      String otherUserId;
      String otherUsername;

      if (message.fromUserId == currentUserId) {
        otherUserId = message.toUserId;
        otherUsername = message.toUsername;
      } else if (message.toUserId == currentUserId) {
        otherUserId = message.fromUserId;
        otherUsername = message.fromUsername;
      } else {
        continue; // Skip messages not involving current user
      }

      usernames[otherUserId] = otherUsername;
      conversationGroups.putIfAbsent(otherUserId, () => []);
      conversationGroups[otherUserId]!.add(message);
    }

    // Convert to conversations and sort by last message time
    final conversations = conversationGroups.entries
        .map((entry) => ResourceConversation.fromMessages(
      currentUserId,
      entry.key,
      usernames[entry.key]!,
      entry.value,
    ))
        .toList();

    conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return conversations;
  }

  // Mark messages as read
  Future<String> markMessagesAsRead(
      String currentUserId,
      String otherUserId,
      ) async {
    try {
      await _authRepository.markMessagesAsRead(currentUserId, otherUserId);

      // Update local state
      state = state.map((message) {
        if (message.fromUserId == otherUserId &&
            message.toUserId == currentUserId &&
            !message.isRead) {
          return message.copyWith(isRead: true);
        }
        return message;
      }).toList();

      return 'Messages marked as read';
    } catch (e) {
      return 'Failed to mark messages as read: ${e.toString()}';
    }
  }

  // Get unread message count
  int getUnreadCount(String currentUserId) {
    return state
        .where((message) =>
    message.toUserId == currentUserId && !message.isRead)
        .length;
  }

  bool hasUnreadMessagesFrom(String currentUserId, String otherUserId) {
    return state.any((message) =>
    message.fromUserId == otherUserId &&
        message.toUserId == currentUserId &&
        !message.isRead);
  }


  // Clear messages on logout
  void clearMessages() {
    state = [];
  }
}

// Provider
final resourceMessageNotifierProvider =
StateNotifierProvider<ResourceMessageNotifier, List<ResourceMessage>>((ref) {
  return ResourceMessageNotifier(FirebaseAuthRepository());
});