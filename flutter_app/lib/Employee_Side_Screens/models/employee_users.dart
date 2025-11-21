import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  EmployeeUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'createdAt': Timestamp.fromDate(
        createdAt,
      ), // store as Firestore timestamp
    };
  }

  factory EmployeeUser.fromMap(String id, Map<String, dynamic> map) {
    return EmployeeUser(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'employee',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
