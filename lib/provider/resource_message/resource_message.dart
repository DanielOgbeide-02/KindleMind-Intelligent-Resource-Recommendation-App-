import '../resource_model/resource_model.dart';

class ResourceMessage {
  final String id;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final String toUsername;
  final ResourceModel resource;
  final DateTime timestamp;
  final bool isRead;

  ResourceMessage({
    required this.id,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.toUsername,
    required this.resource,
    required this.timestamp,
    this.isRead = false,
  });

  factory ResourceMessage.fromMap(Map<String, dynamic> data) {
    return ResourceMessage(
      id: data['id'],
      fromUserId: data['fromUserId'],
      fromUsername: data['fromUsername'],
      toUserId: data['toUserId'],
      toUsername: data['toUsername'],
      resource: ResourceModel.fromMap(data['resource']),
      timestamp: DateTime.parse(data['timestamp']),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'toUserId': toUserId,
      'toUsername': toUsername,
      'resource': resource.toMap(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  ResourceMessage copyWith({
    bool? isRead,
  }) {
    return ResourceMessage(
      id: id,
      fromUserId: fromUserId,
      fromUsername: fromUsername,
      toUserId: toUserId,
      toUsername: toUsername,
      resource: resource,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}

// Model to represent a conversation between two users
class ResourceConversation {
  final String conversationId;
  final String otherUserId;
  final String otherUsername;
  final List<ResourceMessage> messages;
  final DateTime lastMessageTime;
  final int unreadCount;

  ResourceConversation({
    required this.conversationId,
    required this.otherUserId,
    required this.otherUsername,
    required this.messages,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  // Generate conversation ID from two user IDs (consistent ordering)
  static String generateConversationId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  factory ResourceConversation.fromMessages(
      String currentUserId,
      String otherUserId,
      String otherUsername,
      List<ResourceMessage> messages,
      ) {
    // Sort messages by timestamp
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Count unread messages (messages sent to current user that are unread)
    final unreadCount = messages
        .where((msg) => msg.toUserId == currentUserId && !msg.isRead)
        .length;

    return ResourceConversation(
      conversationId: generateConversationId(currentUserId, otherUserId),
      otherUserId: otherUserId,
      otherUsername: otherUsername,
      messages: messages,
      lastMessageTime: messages.isNotEmpty
          ? messages.last.timestamp
          : DateTime.now(),
      unreadCount: unreadCount,
    );
  }
}