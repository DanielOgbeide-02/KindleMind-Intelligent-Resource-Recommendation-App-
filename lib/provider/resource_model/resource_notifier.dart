import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recommender_nk/provider/resource_model/resource_model.dart';
import '../../data/repositories/firebase_auth_repository.dart';

class ResourceNotifier extends StateNotifier<List<ResourceModel>> {
  final FirebaseAuthRepository _authRepository;

  ResourceNotifier(this._authRepository) : super([]);

  // ✅ Fetch resources saved by a user
  Future<String> fetchUserResources(String userId) async {
    try {
      final resources = await _authRepository.fetchUserResources(userId);
      state = resources;
      return 'Success';
    } catch (e) {
      return 'Failed to fetch resources: ${e.toString()}';
    }
  }

  Future<String> saveResource(String userId, ResourceModel resource) async {
    try {
      await _authRepository.saveUserResource(userId, resource);
      // Only update the resource if it already exists in state
      final existingIndex = state.indexWhere((r) => r.quote == resource.quote);
      if (existingIndex != -1) {
        final updated = state[existingIndex].copyWith(isSaved: true);
        state = [
          ...state.sublist(0, existingIndex),
          updated,
          ...state.sublist(existingIndex + 1)
        ];
      } else {
        // Add new resource to state
        final updated = resource.copyWith(isSaved: true);
        state = [...state, updated];
      }
      return 'Resource saved successfully';
    } catch (e) {
      return 'Failed to save resource: ${e.toString()}';
    }
  }

// ✅ Remove Saved - FIXED
  Future<String> removeSavedResource(String userId, String resourceQuote) async {
    try {
      await _authRepository.removeSavedResource(userId, resourceQuote);
      // Update existing resource in state
      final existingIndex = state.indexWhere((r) => r.quote == resourceQuote);
      if (existingIndex != -1) {
        final updated = state[existingIndex].copyWith(isSaved: false);
        state = [
          ...state.sublist(0, existingIndex),
          updated,
          ...state.sublist(existingIndex + 1)
        ];
      }
      return 'Resource removed from saved successfully';
    } catch (e) {
      return 'Failed to remove saved resource: ${e.toString()}';
    }
  }

  // ✅ Update resource (generic properties)
  Future<String> updateResource(String userId, ResourceModel updatedResource) async {
    try {
      await _authRepository.updateUserResource(userId, updatedResource);
      _updateLocalResource(updatedResource);
      return 'Resource updated successfully';
    } catch (e) {
      return 'Failed to update resource: ${e.toString()}';
    }
  }

  // ✅ Like
  Future<String> likeResource(String userId, ResourceModel resource) async {
    try {
      await _authRepository.likeUserResource(userId, resource);
      final updated = resource.copyWith(isLiked: true);
      _updateLocalResource(updated);
      return 'Resource liked successfully';
    } catch (e) {
      return 'Failed to like resource: ${e.toString()}';
    }
  }

  // ✅ Unlike
  Future<String> unlikeResource(String userId, String resourceQuote) async {
    try {
      await _authRepository.removeLikedResource(userId, resourceQuote);
      _updateLocalResourceByQuote(resourceQuote, (r) => r.copyWith(isLiked: false));
      return 'Resource unliked successfully';
    } catch (e) {
      return 'Failed to unlike resource: ${e.toString()}';
    }
  }

  // ✅ Dislike
  Future<String> dislikeResource(String userId, ResourceModel resource) async {
    try {
      await _authRepository.dislikeUserResource(userId, resource);
      final updated = resource.copyWith(isDisliked: true);
      _updateLocalResource(updated);
      return 'Resource disliked successfully';
    } catch (e) {
      return 'Failed to dislike resource: ${e.toString()}';
    }
  }

  // ✅ Remove Dislike
  Future<String> removeDislikeResource(String userId, String resourceQuote) async {
    try {
      await _authRepository.removeDislikedResource(userId, resourceQuote);
      _updateLocalResourceByQuote(resourceQuote, (r) => r.copyWith(isDisliked: false));
      return 'Dislike removed successfully';
    } catch (e) {
      return 'Failed to remove dislike: ${e.toString()}';
    }
  }

  // ✅ Share
  Future<String> shareResource(String fromUserId, String toUserId, ResourceModel resource) async {
    try {
      await _authRepository.shareResourceToUser(fromUserId, toUserId, resource);
      final updated = resource.copyWith(isShared: true);
      _updateLocalResource(updated);
      return 'Resource shared successfully';
    } catch (e) {
      return 'Failed to share resource: ${e.toString()}';
    }
  }


  // ✅ Get liked/disliked/shared/received
  Future<List<ResourceModel>> getLikedResources(String userId) async =>
      await _authRepository.getUserLikedResources(userId);

  Future<List<ResourceModel>> getDislikedResources(String userId) async =>
      await _authRepository.getUserDislikedResources(userId);

  Future<List<Map<String, dynamic>>> getSharedResources(String userId) async =>
      await _authRepository.getUserSharedResources(userId);

  Future<List<Map<String, dynamic>>> getReceivedResources(String userId) async =>
      await _authRepository.getUserReceivedResources(userId);

  Future<List<ResourceModel>> getSavedResources(String userId) async =>
      await _authRepository.getUserSavedResources(userId);

  // ✅ Check status
  Future<Map<String, bool>> getResourceStatus(String userId, String resourceQuote) async {
    try {
      final isSaved = await _authRepository.isResourceSaved(userId, resourceQuote);
      final isLiked = await _authRepository.isResourceLiked(userId, resourceQuote);
      final isDisliked = await _authRepository.isResourceDisliked(userId, resourceQuote);
      return {'isSaved': isSaved, 'isLiked': isLiked, 'isDisliked': isDisliked};
    } catch (_) {
      return {'isSaved': false, 'isLiked': false, 'isDisliked': false};
    }
  }

  // ✅ Toggle Like
  Future<String> toggleLikeResource(String userId, ResourceModel resource) async {
    try {
      final isLiked = await _authRepository.isResourceLiked(userId, resource.quote);
      return isLiked
          ? await unlikeResource(userId, resource.quote)
          : await likeResource(userId, resource);
    } catch (e) {
      return 'Failed to toggle like: ${e.toString()}';
    }
  }

  // ✅ Toggle Dislike
  Future<String> toggleDislikeResource(String userId, ResourceModel resource) async {
    try {
      final isDisliked = await _authRepository.isResourceDisliked(userId, resource.quote);
      return isDisliked
          ? await removeDislikeResource(userId, resource.quote)
          : await dislikeResource(userId, resource);
    } catch (e) {
      return 'Failed to toggle dislike: ${e.toString()}';
    }
  }

  // ✅ Toggle Save
  Future<String> toggleSaveResource(String userId, ResourceModel resource) async {
    try {
      final isSaved = await _authRepository.isResourceSaved(userId, resource.quote);
      return isSaved
          ? await removeSavedResource(userId, resource.quote)
          : await saveResource(userId, resource);
    } catch (e) {
      return 'Failed to toggle save: ${e.toString()}';
    }
  }

  // ✅ Clear on logout
  void clearResources() {
    state = [];
  }

  // 🔁 Helper: Update full resource
  void _updateLocalResource(ResourceModel updated) {
    state = state.map((r) => r.quote == updated.quote ? updated : r).toList();
  }

  // 🔁 Helper: Update by quote + custom update logic
  void _updateLocalResourceByQuote(
      String quote,
      ResourceModel Function(ResourceModel) updateFn,
      ) {
    state = state.map((r) => r.quote == quote ? updateFn(r) : r).toList();
  }
}

// ✅ Provider
final resourcesNotifierProvider =
StateNotifierProvider<ResourceNotifier, List<ResourceModel>>((ref) {
  return ResourceNotifier(FirebaseAuthRepository());
});
