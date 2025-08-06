import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recommender_nk/config/theme/app_theme.dart';
import 'package:recommender_nk/data/datasources/get_resources.dart';
import 'package:recommender_nk/domain/services/notification_service.dart';

import '../../../../domain/services/recommendation_service.dart';
import '../../../../provider/resource_model/user_notifier_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final Future<Map<String, dynamic>?> dailyFuture;
  late final Future<List<Map<String, dynamic>>?> quotesFuture;
  late final Future<List<Map<String, dynamic>>?> copingFuture;
  late final Future<List<Map<String, dynamic>>?> articleFuture;
  late final Future<Map<String, dynamic>> recommendationFuture;

  @override
  void initState() {
    super.initState();
    final model = ResourcesModel();
    final recommendationService = ref.read(recommendationServiceProvider);

    // Assign to class variables
    dailyFuture = model.getDailyMotivation();
    quotesFuture = model.getAllMotivationalQuotes();
    copingFuture = model.getAllCopingStrategies();
    articleFuture = model.getAllArticles();

    final user = ref.read(userNotifierProvider);
    final userId = user?.uid;

    // Use the enhanced recommendation method that handles all preferred types
    recommendationFuture = recommendationService.getAllPreferredTypeRecommendations(userId!);
  }

  Widget _buildSection(String title, List<Widget> cards, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      )),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textPrimary.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  ShowLocalNotification().scheduleNotification(
                      'title',
                      'body',
                      5
                  );
                },
                child: Icon(Icons.chevron_right, color: AppTheme.primary),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (_, i) => cards[i],
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: cards.length,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(String author, String quote) {
    return GestureDetector(
      onTap: () {
        context.push('/each_content', extra: {
          'quote': quote,
          'author': author,
          'articleType': 'Motivational'
        });
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(8),
        child: Text(
          author,
          style: TextStyle(
            color: AppTheme.surface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildCopingCard(String advice, String content) {
    return GestureDetector(
      onTap: () {
        context.push('/each_content', extra: {
          'quote': advice,
          'author': 'Coping Strategy',
          'articleType': 'Coping Strategy'
        });
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(8),
        child: Text(
          'Coping Strategy',
          style: TextStyle(
            color: AppTheme.surface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article, String content) {
    final String title = article['title']?.toString() ?? 'Article';
    final String content = article['content']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        context.push('/each_content', extra: {
          'quote': content,
          'author': 'Article',
          'articleType': 'Article',
          'title': title,
        });
        print('title: $title');
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(8),
        child: Text(
          title,
          style: TextStyle(
            color: AppTheme.surface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );
  }

  // Updated recommendation card to match the consistent design
  Widget _buildRecommendationCard(Map<String, dynamic> resource) {
    final String resourceId = resource['resource_id']?.toString() ?? '';
    final String resourceType = resource['resource_type']?.toString() ?? '';
    final String content = resource['content']?.toString() ?? '';
    final double score = resource['recommendation_score']?.toDouble() ?? 0.0;
    final String sourcePreferenceType = resource['source_preference_type']?.toString() ?? '';
    final String authorMotivational = resource['author']?.toString()??'';

    // Get display text based on resource type
    String displayText = resourceType;

    // For specific resource types, you might want to show more specific info
    if (resourceType.contains('Motivational')) {
      // For motivational quotes, try to extract author or show "Motivational Quote"
      displayText = 'Motivational Quote';
    } else if (resourceType.contains('Coping')) {
      displayText = 'Coping Strategy';
    } else if (resourceType.contains('Article')) {
      // For articles, you might want to show a truncated title if available
      // displayText = 'Article';
      displayText = resource['resource_id'] ?? 'Article'; // Show actual article title
    }

    return GestureDetector(
      onTap: () {
        context.push('/each_content', extra: {
          'quote': content,
          'author': resourceType.contains('Motivational')?authorMotivational:resourceType,
          'articleType': resourceType,
          'title': resourceType.contains('Article')?resource['resource_id'].toString():'',
        });
      },
      child: Container(
        width: 140, // Same width as other cards
        decoration: BoxDecoration(
          color: AppTheme.primary, // Same color as other cards
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        alignment: Alignment.bottomLeft, // Same alignment as other cards
        padding: const EdgeInsets.all(8), // Same padding as other cards
        child: Text(
          displayText,
          style: TextStyle(
            color: AppTheme.surface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2, // Allow up to 2 lines like article cards
        ),
      ),
    );
  }

  Widget _buildDailyBanner(Map<String, dynamic>? dailyData) {
    if (dailyData == null) {
      return SizedBox(
        height: 200,
        child: Center(child: Text('Failed to load daily motivation')),
      );
    }

    final String quote = dailyData['quote']?.toString() ?? '';
    final String author = dailyData['author']?.toString() ?? 'Unknown';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: (){
          context.push('/each_content', extra: {
            'quote': quote,
            'author': author,
            'articleType': 'Daily Motivation'
          });
        },
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primary,
                AppTheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          alignment: Alignment.bottomLeft,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                quote,
                style: TextStyle(
                  color: AppTheme.surface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '- $author',
                style: TextStyle(
                  color: AppTheme.surface.withOpacity(0.85),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotesSection(List<Map<String, dynamic>>? quotesData) {
    if (quotesData == null || quotesData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('No motivational messages available'),
      );
    }

    final cards = quotesData
        .map((q) {
      final String author = q['author']?.toString() ?? 'Unknown';
      final String quote = q['quote']?.toString() ?? '';
      return _buildCard(author, quote);
    })
        .toList();

    return _buildSection('Motivational Messages', cards);
  }

  Widget _buildCopingSection(String title, List<Map<String, dynamic>>? copingData) {
    if (copingData == null || copingData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('No coping strategies available'),
      );
    }

    final cards = copingData
        .map((item) {
      final String itemTitle = item['title']?.toString() ?? '';
      final String content = item['content']?.toString() ?? '';
      return _buildCopingCard(itemTitle, content);
    })
        .toList();

    return _buildSection(title, cards);
  }

  Widget _buildArticlesSection(String title, List<Map<String, dynamic>>? articlesData) {
    if (articlesData == null || articlesData.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('No articles available'),
      );
    }

    final cards = articlesData
        .map((article) {
      final String articleTitle = article['title']?.toString() ?? '';
      final String content = article['content']?.toString() ?? '';
      return _buildArticleCard(article, content);
    })
        .toList();

    return _buildSection(title, cards);
  }

  Widget _buildRecommendationsSection(Map<String, dynamic>? recommendations) {
    if (recommendations == null || recommendations['recommended_resources'] == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('No recommendations available'),
      );
    }

    final recommendedResources = (recommendations['recommended_resources'] as List<dynamic>?)
        ?.map((r) => Map<String, dynamic>.from(r as Map))
        .toList() ?? [];

    if (recommendedResources.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('No recommendations found'),
      );
    }

    // Create subtitle with breakdown info
    final breakdown = recommendations['resource_type_breakdown'] != null
        ? Map<String, dynamic>.from(recommendations['resource_type_breakdown'] as Map)
        : <String, dynamic>{};
    final totalRecs = recommendations['total_recommendations'] ?? 0;
    String subtitle = 'Based on your preferences • $totalRecs items';

    if (breakdown.isNotEmpty) {
      final breakdownText = breakdown.entries
          .where((entry) => entry.value > 0)
          .map((entry) => '${entry.value} ${entry.key}')
          .join(', ');
      if (breakdownText.isNotEmpty) {
        subtitle = '$breakdownText';
      }
    }

    final cards = recommendedResources.map((resource) {
      // Print the recommendation details for debugging
      print('Recommended Resource:');
      print('  ID: ${resource['resource_id']}');
      print('  Type: ${resource['resource_type']}');
      print('  Score: ${resource['recommendation_score']}');
      print('  Source Preference: ${resource['source_preference_type']}');
      print('---');

      return _buildRecommendationCard(resource);
    }).toList();

    return _buildSection('Recommended for You', cards, subtitle: subtitle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        title: Text('KindleMind',
            style: TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: 24,
              color: Colors.white,
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                GestureDetector(onTap: (){
                  context.push('/notifications');
                }, child: Icon(Icons.notifications, color: AppTheme.white14, size: 35,)),
                SizedBox(width: 10,),
                CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: AppTheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([dailyFuture, quotesFuture, copingFuture, articleFuture, recommendationFuture]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading data: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final List<dynamic> results = snapshot.data!;
          final dailyData = results[0] as Map<String, dynamic>?;
          final quotesData = results[1] != null ? List<Map<String, dynamic>>.from(results[1] as List) : null;
          final copingData = results[2] != null ? List<Map<String, dynamic>>.from(results[2] as List) : null;
          final articlesData = results[3] != null ? List<Map<String, dynamic>>.from(results[3] as List) : null;
          final recommendations = results[4] as Map<String, dynamic>?;

          return ListView(
            children: [
              // 1️⃣ Daily Motivation Banner
              _buildDailyBanner(dailyData),

              // 2️⃣ Enhanced Recommendations Section (moved up for better visibility)
              _buildRecommendationsSection(recommendations),

              // 3️⃣ Random Quotes Carousel
              _buildQuotesSection(quotesData),

              // 4️⃣ Coping Strategies Carousel
              _buildCopingSection('Coping Strategies', copingData),

              // 5️⃣ Articles Carousel
              _buildArticlesSection('Articles', articlesData),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}