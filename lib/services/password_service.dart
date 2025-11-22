import '../models/password_record.dart';

class PasswordService {
  static final PasswordService _instance = PasswordService._internal();
  factory PasswordService() => _instance;
  PasswordService._internal();

  final List<PasswordRecord> _passwordHistory = [];

  List<PasswordRecord> get passwordHistory => List.unmodifiable(_passwordHistory);

  void addPassword(String password) {
    final record = PasswordRecord(
      password: password,
      createdAt: DateTime.now(),
    );
    _passwordHistory.insert(0, record); // Добавляем в начало
  }

  void deletePassword(int index) {
    if (index >= 0 && index < _passwordHistory.length) {
      _passwordHistory.removeAt(index);
    }
  }

  void clearHistory() {
    _passwordHistory.clear();
  }

  List<PasswordRecord> searchPasswords(String query) {
    if (query.isEmpty) return _passwordHistory;
    return _passwordHistory
        .where((record) => record.password.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}