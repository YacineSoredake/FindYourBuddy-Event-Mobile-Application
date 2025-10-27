import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/services/crud/message_service.dart';
import 'package:frontend/services/socket_service.dart';

class ChatProvider extends ChangeNotifier {
  final String userId;
  final String buddyId;

  final SocketService _socketService = SocketService();
  final MessageService _messageService = MessageService(ApiConstants.baseUrl);

  bool loading = true;
  final List<Map<String, dynamic>> messages = [];
  bool _initialized = false; // prevent re-initialization

  ChatProvider({
    required this.userId,
    required this.buddyId,
  });

  /// Initialize the chat (only once per instance)
  Future<void> initChat() async {
    if (_initialized) return; // 🧠 Prevent multiple calls
    _initialized = true;

    try {
      // Load previous messages
      final oldMessages =
          await _messageService.getChatMessages(buddyId: buddyId);
      messages.addAll(oldMessages);

      // Connect to socket
      _socketService.connect(userId);
      _socketService.joinBuddyChat(buddyId);

      // Listen for incoming messages
      _socketService.onMessageReceived((data) {
        if (data['buddyId'] == buddyId && data['senderId'] != userId) {
          messages.add({
            '_id': data['_id'],
            'senderId': data['senderId'],
            'text': data['text'],
            'createdAt': data['createdAt'],
          });
          notifyListeners();
        }
      });

      loading = false;
      notifyListeners();
    } catch (e) {
      print("❌ Chat init error: $e");
      loading = false;
      notifyListeners();
    }
  }

  /// Send a message
  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _socketService.sendMessage(buddyId, userId, trimmed);

    messages.add({
      'senderId': userId,
      'text': trimmed,
      'createdAt': DateTime.now().toIso8601String(),
    });

    notifyListeners();
  }

  /// Clean up resources
  void disposeChat() {
    _socketService.disconnect();
  }

  @override
  void dispose() {
    disposeChat();
    super.dispose();
  }
}
