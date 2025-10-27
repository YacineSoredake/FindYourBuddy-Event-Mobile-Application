import 'user.dart';

class Buddy {
  final String id;
  final String event;
  final List<User> users;

  Buddy({
    required this.id,
    required this.event,
    required this.users,
  });

  factory Buddy.fromJson(Map<String, dynamic> json) {
    return Buddy(
      id: json['_id'] ?? '',
      event: json['event'] ?? '',
      users: (json['users'] as List)
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList(),
    );
  }

  // 👇 Helper to get the "other" user in the pair
  User? getMatchedUser(String? currentUserId) {
    return users.firstWhere(
      (u) => u.id != currentUserId,
      orElse: () => users.first,
    );
  }
}
