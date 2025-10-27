import 'package:frontend/exceptions/swipe_exception.dart';
import 'package:frontend/models/buddy.dart';

import '../../core/api.dart';

class SwipeService {
  static Future<String?> handleSwipe({
    required String eventId,
    required String targetId,
    required bool liked,
  }) async {
    try {
      final response = await Api.dio.post(
        '/swipes',
        data: {'eventId': eventId, 'targetId': targetId, 'liked': liked},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          return data['status'];
        }
      }
      return null;
    } catch (e) {
      print('Swipe error: $e');
      return null;
    }
  }

  static Future<List<Buddy>> fetchMatchedBuddies() async {
    try {
      final response = await Api.dio.get('/swipes/matches');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final buddiesJson = response.data['buddies'] as List<dynamic>;
        return buddiesJson
            .map((json) => Buddy.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw SwipeException('Failed to fetch matched buddies');
      }
    } catch (e) {
      throw SwipeException('Error fetching matched buddies: $e');
    }
  }
}
