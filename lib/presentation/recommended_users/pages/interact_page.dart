import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../provider/resource_message/resource_message_notifier.dart';
import '../../home/pages/each_content_screen.dart';
import 'package:go_router/go_router.dart';

class ConversationPage extends ConsumerStatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final String otherUsername;

  const ConversationPage({
    Key? key,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUsername,
  }) : super(key: key);

  @override
  ConsumerState<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends ConsumerState<ConversationPage> {
  @override
  void initState() {
    super.initState();
    // Mark messages as read when entering conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(resourceMessageNotifierProvider.notifier)
          .markMessagesAsRead(widget.currentUserId, widget.otherUserId);
    });
  }

  void _navigateToResourceDetail(dynamic resource) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EachContentScreen(
          author: resource.author,
          quote: resource.quote,
          articleType: resource.articleType,
          title: null, // Add title if available in your resource model
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageNotifier = ref.watch(resourceMessageNotifierProvider.notifier);
    final conversation = messageNotifier.getConversationWith(
      widget.currentUserId,
      widget.otherUserId,
      widget.otherUsername,
    );

    if (conversation == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.otherUsername), leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),),        body: const Center(child: Text('No messages yet')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.otherUsername), leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: conversation.messages.length,
        itemBuilder: (context, index) {
          final message = conversation.messages[index];
          final isFromCurrentUser = message.fromUserId == widget.currentUserId;

          return Align(
            alignment: isFromCurrentUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isFromCurrentUser
                    ? Colors.blue[100]
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clickable Resource content
                  GestureDetector(
                    onTap: () => _navigateToResourceDetail(message.resource),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                        // Add subtle shadow to indicate it's clickable
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  message.resource.quote,
                                  style: const TextStyle(fontStyle: FontStyle.italic),
                                ),
                              ),
                              // Add a small arrow icon to indicate it's clickable
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '- ${message.resource.author}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (message.resource.articleType.isNotEmpty)
                            Text(
                              message.resource.articleType,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}