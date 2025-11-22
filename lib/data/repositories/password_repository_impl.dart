import 'package:uuid/uuid.dart';
import '../../domain/entities/password_record.dart';
import '../../domain/repositories/password_repository.dart';
import '../services/local_storage_service.dart';
import '../services/security_api_service.dart';

class PasswordRepositoryImpl implements PasswordRepository {
  final LocalStorageService _localStorageService;
  final SecurityApiService _securityApiService;
  final Uuid _uuid = const Uuid();

  PasswordRepositoryImpl({
    required LocalStorageService localStorageService,
    required SecurityApiService securityApiService,
  })  : _localStorageService = localStorageService,
        _securityApiService = securityApiService;

  @override
  Future<List<PasswordRecord>> getPasswordHistory() async {
    final passwords = await _localStorageService.getPasswords();
    return passwords.map((json) => PasswordRecord.fromJson(json)).toList();
  }

  @override
  Future<void> savePassword(PasswordRecord password) async {
    await _localStorageService.insertPassword(password.toJson());
  }

  @override
  Future<void> deletePassword(String id) async {
    await _localStorageService.deletePassword(id);
  }

  @override
  Future<void> clearHistory() async {
    await _localStorageService.clearPasswords();
  }

  @override
  Future<PasswordRecord> createPasswordRecord({
    required String password,
    required int strength,
  }) async {
    final isSecure = await _securityApiService.checkPasswordSecurity(password);

    if (!isSecure) {
      throw Exception('Этот пароль был скомпрометирован в утечках данных!');
    }

    return PasswordRecord(
      id: _uuid.v4(),
      password: password,
      createdAt: DateTime.now(),
      strength: strength,
    );
  }
}