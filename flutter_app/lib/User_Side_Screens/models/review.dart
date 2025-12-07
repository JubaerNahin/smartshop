import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String productId;
  final String userId;
  final double rating;
  final String comment;
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> data) =>
      ReviewModel(
        id: id,
        productId: data['productId'],
        userId: data['userId'],
        rating: (data['rating'] as num).toDouble(),
        comment: data['comment'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'userId': userId,
    'rating': rating,
    'comment': comment,
    'timestamp': timestamp,
  };
}
