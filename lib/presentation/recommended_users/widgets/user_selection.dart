import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../provider/auth_provider.dart';
import '../../../../provider/resource_model/user_notifier_provider.dart';

class SimpleUser {
  final String uid;
  final String name;
  final String username;

  SimpleUser({
    required this.uid,
    required this.name,
    required this.username,
  });
}

class UserSelectionDialog extends ConsumerStatefulWidget {
  final Function(SimpleUser) onUserSelected;

  const UserSelectionDialog({
    super.key,
    required this.onUserSelected,
  });

  @override
  ConsumerState<UserSelectionDialog> createState() => _UserSelectionDialogState();
}

class _UserSelectionDialogState extends ConsumerState<UserSelectionDialog> {
  String _searchQuery = '';

  List<SimpleUser> _filterUsers(List<Map<String, String>> users) {
    List<SimpleUser> simpleUsers = users.map((user) => SimpleUser(
      uid: user['id'] ?? '',
      name: user['name'] ?? user['username'] ?? 'Unknown User',
      username: user['username'] ?? 'unknown',
    )).toList();

    if (_searchQuery.isEmpty) return simpleUsers;

    return simpleUsers.where((user) {
      final name = user.name.toLowerCase();
      final username = user.username.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || username.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userNotifierProvider);

    if (currentUser == null) {
      return AlertDialog(
        title: Text('Error'),
        content: Text('Please log in to share resources'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      );
    }

    final usersAsync = ref.watch(usersExceptCurrentProvider(currentUser.uid));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share with',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Search bar
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            SizedBox(height: 16),

            // Users list
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  final filteredUsers = _filterUsers(users);

                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person_search,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No users available'
                                : 'No users match your search',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // return ListView.separated(
                  //   itemCount: filteredUsers.length,
                  //   separatorBuilder: (context, index) => Divider(height: 1),
                  //   itemBuilder: (context, index) {
                  //     final user = filteredUsers[index];
                  //     return ListTile(
                  //       contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  //       leading: CircleAvatar(
                  //         radius: 25,
                  //         backgroundColor: Colors.blue.withOpacity(0.1),
                  //         child: Icon(
                  //           Icons.person,
                  //           color: Colors.blue,
                  //           size: 30,
                  //         ),
                  //       ),
                  //       title: Text(
                  //         user.name,
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.w600,
                  //           fontSize: 16,
                  //         ),
                  //       ),
                  //       subtitle: Text(
                  //         '@${user.username}',
                  //         style: TextStyle(
                  //           color: Colors.grey[600],
                  //           fontSize: 14,
                  //         ),
                  //       ),
                  //       onTap: () {
                  //         Navigator.of(context).pop();
                  //         widget.onUserSelected(user);
                  //       },
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       hoverColor: Colors.grey[100],
                  //     );
                  //   },
                  // );

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        title: Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          '@${user.username}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onUserSelected(user);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hoverColor: Colors.grey[100],
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading users...'),
                    ],
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Error loading users',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.refresh(usersExceptCurrentProvider(currentUser.uid)),
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
    );
  }
}