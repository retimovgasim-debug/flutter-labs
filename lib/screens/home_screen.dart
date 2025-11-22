import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/password_strength_indicator.dart';
import '../services/password_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _generatedPassword = 'Нажмите "Сгенерировать"';
  double _passwordLength = 12;
  double _passwordStrength = 0.0;

  // Настройки символов
  bool _uppercase = true;
  bool _lowercase = true;
  bool _numbers = true;
  bool _symbols = true;

  String? _generateRandomPassword() {
    // Возвращаем null если не выбраны типы символов
    if (!_uppercase && !_lowercase && !_numbers && !_symbols) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы один тип символов!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return null;
    }

    // Формируем строку доступных символов
    String chars = '';
    if (_uppercase) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_lowercase) chars += 'abcdefghijklmnopqrstuvwxyz';
    if (_numbers) chars += '0123456789';
    if (_symbols) chars += '!@#\$%^&*()';

    // Генерируем пароль
    String result = '';
    final random = Random();
    for (int i = 0; i < _passwordLength; i++) {
      result += chars[random.nextInt(chars.length)];
    }
    return result;
  }

  void _generatePassword() {
    final newPassword = _generateRandomPassword();
    if (newPassword != null) {
      setState(() {
        _generatedPassword = newPassword;
        _passwordStrength = _calculateStrength();
      });

      // СОХРАНЯЕМ В ИСТОРИЮ!
      PasswordService().addPassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Новый пароль сгенерирован и сохранен в историю'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _copyToClipboard() {
    // Не копируем если пароль фейковый
    if (_generatedPassword == 'Выберите типы символов!' ||
        _generatedPassword == 'Нажмите "Сгенерировать"' ||
        _generatedPassword == 'Ошибка генерации') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала сгенерируйте валидный пароль'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Пароль скопирован в буфер обмена'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.pushNamed(context, '/history');
  }

  double _calculateStrength() {
    // Проверяем что выбран хотя бы один тип
    if (!_uppercase && !_lowercase && !_numbers && !_symbols) {
      return 0.0;
    }

    double strength = 0.0;
    if (_uppercase) strength += 0.2;
    if (_lowercase) strength += 0.2;
    if (_numbers) strength += 0.3;
    if (_symbols) strength += 0.3;

    // Умножаем на коэффициент длины
    strength *= (_passwordLength / 32);

    return strength.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isPlaceholderPassword = _generatedPassword == 'Выберите типы символов!' ||
        _generatedPassword == 'Нажмите "Сгенерировать"';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Генератор паролей'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Отображение сгенерированного пароля
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                children: [
                  const Text(
                    'Сгенерированный пароль',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _generatedPassword,
                    style: TextStyle(
                      fontSize: isPlaceholderPassword ? 18 : 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: isPlaceholderPassword ? 0 : 1.5,
                      color: isPlaceholderPassword ? Colors.grey : Colors.black,
                    ),
                    textAlign: isPlaceholderPassword ? TextAlign.center : TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  PasswordStrengthIndicator(strength: _passwordStrength),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Настройка длины пароля
            Row(
              children: [
                const Text(
                  'Длина пароля:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  _passwordLength.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _passwordLength,
                    min: 6,
                    max: 32,
                    divisions: 26,
                    onChanged: (value) {
                      setState(() {
                        _passwordLength = value;
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Типы символов
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Типы символов:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SymbolTypeCheckbox(
                        label: 'A-Z',
                        value: _uppercase,
                        onChanged: (value) {
                          setState(() {
                            _uppercase = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _SymbolTypeCheckbox(
                        label: 'a-z',
                        value: _lowercase,
                        onChanged: (value) {
                          setState(() {
                            _lowercase = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _SymbolTypeCheckbox(
                        label: '0-9',
                        value: _numbers,
                        onChanged: (value) {
                          setState(() {
                            _numbers = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _SymbolTypeCheckbox(
                        label: '!@#\$',
                        value: _symbols,
                        onChanged: (value) {
                          setState(() {
                            _symbols = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _generatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('СГЕНЕРИРОВАТЬ'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 60,
                  child: ElevatedButton(
                    onPressed: _copyToClipboard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Icon(Icons.copy),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Кнопка перехода к истории
            OutlinedButton(
              onPressed: _navigateToHistory,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 20),
                  SizedBox(width: 8),
                  Text('ИСТОРИЯ ПАРОЛЕЙ'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Виджет для чекбоксов
class _SymbolTypeCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool?)? onChanged;

  const _SymbolTypeCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Text(label),
      ],
    );
  }
}