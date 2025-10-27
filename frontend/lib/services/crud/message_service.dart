import 'package:dio/dio.dart';
import 'package:frontend/core/api.dart';

class MessageService {
  final String baseUrl;

  MessageService(this.baseUrl);

  Future<List<Map<String, dynamic>>> getChatMessages({required String buddyId}) async {
    try {
      final Response response = await Api.dio.get('/messages/$buddyId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List messages = response.data['messages'];

        return messages.map((m) {
          return {
            '_id': m['_id'],
            'senderId': m['senderId'] is Map
                ? m['senderId']['_id']
                : m['senderId'],
            'text': m['text'],
            'createdAt': m['createdAt'],
          };
        }).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }
}
