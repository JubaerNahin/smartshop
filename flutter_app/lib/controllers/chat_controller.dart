import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/models/chat.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<ChatMessage> messages = <ChatMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    _listenToMessages();
  }

  void _listenToMessages() {
    _firestore
        .collection('chats')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
          messages.value =
              snapshot.docs
                  .map((doc) => ChatMessage.fromMap(doc.data()))
                  .toList();
        });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      message: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    await _firestore.collection('chats').add(userMsg.toMap());

    // Simulate SmartShop AI reply
    Future.delayed(const Duration(seconds: 1), () async {
      final aiResponse = ChatMessage(
        message: generateSmartShopResponse(text),
        isUser: false,
        timestamp: DateTime.now(),
      );
      await _firestore.collection('chats').add(aiResponse.toMap());
    });
  }

  String generateSmartShopResponse(String userText) {
    final text = userText.toLowerCase();
    if (text.contains('t-shirt')) {
      return 'We have trendy SmartShop T-shirts starting at \$15!';
    } else if (text.contains('discount')) {
      return 'Good news! 🎉 SmartShop is offering 20% off this week!';
    } else if (text.contains('hello') || text.contains('hi')) {
      return 'Hello 👋! Welcome to SmartShop — your personal shopping assistant!';
    } else if (text.contains('shoes')) {
      return 'We’ve got stylish shoes in all sizes and colors. Want to see them? 👟';
    } else {
      return 'I’m not sure, but I’ll help you find it on SmartShop!';
    }
  }
}
