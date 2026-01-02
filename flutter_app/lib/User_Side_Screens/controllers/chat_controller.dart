import 'dart:convert';
import 'package:flutter_app/User_Side_Screens/models/chat.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  // Reactive list of messages
  var messages = <ChatMessage>[].obs;

  // Backend URL (update for emulator/device as needed)
  final String backendUrl = "http://10.0.2.2:8000/chat";

  /// Sends a message from the user to the backend and receives a reply
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message with timestamp
    final userMessage = ChatMessage(
      message: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    messages.add(userMessage);

    try {
      // Send request to backend
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final replyText =
            data["reply"]?.toString() ?? "No response from server.";

        // Add bot reply with timestamp
        messages.add(
          ChatMessage(
            message: replyText,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      } else {
        // Handle server errors
        messages.add(
          ChatMessage(
            message: "Server error: ${response.statusCode}",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      // Handle network/connection errors
      messages.add(
        ChatMessage(
          message: "Connection error: $e",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  /// Optional: Clears all messages
  void clearMessages() => messages.clear();
}
