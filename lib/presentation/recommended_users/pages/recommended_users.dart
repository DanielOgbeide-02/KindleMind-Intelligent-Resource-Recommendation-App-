import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recommender_nk/presentation/recommended_users/widgets/user_item.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/services/recommendation_service.dart';
import '../../../provider/resource_model/user_notifier_provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/resource_message/resource_message_notifier.dart';
import '../../search/widgets/custom_search/custom_search.dart';

class RecommendedUsers extends ConsumerStatefulWidget {
  const RecommendedUsers({super.key});

  @override
  ConsumerState<RecommendedUsers> createState() => _RecommendedUsersState();
}

class _RecommendedUsersState extends ConsumerState<RecommendedUsers> {
  late String currentUserId;
  String _searchQuery = '';
  bool _isLoadingRecommendations = false;
  List<Map<String, String>> _recommendedUsers = [];
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.read(userNotifierProvider);
    if (user != null) {
      currentUserId = user.uid;
      _loadRecommendedUsers();
    }
  }

  Future<void> _loadRecommendedUsers() async {
    if (_isLoadingRecommendations) return;

    setState(() {
      _isLoadingRecommendations = true;
      _error = null;
    });

    try {
      final recommendationService = ref.read(recommendationServiceProvider);
      final authRepository = ref.read(firebaseAuthRepositoryProvider);

      final similarUsers = await recommendationService.getSimilarUsersRecommendations(currentUserId);

      if (similarUsers.isEmpty) {
        throw Exception('No similar users found');
      }

      final List<Map<String, String>> convertedUsers = [];

      for (final user in similarUsers) {
        final userId = user['user_id']?.toString();
        if (userId == null || userId == currentUserId) continue;

        final fullUser = await authRepository.getUserById(userId); // ✅ use repository
        if (fullUser == null) continue;

        convertedUsers.add({
          'id': fullUser.uid,
          'name': fullUser.name ?? 'Anonymous',
          'username': fullUser.username ?? 'unknown',
          'bio': 'Recovery Stage: ${fullUser.recoveryStage ?? "Unknown"}',
        });
      }

      setState(() {
        _recommendedUsers = convertedUsers;
        _isLoadingRecommendations = false;
      });

    } catch (e) {
      setState(() {
        _error = 'Failed to load recommended users: $e';
        _isLoadingRecommendations = false;
      });

      final usersAsync = ref.read(usersExceptCurrentProvider(currentUserId));
      await usersAsync.when(
        data: (users) {
          setState(() {
            _recommendedUsers = users;
          });
        },
        loading: () {},
        error: (error, stackTrace) {},
      );
    }
  }


  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  List<Map<String, String>> _filterUsers(List<Map<String, String>> users) {
    if (_searchQuery.isEmpty) return users;

    return users.where((user) {
      final name = user['name']?.toLowerCase() ?? '';
      final username = user['username']?.toLowerCase() ?? '';
      return name.contains(_searchQuery) || username.contains(_searchQuery);
    }).toList();
  }

  bool _hasUnreadMessages(String otherUserId) {
    final messageNotifier = ref.read(resourceMessageNotifierProvider.notifier);
    return messageNotifier.hasUnreadMessagesFrom(currentUserId, otherUserId);
  }

  Future<void> _refreshRecommendations() async {
    await _loadRecommendedUsers();
  }

  Widget _buildRecommendationIndicator() {
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Using fallback user list. ${_error!}',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.people_outline, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing users based on your preferences and activity',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userNotifierProvider);

    if (currentUser == null) {
      return SafeArea(
        child: Scaffold(
          body: Center(child: Text('Please log in to see recommended users')),
        ),
      );
    }

    // Watch message provider to trigger rebuilds when messages change
    ref.watch(resourceMessageNotifierProvider);

    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header with refresh button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recommended Users',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoadingRecommendations ? null : _refreshRecommendations,
                    icon: _isLoadingRecommendations
                        ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Icon(Icons.refresh),
                    tooltip: 'Refresh recommendations',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recommendation status indicator
              _buildRecommendationIndicator(),

              // Search bar
              CustomSearchBar(onChanged: _onSearchChanged, isUsers: true),
              const SizedBox(height: 30),

              // Users list
              Expanded(
                child: _isLoadingRecommendations
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text('Loading personalized recommendations...'),
                    ],
                  ),
                )
                    : _buildUsersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    final usersAsync = ref.watch(usersExceptCurrentProvider(currentUserId));

    return usersAsync.when(
      data: (allUsers) {
        // Use recommended users if available, otherwise use all users
        final usersToShow = _recommendedUsers.isNotEmpty ? _recommendedUsers : allUsers;
        final filteredUsers = _filterUsers(usersToShow);

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No users found'
                      : 'No users match your search',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                if (_searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    child: Text('Clear search'),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: filteredUsers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 25),
          padding: const EdgeInsets.only(bottom: 25),
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            final hasUnread = _hasUnreadMessages(user['id']!);

            return GestureDetector(
              onTap: () {
                context.push('/users_page/${user['id']}');
              },
              child: Stack(
                children: [
                  UserItem(
                    name: user['name'],
                    userName: user['username'],
                    bioInfo: user['bio'],
                  ),
                  // Red dot for unread messages
                  if (hasUnread)
                    Positioned(
                      top: 14,
                      right: 195,
                      child: Container(
                        width: 12,
                        height: 12,
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
                  // Recommendation badge (if this is a recommended user)
                ],
              ),
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading users',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.refresh(usersExceptCurrentProvider(currentUserId));
                _refreshRecommendations();
              },
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}