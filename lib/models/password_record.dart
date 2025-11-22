class PasswordRecord {
  final String password;
  final DateTime createdAt;

  PasswordRecord({
    required this.password,
    required this.createdAt,
  });

  String get formattedDate {
    return '${createdAt.day}.${createdAt.month}.${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}