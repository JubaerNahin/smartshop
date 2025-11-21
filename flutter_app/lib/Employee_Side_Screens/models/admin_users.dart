class AdminUser {
  final String uid;
  final String email;
  final String name;
  final bool isAdmin;

  AdminUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.isAdmin,
  });

  factory AdminUser.fromMap(String uid, Map<String, dynamic> map) {
    return AdminUser(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      isAdmin: map['isAdmin'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'name': name, 'isAdmin': isAdmin};
  }
}
