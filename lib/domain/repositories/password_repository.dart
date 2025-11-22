import '../entities/password_record.dart';

abstract class PasswordRepository {
  Future<List<PasswordRecord>> getPasswordHistory();
  Future<void> savePassword(PasswordRecord password);
  Future<void> deletePassword(String id);
  Future<void> clearHistory();
  Future<PasswordRecord> createPasswordRecord({
    required String password,
    required int strength,
  });
}