import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final DateTime joinedAt;
  final String address;
  final String imageUrl;
  final String shippingAddress;

  UserModel({
    required this.address,
    required this.imageUrl,
    required this.shippingAddress,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.joinedAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      profileImage: data['profileImage'] ?? '',
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
      address: data['address'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      shippingAddress: data['shippingAddress'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'profileImage': profileImage,
    'joinedAt': joinedAt,
    'address': address,
    'imageUrl': imageUrl,
    'shippingAddress': shippingAddress,
  };
}
