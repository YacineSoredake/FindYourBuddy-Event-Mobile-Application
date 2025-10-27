import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:frontend/models/user.dart';

class Event extends Equatable {
  final String id;
  final String title;
  final String category;
  final String? description;
  final EventLocation? location;
  final DateTime date;
  final User? createdBy;
  final List<String>? images;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isInterested;
  final int interestedCount;

  const Event({
    required this.id,
    required this.title,
    required this.category,
    this.description,
    this.location,
    this.images,
    required this.date,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.isInterested = false,
    this.interestedCount = 0,
  });

  /// Convert JSON → Event object
  factory Event.fromJson(Map<String, dynamic> json) {
    dynamic loc = json['location'];

    if (loc is String) {
      try {
        loc = jsonDecode(loc);
      } catch (_) {
        loc = null;
      }
    }

    if (loc is Map<String, dynamic>) {
      loc = EventLocation.fromJson(loc);
    }

    return Event(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'],
      location: loc,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      date: json['date'] != null
          ? DateTime.tryParse(json['date']) ?? DateTime.now()
          : DateTime.now(),
      createdBy: json['createdBy'] != null
          ? User.fromJson(json['createdBy'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      isInterested: json['isInterested'] ?? false,
      interestedCount: json['interestedCount'] ?? 0,
    );
  }

  /// Convert Event object → JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'category': category,
      'description': description,
      'location': location?.toJson(),
      'date': date.toIso8601String(),
      'createdBy': createdBy?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isInterested': isInterested,
      'interestedCount': interestedCount,
    };
  }

  ///  CopyWith for easy updates
  Event copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    EventLocation? location,
    DateTime? date,
    User? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  ///  For easier debugging/logging
  @override
  String toString() {
    return 'Event(id: $id, title: $title, category: $category, '
        'date: $date, location: $location, createdBy: $createdBy)';
  }

  ///  For comparison (used with Equatable)
  @override
  List<Object?> get props => [
    id,
    title,
    category,
    description,
    location,
    date,
    createdBy,
    createdAt,
    updatedAt,
  ];
}

///  Location sub-model
class EventLocation {
  final double? lat;
  final double? lng;
  final String? address;

  const EventLocation({this.lat, this.lng, this.address});

  factory EventLocation.fromJson(Map<String, dynamic> json) {
    return EventLocation(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng, 'address': address};
  }

  @override
  String toString() => 'EventLocation(lat: $lat, lng: $lng, address: $address)';
}
