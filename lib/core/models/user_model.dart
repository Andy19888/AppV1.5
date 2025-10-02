import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { repositor, supervisor, admin }

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;
  final List<String> authorizedSucursales;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    this.isActive = true,
    this.authorizedSucursales = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.repositor,
      ),
      createdAt: _parseDate(json['createdAt']),
      isActive: json['isActive'] as bool? ?? true,
      authorizedSucursales: (json['authorizedSucursales'] != null)
          ? List<String>.from(json['authorizedSucursales'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'authorizedSucursales': authorizedSucursales,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
    List<String>? authorizedSucursales,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      authorizedSucursales: authorizedSucursales ?? this.authorizedSucursales,
    );
  }

  // 🔽 Helper universal para fechas (acepta Firestore Timestamp, String o DateTime)
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is Timestamp) return value.toDate();
    throw Exception('Formato de fecha no soportado: $value');
  }
}
