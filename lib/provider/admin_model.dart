class AdminModel {
  final String uid;
  final String email;
  final String name;
  final String role;

  AdminModel({
    required this.uid,
    required this.email,
    required this.name,
    this.role = 'admin',
  });

  factory AdminModel.fromMap(Map<String, dynamic> data) {
    return AdminModel(
      uid: data['uid']?.toString() ?? '', // Handle null values
      email: data['email']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      role: data['role']?.toString() ?? 'admin',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
    };
  }

  AdminModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
  }) {
    return AdminModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }
}