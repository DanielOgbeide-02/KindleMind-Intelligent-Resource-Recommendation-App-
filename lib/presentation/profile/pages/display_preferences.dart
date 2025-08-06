import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/helper/snackbar.dart';
import '../../../config/theme/app_theme.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/resource_model/user_notifier_provider.dart';


class PreferencesPage extends ConsumerStatefulWidget {
  const PreferencesPage({super.key});

  @override
  ConsumerState<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends ConsumerState<PreferencesPage> {
  String selectedGender = '';
  String selectedAgeGroup = '';
  String selectedRecoveryStage = '';
  List<String> selectedResourceTypes = [];

  bool isEditing = false;
  bool isLoading = false;
  bool isPressed = false;

  // Age group options
  final List<String> ageGroupOptions = [
    '18-24',
    '25-34',
    '35-44',
    '45-54',
    '55+'
  ];

  // Gender options
  final List<String> genderOptions = [
    'Male',
    'Female'
  ];

  // Recovery stage options
  final List<String> recoveryStageOptions = [
    'Early',
    'Mid',
    'Late'
  ];

  // Resource type options
  final List<String> resourceTypeOptions = [
    'Motivational Messages',
    'Coping Strategies',
    'Articles'
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final user = ref.read(userNotifierProvider);

    if (user != null) {
      // Only set values if they exist in our predefined options
      selectedAgeGroup = ageGroupOptions.contains(user.age) ? (user.age ?? '') : '';
      selectedGender = genderOptions.contains(user.gender) ? (user.gender ?? '') : '';
      selectedRecoveryStage = recoveryStageOptions.contains(user.recoveryStage) ? (user.recoveryStage ?? '') : '';

      // Filter resource types to only include valid options
      final userResourceTypes = user.preferredResourceTypes ?? [];
      selectedResourceTypes = userResourceTypes.where((type) => resourceTypeOptions.contains(type)).toList();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
    required bool isEnabled,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.arrow_drop_down, color: AppTheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value.isEmpty || !options.contains(value) ? null : value,
                    hint: Text('Select $label'),
                    isExpanded: true,
                    onChanged: isEnabled ? onChanged : null,
                    items: options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> selectedValues,
    required List<String> options,
    required Function(List<String>) onChanged,
    required bool isEnabled,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list, color: AppTheme.primary),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (selectedValues.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selectedValues.map((value) {
                return Chip(
                  label: Text(value, style: const TextStyle(fontSize: 12)),
                  deleteIcon: isEnabled ? const Icon(Icons.close, size: 16) : null,
                  onDeleted: isEnabled ? () {
                    final newList = List<String>.from(selectedValues);
                    newList.remove(value);
                    onChanged(newList);
                  } : null,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                );
              }).toList(),
            ),
          if (isEnabled)
            TextButton(
              onPressed: () => _showMultiSelectDialog(
                title: 'Select $label',
                options: options,
                selectedValues: selectedValues,
                onChanged: onChanged,
              ),
              child: Text('+ Add $label'),
            ),
        ],
      ),
    );
  }

  void _showMultiSelectDialog({
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required Function(List<String>) onChanged,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> tempSelected = List<String>.from(selectedValues);

        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      return CheckboxListTile(
                        title: Text(option),
                        value: tempSelected.contains(option),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              tempSelected.add(option);
                            } else {
                              tempSelected.remove(option);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      onChanged(tempSelected);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Done'),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferences'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 25),
                children: [
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Personal Preferences',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Row(
                            children: [
                              Icon(Icons.edit, color: AppTheme.primary),
                              const SizedBox(width: 5),
                              GestureDetector(
                                onTap: () async {
                                  // First, toggle the editing state
                                  setState(() {
                                    isEditing = !isEditing;
                                  });

                                  if (isEditing) {
                                    return; // Exit early to allow the UI to update
                                  }

                                  setState(() {
                                    isLoading = true;
                                    isPressed = true;
                                  });

                                  final authController = ref.read(authControllerProvider.notifier);
                                  final userData = ref.watch(userNotifierProvider);

                                  if (userData == null) return;

                                  // Check for changes
                                  bool hasChanges =
                                      selectedAgeGroup != (userData.age ?? '') ||
                                          selectedGender != (userData.gender ?? '') ||
                                          selectedRecoveryStage != (userData.recoveryStage ?? '') ||
                                          !_listEquals(selectedResourceTypes, userData.preferredResourceTypes ?? []);

                                  if (!hasChanges) {
                                    setState(() {
                                      isLoading = false;
                                      isPressed = false;
                                    });
                                    showTopSnackBar(
                                      context: context,
                                      title: 'message:',
                                      message: 'No changes detected',
                                    );
                                    return;
                                  }

                                  final errorMessage = await authController.updateUserProfile(
                                    name: userData.name,
                                    username: userData.username,
                                    email: userData.email,
                                    savedResources: userData.savedResources,
                                    likedResources: userData.likedResources,
                                    dislikedResources: userData.dislikedResources,
                                    sharedResources: userData.sharedResources,
                                    age: selectedAgeGroup,
                                    gender: selectedGender,
                                    recoveryStage: selectedRecoveryStage,
                                    preferredResourceTypes: selectedResourceTypes,
                                  );

                                  setState(() {
                                    isLoading = false;
                                    isPressed = false;
                                    isEditing = false;
                                  });

                                  if (errorMessage == null) {
                                    showTopSnackBar(
                                      context: context,
                                      title: 'message: ',
                                      message: 'Preferences updated successfully',
                                    );
                                  } else {
                                    showTopSnackBar(
                                      context: context,
                                      title: 'error: ',
                                      message: errorMessage,
                                    );
                                  }
                                },
                                child: isLoading
                                    ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primary,
                                  ),
                                )
                                    : Text(isEditing ? 'Save Changes' : 'Edit'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          _buildDropdownField(
                            label: 'Age Group',
                            value: selectedAgeGroup,
                            options: ageGroupOptions,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedAgeGroup = newValue ?? '';
                              });
                            },
                            isEnabled: isEditing,
                          ),
                          _buildDropdownField(
                            label: 'Gender',
                            value: selectedGender,
                            options: genderOptions,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedGender = newValue ?? '';
                              });
                            },
                            isEnabled: isEditing,
                          ),
                          _buildDropdownField(
                            label: 'Recovery Stage',
                            value: selectedRecoveryStage,
                            options: recoveryStageOptions,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedRecoveryStage = newValue ?? '';
                              });
                            },
                            isEnabled: isEditing,
                          ),
                          _buildMultiSelectField(
                            label: 'Preferred Resource Types',
                            selectedValues: selectedResourceTypes,
                            options: resourceTypeOptions,
                            onChanged: (List<String> newValues) {
                              setState(() {
                                selectedResourceTypes = newValues;
                              });
                            },
                            isEnabled: isEditing,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  if (!isEditing)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Preferences Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildSummaryItem('Age', selectedAgeGroup.isEmpty ? 'Not set' : selectedAgeGroup),
                        _buildSummaryItem('Gender', selectedGender.isEmpty ? 'Not set' : selectedGender),
                        _buildSummaryItem('Recovery Stage', selectedRecoveryStage.isEmpty ? 'Not set' : selectedRecoveryStage),
                        _buildSummaryItem(
                            'Preferred Resources',
                            selectedResourceTypes.isEmpty
                                ? 'None selected'
                                : selectedResourceTypes.join(', ')
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: value.contains('Not set') || value.contains('None selected')
                    ? Colors.grey.shade600
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _listEquals(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (!list2.contains(list1[i])) return false;
    }
    return true;
  }
}