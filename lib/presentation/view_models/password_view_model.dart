import 'package:flutter/foundation.dart';
import '../../domain/entities/password_record.dart';
import '../../domain/repositories/password_repository.dart';

class PasswordViewModel with ChangeNotifier {
  final PasswordRepository _passwordRepository;

  PasswordViewModel({required PasswordRepository passwordRepository})
      : _passwordRepository = passwordRepository;

  List<PasswordRecord> _passwordHistory = [];
  List<PasswordRecord> get passwordHistory => _passwordHistory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> loadPasswordHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      _passwordHistory = await _passwordRepository.getPasswordHistory();
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Ошибка загрузки истории: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePassword(PasswordRecord password) async {
    try {
      await _passwordRepository.savePassword(password);
      await loadPasswordHistory(); // Обновляем историю
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Ошибка сохранения пароля: $e';
      notifyListeners();
    }
  }

  Future<void> deletePassword(String id) async {
    try {
      await _passwordRepository.deletePassword(id);
      await loadPasswordHistory(); // Обновляем историю
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Ошибка удаления пароля: $e';
      notifyListeners();
    }
  }

  Future<void> clearHistory() async {
    try {
      await _passwordRepository.clearHistory();
      await loadPasswordHistory(); // Обновляем историю
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Ошибка очистки истории: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}