class SharedEvent {
  final String eventId;
  final String title;
  final String category;
  final DateTime date;

  SharedEvent({
    required this.eventId,
    required this.title,
    required this.category,
    required this.date,
  });

  factory SharedEvent.fromJson(Map<String, dynamic> json) {
    return SharedEvent(
      eventId: json['eventId'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'title': title,
      'category': category,
      'date': date.toIso8601String(),
    };
  }
}

class User {
  final String? id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio;
  final List<String>? fields;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  //  New fields for explore endpoint
  final List<SharedEvent>? sharedEvents;
  final int? sharedEventCount;

  User({
    this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.bio,
    this.fields = const [],
    this.createdAt,
    this.updatedAt,
    this.sharedEvents,
    this.sharedEventCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      bio: json['bio'],
      fields:
          (json['interests'] ?? json['fields']) != null &&
              (json['interests'] ?? json['fields']) is List
          ? List<String>.from(json['interests'] ?? json['fields'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,

      // 🆕 Parse the new explore fields
      sharedEvents: json['sharedEvents'] != null
          ? (json['sharedEvents'] as List)
                .map((e) => SharedEvent.fromJson(e))
                .toList()
          : null,
      sharedEventCount: json['sharedEventCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'bio':bio,
      'fields': fields,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'sharedEvents': sharedEvents?.map((e) => e.toJson()).toList(),
      'sharedEventCount': sharedEventCount,
    };
  }

}
