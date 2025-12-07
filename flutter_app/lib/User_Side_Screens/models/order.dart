import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/User_Side_Screens/models/cart.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double total;
  final String status;
  final DateTime orderedAt;
  final String shippingAddress;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.orderedAt,
    required this.shippingAddress,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) =>
      OrderModel(
        id: id,
        userId: data['userId'],
        items:
            (data['items'] as List)
                .map((item) => CartItemModel.fromMap(item['id'], item))
                .toList(),
        total: (data['total'] as num).toDouble(),
        status: data['status'],
        orderedAt: (data['orderedAt'] as Timestamp).toDate(),
        shippingAddress: data['shippingAddress'],
      );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'items': items.map((e) => e.toMap()).toList(),
    'total': total,
    'status': status,
    'orderedAt': orderedAt,
    'shippingAddress': shippingAddress,
  };
}
