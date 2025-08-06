import 'package:recommender_nk/provider/resource_model/resource_model.dart';

class UserModel {
  final String uid;
  final String username;
  final String name;
  final String email;
  final int? dailyStreaks;
  final List<ResourceModel> savedResources;
  final List<ResourceModel> likedResources;
  final List<ResourceModel> dislikedResources;
  final List<ResourceModel> sharedResources;
  // Preference fields
  final String? age;
  final String? gender;
  final String? recoveryStage;
  final List<String> preferredResourceTypes;

  UserModel({
    required this.uid,
    required this.username,
    required this.name,
    required this.email,
    required this.savedResources,
    required this.likedResources,
    required this.dislikedResources,
    required this.sharedResources,
    this.dailyStreaks,
    this.age,
    this.gender,
    this.recoveryStage,
    this.preferredResourceTypes = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      username: data['username'],
      name: data['name'],
      email: data['email'],
      savedResources: (data['savedResources'] as List<dynamic>?)
          ?.map((e) => ResourceModel.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      likedResources: (data['likedResources'] as List<dynamic>?)
          ?.map((e) => ResourceModel.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      dislikedResources: (data['dislikedResources'] as List<dynamic>?)
          ?.map((e) => ResourceModel.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      sharedResources: (data['sharedResources'] as List<dynamic>?)
          ?.map((e) => ResourceModel.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      dailyStreaks: data['dailyStreaks'],
      age: data['age'],
      gender: data['gender'],
      recoveryStage: data['recoveryStage'],
      preferredResourceTypes: (data['preferredResourceTypes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'name': name,
      'email': email,
      'savedResources': savedResources.map((e) => e.toMap()).toList(),
      'likedResources': likedResources.map((e) => e.toMap()).toList(),
      'dislikedResources': dislikedResources.map((e) => e.toMap()).toList(),
      'sharedResources': sharedResources.map((e) => e.toMap()).toList(),
      'dailyStreaks': dailyStreaks,
      'age': age,
      'gender': gender,
      'recoveryStage': recoveryStage,
      'preferredResourceTypes': preferredResourceTypes,
    };
  }

  // Helper method to create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? username,
    String? name,
    String? email,
    List<ResourceModel>? savedResources,
    List<ResourceModel>? likedResources,
    List<ResourceModel>? dislikedResources,
    List<ResourceModel>? sharedResources,
    int? dailyStreaks,
    String? age,
    String? gender,
    String? recoveryStage,
    List<String>? preferredResourceTypes,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      savedResources: savedResources ?? this.savedResources,
      likedResources: likedResources ?? this.likedResources,
      dislikedResources: dislikedResources ?? this.dislikedResources,
      sharedResources: sharedResources ?? this.sharedResources,
      dailyStreaks: dailyStreaks ?? this.dailyStreaks,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      recoveryStage: recoveryStage ?? this.recoveryStage,
      preferredResourceTypes: preferredResourceTypes ?? this.preferredResourceTypes,
    );
  }
}