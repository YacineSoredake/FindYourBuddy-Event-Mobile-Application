class Message {
  final String id;
  final String buddyId;
  final String senderId;
  final String text;
  final bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.buddyId,
    required this.senderId,
    required this.text,
    this.read = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert JSON → Dart
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      buddyId: json['buddyId'] ?? '',
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Convert Dart → JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'buddyId': buddyId,
      'senderId': senderId,
      'text': text,
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
