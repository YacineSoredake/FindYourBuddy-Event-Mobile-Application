class CloudUser {
  final String uid;
  final String email;

  CloudUser({required this.uid, required this.email});

  @override
  String toString() => 'Cloud user : $email (ID:$uid)';
}
