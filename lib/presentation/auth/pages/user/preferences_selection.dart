import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recommender_nk/config/theme/app_theme.dart';
import 'package:recommender_nk/presentation/auth/widgets/buttons/app_btn.dart';
import 'package:recommender_nk/provider/auth_provider.dart';
import 'package:recommender_nk/provider/resource_model/user_notifier_provider.dart';
import 'package:recommender_nk/config/helper/snackbar.dart';

class UserPreferencesPage extends ConsumerStatefulWidget {
  const UserPreferencesPage({super.key});

  @override
  ConsumerState<UserPreferencesPage> createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends ConsumerState<UserPreferencesPage> {
  String? selectedAge;
  String? selectedGender;
  String? selectedRecoveryStage;
  List<String> selectedResourceTypes = [];
  bool isLoading = false;

  final List<String> ageGroups = ['18-24', '25-34', '35-44', '45-54', '55+'];
  final List<String> genders = ['Male', 'Female'];
  final List<String> recoveryStages = ['Early', 'Mid', 'Late'];
  final List<String> resourceTypes = ['Motivational Messages', 'Coping Strategies', 'Articles'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppTheme.primary,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Column(
                  children: [
                    Text(
                      'Tell us about yourself',
                      style: TextStyle(
                        fontSize: 28,
                        color: AppTheme.surface,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This helps us personalize your experience',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.surface.withOpacity(0.8),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                // Age Selection
                _buildSectionTitle('Age Group'),
                const SizedBox(height: 15),
                _buildSelectionGrid(
                  items: ageGroups,
                  selectedItem: selectedAge,
                  onItemSelected: (age) => setState(() => selectedAge = age),
                ),
                const SizedBox(height: 30),

                // Gender Selection
                _buildSectionTitle('Gender'),
                const SizedBox(height: 15),
                _buildSelectionGrid(
                  items: genders,
                  selectedItem: selectedGender,
                  onItemSelected: (gender) => setState(() => selectedGender = gender),
                ),
                const SizedBox(height: 30),

                // Recovery Stage Selection
                _buildSectionTitle('Recovery Stage'),
                const SizedBox(height: 15),
                _buildSelectionGrid(
                  items: recoveryStages,
                  selectedItem: selectedRecoveryStage,
                  onItemSelected: (stage) => setState(() => selectedRecoveryStage = stage),
                ),
                const SizedBox(height: 30),

                // Preferred Resource Types (Multiple Selection)
                _buildSectionTitle('Preferred Resource Types'),
                Text(
                  'You can select multiple options',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.surface.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 15),
                _buildMultiSelectionGrid(
                  items: resourceTypes,
                  selectedItems: selectedResourceTypes,
                  onItemToggled: (resourceType) {
                    setState(() {
                      if (selectedResourceTypes.contains(resourceType)) {
                        selectedResourceTypes.remove(resourceType);
                      } else {
                        selectedResourceTypes.add(resourceType);
                      }
                    });
                  },
                ),
                const SizedBox(height: 50),

                // Continue Button
                basic_app_btn(
                  isLoading: isLoading,
                  isPressed: false,
                  buttonText: 'Complete Preferences',
                  onPressed: _savePreferences,
                ),
                const SizedBox(height: 20),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        color: AppTheme.surface,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSelectionGrid({
    required List<String> items,
    required String? selectedItem,
    required Function(String) onItemSelected,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        final isSelected = selectedItem == item;
        return GestureDetector(
          onTap: () => onItemSelected(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.surface : Colors.transparent,
              border: Border.all(
                color: AppTheme.surface,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              item,
              style: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.surface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectionGrid({
    required List<String> items,
    required List<String> selectedItems,
    required Function(String) onItemToggled,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        final isSelected = selectedItems.contains(item);
        return GestureDetector(
          onTap: () => onItemToggled(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.surface : Colors.transparent,
              border: Border.all(
                color: AppTheme.surface,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primary : AppTheme.surface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _savePreferences() async {
    // Validate that at least some preferences are selected
    if (selectedAge == null ||
        selectedGender == null ||
        selectedRecoveryStage == null ||
        selectedResourceTypes.isEmpty) {
      showTopSnackBar(
        context: context,
        title: 'Please complete all fields',
        message: 'Select your preferences to continue',
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final authController = ref.read(authControllerProvider.notifier);
      final userNotifier = ref.read(userNotifierProvider.notifier);

      // Get current user details
      final currentUser = await authController.getUserDetails();
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Update user with preferences
      final updatedUser = currentUser.copyWith(
        age: selectedAge,
        gender: selectedGender,
        recoveryStage: selectedRecoveryStage,
        preferredResourceTypes: selectedResourceTypes,
      );

      // Save to Firebase and update local state
      final result = await authController.updateUserProfile(
        name: updatedUser.name,
        email: updatedUser.email,
        username: updatedUser.username,
        savedResources: updatedUser.savedResources,
        likedResources: updatedUser.likedResources,
        dislikedResources: updatedUser.dislikedResources,
        sharedResources: updatedUser.sharedResources,
        age: updatedUser.age,
        gender: updatedUser.gender,
        recoveryStage: updatedUser.recoveryStage,
        preferredResourceTypes: updatedUser.preferredResourceTypes,
        dailyStreaks: updatedUser.dailyStreaks, // Pass dailyStreaks to repository
      );

      if (result == null) {
        // Update local user state with preferences
        userNotifier.updateUser(updatedUser);

        showTopSnackBar(
          context: context,
          title: 'Success!',
          message: 'Your preferences have been saved',
        );

        // Navigate to dashboard
        context.go('/dashboard');
      } else {
        throw Exception(result);
      }
    } catch (e) {
      showTopSnackBar(
        context: context,
        title: 'Error',
        message: 'Failed to save preferences: ${e.toString()}',
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}