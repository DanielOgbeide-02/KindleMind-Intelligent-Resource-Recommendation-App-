import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:recommender_nk/provider/resource_model/resource_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' show Random;
import '../../core/config.dart';
import '../../data/datasources/get_resources.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../provider/auth_provider.dart';
import '../../provider/resource_model/user_notifier_provider.dart';
import '../../provider/user_provider.dart';

class RecommendationService {
  final Ref ref;

  // Use the actual IP address from your Flask server log
  String get apiUrlBase {
    // Use the IP address shown in your Flask server log: http://172.16.4.67:5000
    return Config.apiUrl;
  }

  RecommendationService(this.ref);

  Future<Map<String, dynamic>> getNewUserRecommendationPayload(String userId, [String? specificResourceType]) async {
    try {
      final resourceNotifier = ref.read(resourcesNotifierProvider.notifier);
      final authRepository = FirebaseAuthRepository();
      final authController = ref.read(authControllerProvider.notifier);

      // Fetch user details
      final user = await authController.getUserDetails() ??
          await authRepository.getUserDetails(userId).then((doc) => UserModel.fromMap(doc.data()!));
      if (user == null) throw Exception('User not found');

      // Fetch interactions
      final likedResources = await resourceNotifier.getLikedResources(userId);
      final dislikedResources = await resourceNotifier.getDislikedResources(userId);
      final interactions = [
        ...likedResources.map((r) => {"resource_id": r.quote, "interaction_type": "like"}),
        ...dislikedResources.map((r) => {"resource_id": r.quote, "interaction_type": "dislike"}),
      ];

      // Fetch available resources from Firestore
      final resourcesModel = ResourcesModel();
      final availableResources = <Map<String, dynamic>>[];

      // Use specific resource type if provided, otherwise use the first preferred type
      final resourceTypeToUse = specificResourceType ??
          (user.preferredResourceTypes.isNotEmpty
              ? user.preferredResourceTypes.first
              : "Motivational Messages");

      print('Building payload for resource type: $resourceTypeToUse');

      // Only fetch resources for the specific type being requested
      if (resourceTypeToUse == "Motivational Messages") {
        final allMotivational = await resourcesModel.getAllMotivationalQuotes();
        if (allMotivational != null) {
          for (var doc in allMotivational) {
            availableResources.add({
              "resource_id": doc['quote'],
              "resource_type": "Motivational Message",
              "content": doc['quote'],
              "author": doc['author'],           // Add this line to include author
            });
          }
        }
      } else if (resourceTypeToUse == "Coping Strategies") {
        final allCoping = await resourcesModel.getAllCopingStrategies();
        if (allCoping != null) {
          for (var doc in allCoping) {
            availableResources.add({
              "resource_id": doc['title'] ?? doc['content'].toString().substring(0, 10),
              "resource_type": "Coping Strategy",
              "content": doc['content'],
            });
          }
        }
      } else if (resourceTypeToUse == "Articles") {
        final allArticles = await resourcesModel.getAllArticles();
        if (allArticles != null) {
          for (var doc in allArticles) {
            availableResources.add({
              "resource_id": doc['title'] ?? doc['content'].toString().substring(0, 10),
              "resource_type": "Article",
              "content": doc['content'],
            });
          }
        }
      }
      availableResources.shuffle(Random());

      print('Available resources for $resourceTypeToUse: ${availableResources.length}');

      // Debug: Print the first few resources to verify type
      for (int i = 0; i < availableResources.length && i < 3; i++) {
        print('Resource $i: Type=${availableResources[i]['resource_type']}, ID=${availableResources[i]['resource_id']}');
      }

      return {
        "user_id": user.uid,
        "recovery_stage": user.recoveryStage ?? "Unknown",
        "preferred_resource_type": resourceTypeToUse,
        "available_resources": availableResources,
        "interactions": interactions,
        "top_k": 3, // Increased from 2 to 5
      };
    } catch (e) {
      print('Error in getNewUserRecommendationPayload: $e');
      rethrow;
    }
  }

  /// Modified payload method - removes available_resources to get ONLY similar users
  Future<Map<String, dynamic>> getSimilarUsersPayload(String userId) async {
    try {
      final resourceNotifier = ref.read(resourcesNotifierProvider.notifier);
      final authRepository = FirebaseAuthRepository();
      final authController = ref.read(authControllerProvider.notifier);

      // Fetch target user details
      final user = await authController.getUserDetails() ??
          await authRepository.getUserDetails(userId).then((doc) => UserModel.fromMap(doc.data()!));
      if (user == null) throw Exception('User not found');

      // Fetch interactions for the target user (for similarity calculation)
      final likedResources = await resourceNotifier.getLikedResources(userId);
      final dislikedResources = await resourceNotifier.getDislikedResources(userId);
      final targetUserInteractions = [
        ...likedResources.map((r) => {"resource_id": r.quote, "interaction_type": "like", "user_id": userId}),
        ...dislikedResources.map((r) => {"resource_id": r.quote, "interaction_type": "dislike", "user_id": userId}),
      ];

      // Fetch all users with complete data (excluding the target user)
      final allUsersData = await authRepository.getAllUsers();
      final allUsers = <Map<String, dynamic>>[];
      final allInteractions = <Map<String, dynamic>>[];

      // Add target user interactions
      allInteractions.addAll(targetUserInteractions);

      for (final userData in allUsersData) {
        // if (userData['uid'] == userId) continue; // Skip target user
        print('Raw userData: $userData');
        final uid = userData['id'];
        print('Checking user: $uid');

        if (uid == null || uid == userId) {
          print('Skipping user: $uid (null or same as current user)');
          continue;
        }
        try {
          // Fetch actual user interactions for similarity calculation
          final userLikedResources = await resourceNotifier.getLikedResources(userData['id']!);
          final userDislikedResources = await resourceNotifier.getDislikedResources(userData['id']!);

          // Get actual user details from Firestore
          final userDoc = await authRepository.getUserDetails(userData['id']!);
          final actualUserData = userDoc.data();

          if (actualUserData != null) {
            final userModel = UserModel.fromMap(actualUserData);

            // Build complete user data with display info
            final completeUserData = {
              "user_id": userModel.uid,
              "username": userModel.username ?? "Unknown", // For display
              "name": userModel.name ?? "Anonymous", // For display
              "recovery_stage": userModel.recoveryStage ?? "Unknown",
              "preferred_resource_type": userModel.preferredResourceTypes.isNotEmpty
                  ? userModel.preferredResourceTypes.first
                  : "Motivational Messages",
              "preferred_resource_types": userModel.preferredResourceTypes,
              "age": userModel.age,
              "gender": userModel.gender,
              "liked_resources_count": userLikedResources.length,
              "disliked_resources_count": userDislikedResources.length,
            };

            allUsers.add(completeUserData);

            // Add user interactions for similarity calculation
            final userInteractions = [
              ...userLikedResources.map((r) => {"resource_id": r.quote, "interaction_type": "like", "user_id": userData['id']}),
              ...userDislikedResources.map((r) => {"resource_id": r.quote, "interaction_type": "dislike", "user_id": userData['id']}),
            ];
            allInteractions.addAll(userInteractions);
          }
        } catch (e) {
          print('Error fetching data for user ${userData['id']}: $e');
          continue;
        }
      }

      print('Found ${allUsers.length} users for similarity comparison');

      return {
        "user_data": {
          "user_id": user.uid,
          "recovery_stage": user.recoveryStage ?? "Unknown",
          "preferred_resource_type": user.preferredResourceTypes.isNotEmpty
              ? user.preferredResourceTypes.first
              : "Motivational Messages",
          "preferred_resource_types": user.preferredResourceTypes,
          "age": user.age,
          "gender": user.gender,
          "liked_resources_count": likedResources.length,
          "disliked_resources_count": dislikedResources.length,
        },
        "all_users": allUsers,
        "interactions": allInteractions,
        "top_k_users": 5, // Get top 5 similar users
        // 🚀 REMOVED: available_resources - Flask will skip resource recommendations
        // 🚀 REMOVED: top_k_resources - We only want similar users
      };
    } catch (e) {
      print('Error in getSimilarUsersPayload: $e');
      rethrow;
    }
  }

  /// Modified method - now returns ONLY similar users (no resource recommendations)
  Future<List<Map<String, dynamic>>> getSimilarUsersRecommendations(String userId) async {
    try {
      print('Attempting to connect to: $apiUrlBase/recommend/similar_users');

      // Use the modified payload that excludes available_resources
      final payload = await getSimilarUsersPayload(userId);

      final response = await http.post(
        Uri.parse('$apiUrlBase/recommend/similar_users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10000));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        // 🚀 RETURN ONLY similar_users (not recommended_resources)
        final similarUsers = (result['similar_users'] as List<dynamic>?)
            ?.map((user) => user as Map<String, dynamic>)
            .toList() ?? [];

        print('Found ${similarUsers.length} similar users');
        return similarUsers;

      } else {
        throw Exception('Failed to get similar users: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in getSimilarUsersRecommendations: $e');
      // Return empty list instead of error object
      return [];
    }
  }

  /// Optional: Rename the method to be clearer about what it does
  Future<List<Map<String, dynamic>>> getSimilarUsers(String userId) async {
    return getSimilarUsersRecommendations(userId);
  }






  /// Get recommendations for all preferred resource types
  Future<Map<String, dynamic>> getAllPreferredTypeRecommendations(String userId) async {
    try {
      final user = ref.read(userNotifierProvider);
      if (user == null) throw Exception('User not found');

      final preferredTypes = user.preferredResourceTypes.isNotEmpty
          ? user.preferredResourceTypes
          : ["Motivational Messages"]; // Default fallback

      print('Getting recommendations for resource types: $preferredTypes');

      final List<Map<String, dynamic>> allRecommendations = [];
      final Map<String, dynamic> combinedResponse = {
        'recommended_resources': [],
        'resource_type_breakdown': {},
        'total_recommendations': 0,
      };

      // Get recommendations for each preferred resource type
      for (String resourceType in preferredTypes) {
        try {
          print('Fetching recommendations for: $resourceType');

          final payload = await getNewUserRecommendationPayload(userId, resourceType);

          final response = await http.post(
            Uri.parse('$apiUrlBase/recommend/new_user'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          ).timeout(const Duration(seconds: 10000));

          print('Response for $resourceType - Status: ${response.statusCode}');

          if (response.statusCode == 200) {
            final typeRecommendations = jsonDecode(response.body);
            final resources = (typeRecommendations['recommended_resources'] as List<dynamic>?)
                ?.map((r) => r as Map<String, dynamic>)
                .toList() ?? [];

            // Add resource type identifier to each recommendation
            for (var resource in resources) {
              resource['source_preference_type'] = resourceType;
            }

            // Debug: Print what we got back for this resource type
            print('Received ${resources.length} recommendations for $resourceType:');
            for (var resource in resources) {
              print('  - Type: ${resource['resource_type']}, ID: ${resource['resource_id']}');
            }

            allRecommendations.addAll(resources);
            combinedResponse['resource_type_breakdown'][resourceType] = resources.length;

            print('Added ${resources.length} recommendations for $resourceType');
          } else {
            print('Failed to get recommendations for $resourceType: ${response.statusCode}');
            print('Response body: ${response.body}');
            combinedResponse['resource_type_breakdown'][resourceType] = 0;
          }
        } catch (e) {
          print('Error getting recommendations for $resourceType: $e');
          combinedResponse['resource_type_breakdown'][resourceType] = 0;
        }
      }

      // Sort all recommendations by score (highest first)
      allRecommendations.sort((a, b) {
        final scoreA = a['recommendation_score']?.toDouble() ?? 0.0;
        final scoreB = b['recommendation_score']?.toDouble() ?? 0.0;
        return scoreB.compareTo(scoreA);
      });

      // Limit to top recommendations - increased to show more variety
      final topRecommendations = allRecommendations.take(15).toList(); // Increased from 6 to 15

      combinedResponse['recommended_resources'] = topRecommendations;
      combinedResponse['total_recommendations'] = topRecommendations.length;

      print('Combined recommendations: ${topRecommendations.length} total');
      print('Breakdown by type: ${combinedResponse['resource_type_breakdown']}');

      return combinedResponse;

    } catch (e) {
      print('Error in getAllPreferredTypeRecommendations: $e');
      return {
        'recommended_resources': [],
        'error': 'Failed to get recommendations: $e',
        'resource_type_breakdown': {},
        'total_recommendations': 0,
      };
    }
  }

  /// Legacy method - now uses the new multi-type approach
  Future<Map<String, dynamic>> getNewUserRecommendations(String userId) async {
    return getAllPreferredTypeRecommendations(userId);
  }



  /// Get recommendations for similar users across all preferred resource types

}

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService(ref);
});