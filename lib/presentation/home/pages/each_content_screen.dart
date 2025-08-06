import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../provider/resource_message/resource_message_notifier.dart';
import '../../../provider/resource_model/user_notifier_provider.dart';
import '../../../provider/resource_model/resource_model.dart';
import '../../../provider/resource_model/resource_notifier.dart';
import '../../recommended_users/widgets/user_selection.dart';
import '../widgets/quote_card.dart';

class EachContentScreen extends ConsumerStatefulWidget {
  const EachContentScreen({
    super.key,
    required this.author,
    required this.quote,
    this.articleType,
    this.title
  });

  final String? author;
  final String? quote;
  final String? articleType;
  final String? title;

  @override
  ConsumerState<EachContentScreen> createState() => _EachContentScreenState();
}

class _EachContentScreenState extends ConsumerState<EachContentScreen> {
  bool isLiked = false;
  bool isDisliked = false;
  bool isSaved = false;
  bool isLoading = false;
  bool isInitializing = true;

  @override
  void initState() {
    super.initState();
    _loadResourceStatus();
  }

  Future<void> _loadResourceStatus() async {
    final user = ref.read(userNotifierProvider);
    if (user != null && widget.quote != null) {
      final status = await ref.read(resourcesNotifierProvider.notifier)
          .getResourceStatus(user.uid, widget.quote!);

      if (mounted) {
        setState(() {
          isLiked = status['isLiked'] ?? false;
          isDisliked = status['isDisliked'] ?? false;
          isSaved = status['isSaved'] ?? false;
          isInitializing = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          isInitializing = false;
        });
      }
    }
  }

  ResourceModel _createResourceModel() {
    return ResourceModel(
      quote: widget.quote ?? '',
      author: widget.author ?? '',
      articleType: widget.articleType ?? '',
      isLiked: isLiked,
      isDisliked: isDisliked,
      isSaved: isSaved,
      isShared: false,
    );
  }

  Future<void> _executeAction(Future<String> Function() action, String successMessage) async {
    setState(() => isLoading = true);

    try {
      final result = await action();
      if (mounted) {
        if (result.contains('successfully') || result == 'Success') {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(successMessage), backgroundColor: Colors.green)
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result), backgroundColor: Colors.red)
          );
        }
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleLike() async {
    final user = ref.read(userNotifierProvider);
    if (user == null || widget.quote == null) return;

    await _executeAction(() async {
      final result = await ref.read(resourcesNotifierProvider.notifier)
          .toggleLikeResource(user.uid, _createResourceModel());

      if (result.contains('successfully')) {
        setState(() {
          isLiked = !isLiked;
          if (isLiked) isDisliked = false;
        });
      }
      return result;
    }, isLiked ? 'Unliked!' : 'Liked!');
  }

  Future<void> _handleDislike() async {
    final user = ref.read(userNotifierProvider);
    if (user == null || widget.quote == null) return;

    await _executeAction(() async {
      final result = await ref.read(resourcesNotifierProvider.notifier)
          .toggleDislikeResource(user.uid, _createResourceModel());

      if (result.contains('successfully')) {
        setState(() {
          isDisliked = !isDisliked;
          if (isDisliked) isLiked = false;
        });
      }
      return result;
    }, isDisliked ? 'Dislike removed!' : 'Disliked!');
  }

  Future<void> _handleSave() async {
    final user = ref.read(userNotifierProvider);
    if (user == null || widget.quote == null) return;

    final currentSavedState = isSaved;
    setState(() => isLoading = true);

    try {
      final result = await ref.read(resourcesNotifierProvider.notifier)
          .toggleSaveResource(user.uid, _createResourceModel());

      if (mounted) {
        if (result.contains('successfully')) {
          setState(() {
            isSaved = !currentSavedState;
            isLoading = false;
          });

          final message = isSaved ? 'Saved!' : 'Removed from saved!';
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.green)
          );
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result), backgroundColor: Colors.red)
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red)
        );
      }
    }
  }

  // Updated share functionality
  Future<void> _handleShare() async {
    final user = ref.read(userNotifierProvider);
    if (user == null || widget.quote == null) return;

    // Show user selection dialog
    showDialog(
      context: context,
      builder: (context) => UserSelectionDialog(
        onUserSelected: (selectedUser) async {
          await _shareWithUser(user, selectedUser);
        },
      ),
    );
  }

  Future<void> _shareWithUser(dynamic currentUser, SimpleUser selectedUser) async {
    setState(() => isLoading = true);

    try {
      // Send resource message using the new message system
      final result = await ref.read(resourceMessageNotifierProvider.notifier)
          .sendResourceToUser(
        fromUserId: currentUser.uid,
        fromUsername: currentUser.username ?? currentUser.name,
        toUserId: selectedUser.uid,
        toUsername: selectedUser.username,
        resource: _createResourceModel(),
      );

      if (mounted) {
        setState(() => isLoading = false);

        if (result.contains('successfully')) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Resource shared with ${selectedUser.name}!'),
                backgroundColor: Colors.green,
              )
          );

          // Optionally update the old sharing system too
          await ref.read(resourcesNotifierProvider.notifier)
              .shareResource(currentUser.uid, selectedUser.uid, _createResourceModel());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to share: $result'),
                backgroundColor: Colors.red,
              )
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error sharing resource: ${e.toString()}'),
              backgroundColor: Colors.red,
            )
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);

    if (isInitializing) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
                Expanded(
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.articleType ?? 'Content',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600
                          ),
                        )
                    )
                ),
              ],
            ),
            SizedBox(height: 60),
            EnhancedQuoteCard(
              quote: widget.quote,
              author: widget.author,
              articleType: widget.articleType,
              title: widget.title,
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Like Button
                      GestureDetector(
                        onTap: isLoading ? null : _handleLike,
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 30,
                          color: isLiked ? Colors.red : Colors.black,
                        ),
                      ),
                      SizedBox(width: 7.5),

                      // Dislike Button
                      GestureDetector(
                        onTap: isLoading ? null : _handleDislike,
                        child: Icon(
                          isDisliked ? Icons.sentiment_dissatisfied : Icons.sentiment_dissatisfied_outlined,
                          size: 30,
                          color: isDisliked ? Colors.orange : Colors.black,
                        ),
                      ),
                      SizedBox(width: 7.5),

                      // Share Button
                      GestureDetector(
                        onTap: isLoading ? null : _handleShare,
                        child: Icon(
                          Icons.share_outlined,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // Save Button
                  GestureDetector(
                    onTap: isLoading ? null : _handleSave,
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 30,
                      color: isSaved ? Colors.blue : Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Loading indicator
            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator()
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}