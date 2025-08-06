import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../provider/resource_model/resource_model.dart';
import '../data/repositories/admin_auth_repository.dart';
import 'admin_model.dart';

// Admin State
class AdminState {
  final AdminModel? admin;
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> resources;
  final Map<String, int> statistics;

  AdminState({
    this.admin,
    this.isLoading = false,
    this.error,
    this.resources = const [],
    this.statistics = const {},
  });

  AdminState copyWith({
    AdminModel? admin,
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? resources,
    Map<String, int>? statistics,
  }) {
    return AdminState(
      admin: admin ?? this.admin,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      resources: resources ?? this.resources,
      statistics: statistics ?? this.statistics,
    );
  }
}

// Admin Notifier
class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _repository;

  AdminNotifier(this._repository) : super(AdminState());

  // Sign In
  Future<String> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final admin = await _repository.adminSignIn(email, password);
      if (admin != null) {
        state = state.copyWith(
          admin: admin,
          isLoading: false,
        );
        await loadDashboardData();
        return 'Sign in successful';
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to sign in',
        );
        return 'Failed to sign in';
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return e.toString();
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _repository.adminSignOut();
      state = AdminState(); // Reset to initial state
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Upload Single Resource
  Future<String> uploadResource(ResourceModel resource) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.uploadResource(resource);
      await loadResources(); // Refresh the resources list
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return e.toString();
    }
  }

  // Upload Multiple Resources
  Future<String> uploadMultipleResources(List<ResourceModel> resources) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.uploadMultipleResources(resources);
      await loadResources(); // Refresh the resources list
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return e.toString();
    }
  }

  // Load All Resources
  Future<void> loadResources() async {
    try {
      final resources = await _repository.getAllResources();
      state = state.copyWith(resources: resources);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Delete Resource
  Future<String> deleteResource(String resourceId) async {
    try {
      final result = await _repository.deleteResource(resourceId);
      await loadResources(); // Refresh the list
      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return e.toString();
    }
  }

  // Update Resource
  Future<String> updateResource(String resourceId, ResourceModel updatedResource) async {
    try {
      final result = await _repository.updateResource(resourceId, updatedResource);
      await loadResources(); // Refresh the list
      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return e.toString();
    }
  }

  // Load Statistics
  Future<void> loadStatistics() async {
    try {
      final statistics = await _repository.getResourceStatistics();
      state = state.copyWith(statistics: statistics);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Search Resources
  Future<void> searchResources(String query) async {
    state = state.copyWith(isLoading: true);

    try {
      final resources = await _repository.searchResources(query);
      state = state.copyWith(
        resources: resources,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load Dashboard Data
  Future<void> loadDashboardData() async {
    await Future.wait([
      loadResources(),
      loadStatistics(),
    ]);
  }

  // Clear Error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Check Admin Status
  Future<bool> checkAdminStatus() async {
    try {
      return await _repository.isCurrentUserAdmin();
    } catch (e) {
      return false;
    }
  }

  // Get Current Admin
  Future<void> getCurrentAdmin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final admin = await _repository.getAdminDetails(user.uid);
        if (admin != null) {
          state = state.copyWith(admin: admin);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Admin Auth Stream Provider
final adminAuthStreamProvider = StreamProvider<User?>((ref) {
  return AdminRepository().authStateChanges;
});

// Admin Provider
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(AdminRepository());
});

// Helper providers for specific state pieces
final adminResourcesProvider = Provider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminProvider).resources;
});

final adminStatisticsProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(adminProvider).statistics;
});

final isAdminLoadingProvider = Provider<bool>((ref) {
  return ref.watch(adminProvider).isLoading;
});

final adminErrorProvider = Provider<String?>((ref) {
  return ref.watch(adminProvider).error;
});

final currentAdminProvider = Provider<AdminModel?>((ref) {
  return ref.watch(adminProvider).admin;
});