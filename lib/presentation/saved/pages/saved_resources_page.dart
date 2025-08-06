// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:recommender_nk/presentation/search/widgets/custom_search/custom_search.dart';
// import 'package:recommender_nk/presentation/search/widgets/resource_item/resource_item.dart';
// import 'package:go_router/go_router.dart';
// import '../../../data/datasources/get_resources.dart';
// import '../../../provider/resource_model/resource_model.dart';
//
// class SavedResourcesPage extends StatefulWidget {
//   const SavedResourcesPage({super.key});
//
//   @override
//   State<SavedResourcesPage> createState() => _SavedResourcesPageState();
// }
//
// class _SavedResourcesPageState extends State<SavedResourcesPage> {
//   String _searchQuery = '';
//   List<ResourceModel> _filteredResources = [];
//   List<ResourceModel> _allResources = [];
//   bool _isLoading = true;
//   final ResourcesModel _resourcesModel = ResourcesModel();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAllResources();
//   }
//
//   Future<void> _loadAllResources() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });
//
//       // Fetch all data from Firebase
//       final motivationalData = await _resourcesModel.getAllMotivationalQuotes();
//       final copingData = await _resourcesModel.getAllCopingStrategies();
//       final articleData = await _resourcesModel.getAllArticles();
//
//       List<ResourceModel> allResources = [];
//
//       // Convert motivational quotes
//       for (var item in motivationalData) {
//         allResources.add(ResourceModel(
//           quote: item['quote'] ?? '',
//           author: item['author'] ?? 'Unknown',
//           articleType: 'Motivational',
//         ));
//       }
//
//       // Convert coping strategies
//       for (var item in copingData) {
//         allResources.add(ResourceModel(
//           quote: item['content'] ?? '', // Use strategy or title field
//           author: item['title'] ?? 'Coping Strategy', // For display purposes
//           articleType: 'Coping Strategy',
//         ));
//       }
//
//       // Convert articles
//       for (var item in articleData) {
//         allResources.add(ResourceModel(
//           quote: item['content'] ?? '', // Use content or description
//           author: item['title'] ?? 'Article', // Use title as the "author" field for display
//           articleType: 'Article',
//         ));
//       }
//
//       setState(() {
//         _allResources = allResources;
//         _filteredResources = allResources;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading resources: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _filterResources() {
//     setState(() {
//       List<ResourceModel> filtered = _allResources;
//
//       if (_searchQuery.isNotEmpty) {
//         final query = _searchQuery.toLowerCase();
//
//         filtered = _allResources.where((item) =>
//         item.quote.toLowerCase().contains(query) ||
//             item.author.toLowerCase().contains(query) ||
//             item.articleType.toLowerCase().contains(query)).toList();
//       }
//
//       _filteredResources = filtered;
//     });
//   }
//
//   void _onSearchChanged(String query) {
//     setState(() {
//       _searchQuery = query;
//     });
//     _filterResources();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             children: [
//               CustomSearchBar(onChanged: _onSearchChanged),
//               const SizedBox(height: 30),
//               Expanded(
//                 child: _isLoading
//                     ? const Center(
//                   child: CircularProgressIndicator(),
//                 )
//                     : _filteredResources.isEmpty
//                     ? Center(
//                   child: Text(
//                     _searchQuery.isEmpty
//                         ? 'No resources available'
//                         : 'No results found for "$_searchQuery"',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 )
//                     : ListView.separated(
//                   itemCount: _filteredResources.length,
//                   separatorBuilder: (context, index) => const SizedBox(height: 25),
//                   padding: const EdgeInsets.only(bottom: 25),
//                   itemBuilder: (context, index) {
//                     final item = _filteredResources[index];
//                     return GestureDetector(
//                       onTap: () {
//                         context.push('/each_content', extra: {
//                           'author': item.author,
//                           'quote': item.quote,
//                           'articleType': item.articleType,
//                           'title': item.articleType=='Article'?item.author:'',
//                         });
//                       },
//                       child: ResourceItem(
//                         quote: item.quote,
//                         author: item.author,
//                         articleType: item.articleType,
//                       ),
//                     );
//                   },
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recommender_nk/presentation/search/widgets/custom_search/custom_search.dart';
import 'package:recommender_nk/presentation/search/widgets/resource_item/resource_item.dart';
import 'package:go_router/go_router.dart';
import '../../../provider/resource_model/resource_model.dart';
import '../../../provider/resource_model/resource_notifier.dart';
import '../../../provider/resource_model/user_notifier_provider.dart';

class SavedResourcesPage extends ConsumerStatefulWidget {
  const SavedResourcesPage({super.key});

  @override
  ConsumerState<SavedResourcesPage> createState() => _SavedResourcesPageState();
}

class _SavedResourcesPageState extends ConsumerState<SavedResourcesPage> {
  String _searchQuery = '';
  List<ResourceModel> _filteredResources = [];
  List<ResourceModel> _allSavedResources = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserSavedResources();
  }

  Future<void> _loadUserSavedResources() async {
    final user = ref.read(userNotifierProvider);

    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please log in to view your saved resources';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final savedResources = await ref.read(resourcesNotifierProvider.notifier)
          .getSavedResources(user.uid);

      // Update the local state with the saved resources
      setState(() {
        _allSavedResources = savedResources;
        _filteredResources = savedResources;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading saved resources: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterResources() {
    setState(() {
      List<ResourceModel> filtered = _allSavedResources;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();

        filtered = _allSavedResources.where((item) =>
        item.quote.toLowerCase().contains(query) ||
            item.author.toLowerCase().contains(query) ||
            item.articleType.toLowerCase().contains(query)).toList();
      }

      _filteredResources = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterResources();
  }

  Future<void> _refreshResources() async {
    await _loadUserSavedResources();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the resources provider to rebuild when it changes
    final savedResources = ref.watch(resourcesNotifierProvider);

    // Update filtered resources when the provider state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLoading && _errorMessage == null) {
        _filterResources();
      }
    });

    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _refreshResources,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: CustomSearchBar(onChanged: _onSearchChanged)),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: _refreshResources,
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Refresh saved resources',
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: _isLoading
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : _errorMessage != null
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshResources,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                      : _filteredResources.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty
                              ? Icons.bookmark_border
                              : Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No saved resources yet\nStart saving resources to see them here!'
                              : 'No results found for "$_searchQuery"',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                    itemCount: _filteredResources.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 25),
                    padding: const EdgeInsets.only(bottom: 25),
                    itemBuilder: (context, index) {
                      final item = _filteredResources[index];
                      return GestureDetector(
                        onTap: () {
                          context.push('/each_content', extra: {
                            'author': item.author,
                            'quote': item.quote,
                            'articleType': item.articleType,
                            'title': item.articleType == 'Article'
                                ? item.author
                                : '',
                          });
                        },
                        child: ResourceItem(
                          quote: item.quote,
                          author: item.author,
                          articleType: item.articleType,
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}