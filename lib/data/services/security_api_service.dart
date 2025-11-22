import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class SecurityApiService {
  static const String _apiUrl = 'https://api.pwnedpasswords.com/range/';

  /// Проверяет, был ли пароль скомпрометирован в утечках данных
  /// Использует API Have I Been Pwned
  Future<bool> checkPasswordSecurity(String password) async {
    try {
      final sha1 = _sha1(password);
      final prefix = sha1.substring(0, 5);

      final response = await http.get(Uri.parse('$_apiUrl$prefix'));

      if (response.statusCode == 200) {
        return !_checkHashInResponse(sha1, response.body);
      }
      return true; // Если API недоступно, считаем пароль безопасным
    } catch (e) {
      return true; // При ошибке считаем пароль безопасным
    }
  }

  String _sha1(String input) {
    var bytes = utf8.encode(input);
    var digest = sha1.convert(bytes);
    return digest.toString().toUpperCase();
  }

  bool _checkHashInResponse(String fullHash, String responseBody) {
    final suffix = fullHash.substring(5);
    final lines = responseBody.split('\n');
    for (final line in lines) {
      if (line.startsWith(suffix)) {
        return true;
      }
    }
    return false;
  }
}