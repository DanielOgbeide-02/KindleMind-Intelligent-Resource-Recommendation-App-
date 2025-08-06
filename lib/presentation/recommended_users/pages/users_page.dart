import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recommender_nk/data/repositories/firebase_auth_repository.dart';
import 'package:recommender_nk/provider/resource_model/user_notifier_provider.dart';

import '../../../config/theme/app_theme.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/resource_message/resource_message_notifier.dart';

class UsersPage extends ConsumerWidget {
  final String? userId;

  const UsersPage({super.key, this.userId});

  bool _hasUnreadMessages(WidgetRef ref, String currentUserId, String otherUserId) {
    final messageNotifier = ref.read(resourceMessageNotifierProvider.notifier);
    return messageNotifier.hasUnreadMessagesFrom(currentUserId, otherUserId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userNotifierProvider);
    ref.watch(resourceMessageNotifierProvider);

    if (currentUser == null) {
      return SafeArea(
        child: Scaffold(
          body: Center(child: Text('Please log in')),
        ),
      );
    }

    // Profile view when userId is provided
    if (userId != null) {
      return _buildProfileView(context, ref, currentUser.uid, userId!);
    }

    // List view when no userId is provided
    return _buildListView(context, ref, currentUser.uid);
  }

  Widget _buildListView(BuildContext context, WidgetRef ref, String currentUserId) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
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
                  SizedBox(width: 20),
                  Text('Users', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: FirebaseAuthRepository().getAllUsersExcept(currentUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error loading users'),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => ref.refresh(allUsersProvider),
                              child: Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final users = snapshot.data ?? [];
                    if (users.isEmpty) {
                      return Center(child: Text('No users found'));
                    }

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final hasUnread = _hasUnreadMessages(ref, currentUserId, user['id']!);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              context.go('/users_page/${user['id']}');
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                                        child: Icon(
                                          Icons.person,
                                          size: 40,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      if (hasUnread)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            width: 15,
                                            height: 15,
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user['name'] ?? 'Unknown',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '@${user['username'] ?? 'unknown'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (hasUnread)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        'New',
                                        style: TextStyle(
                                          color: Colors.red[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, WidgetRef ref, String currentUserId, String userId) {
    final allUsersAsync = ref.watch(allUsersProvider);

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
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
                  SizedBox(width: 20),
                  Text('User Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(height: 40),
              Expanded(
                child: allUsersAsync.when(
                  data: (users) {
                    final user = users.firstWhere(
                          (u) => u['id'] == userId,
                      orElse: () => <String, String>{},
                    );

                    if (user.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('User not found'),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => context.pop(),
                              child: Text('Go Back'),
                            ),
                          ],
                        ),
                      );
                    }

                    final hasUnread = _hasUnreadMessages(ref, currentUserId, userId);

                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: AppTheme.primary.withOpacity(0.1),
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  if (hasUnread)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Text(
                                user['name'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '@${user['username'] ?? 'unknown'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (hasUnread)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      'New messages',
                                      style: TextStyle(
                                        color: Colors.red[700],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(height: 30),
                              GestureDetector(
                                onTap: () {
                                  context.push('/conversation_page', extra: {
                                    'currentUserId': currentUserId,
                                    'otherUserId': user['id'],
                                    'otherUsername': user['username'] ?? 'Unknown',
                                  });
                                },
                                child: Container(
                                  height: 45,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: hasUnread ? Colors.red : AppTheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          hasUnread ? Icons.mark_chat_unread : Icons.message,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          hasUnread ? 'View Messages' : 'Message',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error loading user profile'),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => ref.refresh(allUsersProvider),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}