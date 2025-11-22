class PasswordRecord {
  final String id;
  final String password;
  final DateTime createdAt;
  final int strength; // 0-100

  PasswordRecord({
    required this.id,
    required this.password,
    required this.createdAt,
    required this.strength,
  });

  String get formattedDate {
    return '${createdAt.day}.${createdAt.month}.${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'strength': strength,
    };
  }

  factory PasswordRecord.fromJson(Map<String, dynamic> json) {
    return PasswordRecord(
      id: json['id'],
      password: json['password'],
      createdAt: DateTime.parse(json['createdAt']),
      strength: json['strength'],
    );
  }
}