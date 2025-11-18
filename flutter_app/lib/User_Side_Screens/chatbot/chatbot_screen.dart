import 'package:flutter/material.dart';
import 'package:flutter_app/controllers/chat_controller.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'package:get/get.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.put(ChatController());
  final TextEditingController textController = TextEditingController();

  int _selectedIndex = 2; // Chat tab index

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Get.offNamed('/home');
        break;
      case 1:
        Get.offNamed('/cart');
        break;
      case 2:
        Get.offNamed('/chatbot');
        break;
      case 3:
        Get.offNamed('/account');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbar,
      appBar: AppBar(
        title: const Text(
          'SmartShop Assistant 💬',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appbar,
      ),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: Container(
          color: AppColors.primarycolor,
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  final messages = chatController.messages;
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return BubbleSpecialThree(
                        text: msg.message,
                        color:
                            msg.isUser
                                ? Colors.deepPurpleAccent
                                : Colors.grey.shade300,
                        tail: true,
                        textStyle: TextStyle(
                          color: msg.isUser ? Colors.white : Colors.black87,
                          fontSize: 16,
                        ),
                        isSender: msg.isUser,
                      );
                    },
                  );
                }),
              ),
              // const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    color: AppColors.navbar,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            decoration: const InputDecoration(
                              hintText: "Ask something...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            chatController.sendMessage(textController.text);
                            textController.clear();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
