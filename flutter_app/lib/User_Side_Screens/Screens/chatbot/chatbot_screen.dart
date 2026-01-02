import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter_app/User_Side_Screens/controllers/chat_controller.dart';
import 'package:flutter_app/utils/app_colors.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatController chatController = Get.put(ChatController());
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        title: const Text(
          'SmartShop Assistant 💬',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appbar,
      ),
      body: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        child: Container(
          color: AppColors.primarycolor,
          child: Column(
            children: [
              Expanded(child: _ChatMessages(chatController: chatController)),
              _ChatInput(
                controller: textController,
                onSend: (text) {
                  chatController.sendMessage(text);
                  textController.clear();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Displays list of chat messages
class _ChatMessages extends StatelessWidget {
  final ChatController chatController;

  const _ChatMessages({required this.chatController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final messages = chatController.messages;
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        reverse: true, // newest messages at bottom
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[messages.length - 1 - index]; // reverse order
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: BubbleSpecialThree(
              text: msg.message,
              color:
                  msg.isUser ? Colors.deepPurpleAccent : Colors.grey.shade300,
              tail: true,
              textStyle: TextStyle(
                color: msg.isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
              isSender: msg.isUser,
            ),
          );
        },
      );
    });
  }
}

/// Chat input bar
class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: AppColors.navbar,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Ask something...",
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.buttoncolors),
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) onSend(text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
