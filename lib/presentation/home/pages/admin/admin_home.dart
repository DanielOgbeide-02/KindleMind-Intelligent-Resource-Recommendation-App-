import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/app_theme.dart';
import '../../../../provider/admin_auth_provider.dart';
import '../../../../provider/resource_model/resource_model.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load dashboard data when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminProvider.notifier).loadDashboardData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showUploadDialog() {
    final quoteController = TextEditingController();
    final authorController = TextEditingController();
    String selectedType = 'Motivational';

    final types = ['Motivational', 'Article', 'Coping Strategies'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Upload New Resource'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quoteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Quote/Content',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(
                    labelText: 'Author',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Article Type',
                    border: OutlineInputBorder(),
                  ),
                  items: types.map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (quoteController.text.isNotEmpty && authorController.text.isNotEmpty) {
                  final resource = ResourceModel(
                    quote: quoteController.text,
                    author: authorController.text,
                    articleType: selectedType,
                  );

                  final result = await ref.read(adminProvider.notifier).uploadResource(resource);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result),
                        backgroundColor: result.contains('successfully') ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final admin = ref.watch(currentAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(color: Colors.white),),
        backgroundColor: AppTheme.primary,
        bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.black, // Active tab text color
        unselectedLabelColor: Colors.white70, // Inactive tab text color
        indicatorColor: Colors.yellow, // Optional: indicator under active tab
        tabs: const [
          Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
          Tab(icon: Icon(Icons.upload_file), text: 'Uploads'),
          Tab(icon: Icon(Icons.settings), text: 'Settings'),
        ],
      ),

      actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Upload Resource',
            onPressed: _showUploadDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Overview Tab
          Center(
            child: adminState.isLoading
                ? const CircularProgressIndicator()
                : Text('Welcome ${admin?.name ?? 'Admin'}!\nTotal Resources: ${adminState.resources.length}'),
          ),

          // Uploads Tab
          ListView.builder(
            itemCount: adminState.resources.length,
            itemBuilder: (context, index) {
              final resource = adminState.resources[index];
              return ListTile(
                title: Text(resource['quote']??''),
                subtitle: Text('${resource['author']??''} • ${resource['articleType']??''}'),
              );
            },
          ),

          // Settings Tab
          Center(
            child: ElevatedButton(
              onPressed: () {
                ref.read(adminProvider.notifier).signOut();
                Navigator.pop(context); // or navigate to login screen
              },
              child: GestureDetector( onTap: (){
                context.go('/sign_in');
              },child: const Text('Logout')),
            ),
          ),
        ],
      ),
    );
  }
}
