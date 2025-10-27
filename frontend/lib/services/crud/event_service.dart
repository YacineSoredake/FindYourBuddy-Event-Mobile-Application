import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/exceptions/event_exception.dart';
import 'package:frontend/models/user.dart';

import '../../core/api.dart';
import '../../models/event.dart';

class EventService {
  static Future<List<Event>> fetchEvents({
    String? category,
    String? location,
    String? creator,
    String? date,
    double? lat,
    double? lng,
  }) async {
    try {
      final response = await Api.dio.get(
        '/events',
        queryParameters: {
          if (category != null) 'category': category,
          if (creator != null) 'createdBy.name': creator,
          if (location != null) 'location': location,
          if (date != null) 'date': date,
          if (lat != null) 'lat': lat.toString(),
          if (lng != null) 'lng': lng.toString(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> eventList = response.data['events'];
        return eventList.map((e) => Event.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print('❌ Fetch Events Error: $e');
      rethrow;
    }
  }

  static Future<bool> createEvent({
    required String title,
    required String category,
    required String description,
    required String date,
    required Map<String, dynamic> location,
    List<File>? images,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'category': category,
        'description': description,
        'date': date,
        'location': jsonEncode(location),
        if (images != null && images.isNotEmpty)
          'images': [
            for (final file in images)
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
          ],
      });

      final response = await Api.dio.post(
        '/events',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return true;
      } else {
        throw Exception('Failed to create event');
      }
    } catch (e) {
      print('Create Event Error: $e');
      rethrow;
    }
  }

  static Future<bool> markInterest({required String eventId}) async {
    try {
      final response = await Api.dio.post(
        '/events/interest',
        data: {'event_id': eventId},
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return true;
      } else {
        throw MarkInterestException();
      }
    } catch (e) {
      debugPrint('❌ Mark Interest Error: $e');
      rethrow;
    }
  }

  static Future<bool> unmarkInterest({required String eventId}) async {
    try {
      final response = await Api.dio.delete(
        '/events/interest',
        data: {'event_id': eventId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      } else {
        throw UnmarkInterestException();
      }
    } catch (e) {
      debugPrint('❌ Unmark Interest Error: $e');
      rethrow;
    }
  }

  static Future<List<User>> exploreBuddies() async {
    try {
      final response = await Api.dio.get('/events/explore');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final body = response.data;
        final List<dynamic> data = body['data'];
        final List<User> users = data.map((e) => User.fromJson(e)).toList();
        return users;
      } else {
        throw Exception('Failed to fetch explore buddies');
      }
    } catch (e) {
      log('❌ exploreBuddies error: $e');
      rethrow;
    }
  }
}
