import 'package:cloud_firestore/cloud_firestore.dart';

class ChatQueryModel {
  final String id;
  final String userId;
  final String message;
  final String response;
  final DateTime timestamp;

  ChatQueryModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.response,
    required this.timestamp,
  });

  factory ChatQueryModel.fromMap(String id, Map<String, dynamic> data) =>
      ChatQueryModel(
        id: id,
        userId: data['userId'],
        message: data['message'],
        response: data['response'],
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'message': message,
    'response': response,
    'timestamp': timestamp,
  };
}
