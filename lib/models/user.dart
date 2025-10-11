/// User model for AmritaULABS application
class User {
  final String? id;
  final String name;
  final String email;
  final String role;
  final String? token;
  final bool isBlocked;
  final DateTime? createdAt;

  const User({
    this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.token,
    required this.isBlocked, // ADD THIS LINE
    this.createdAt,
  });

  /// Create User from JSON response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String?,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      token: json['token'] as String?,
      isBlocked: json['isBlocked'] as bool? ?? false, // ADD THIS LINE with a default value
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  /// Convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
      'isBlocked': isBlocked, // ADD THIS LINE
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? token,
    bool? isBlocked, // ADD THIS LINE
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      isBlocked: isBlocked ?? this.isBlocked, // ADD THIS LINE
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, role: $role, isBlocked: $isBlocked}'; // UPDATE THIS LINE
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.isBlocked == isBlocked && // ADD THIS LINE
        other.token == token;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, role, token, isBlocked); // UPDATE THIS LINE
  }
}