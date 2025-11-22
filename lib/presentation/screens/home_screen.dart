import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import '../view_models/password_view_model.dart';
import '../widgets/password_strength_indicator.dart';
import '../../../data/repositories/password_repository_impl.dart';
import '../../../data/services/local_storage_service.dart';
import '../../../data/services/security_api_service.dart';
import '../../../domain/entities/password_record.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _generatedPassword = 'Нажмите "Сгенерировать"';
  double _passwordLength = 12;
  double _passwordStrength = 0.0;

  bool _uppercase = true;
  bool _lowercase = true;
  bool _numbers = true;
  bool _symbols = true;

  late PasswordRepositoryImpl _passwordRepository;
  late LocalStorageService _localStorageService;
  late SecurityApiService _securityApiService;

  @override
  void initState() {
    super.initState();
    _localStorageService = LocalStorageService();
    _securityApiService = SecurityApiService();
    _passwordRepository = PasswordRepositoryImpl(
      localStorageService: _localStorageService,
      securityApiService: _securityApiService,
    );
  }

  String _generateRandomPassword() {
    if (!_uppercase && !_lowercase && !_numbers && !_symbols) {
      return 'Выберите типы символов!';
    }

    String chars = '';
    if (_uppercase) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_lowercase) chars += 'abcdefghijklmnopqrstuvwxyz';
    if (_numbers) chars += '0123456789';
    if (_symbols) chars += '!@#\$%^&*()';

    String result = '';
    final random = Random();
    for (int i = 0; i < _passwordLength; i++) {
      result += chars[random.nextInt(chars.length)];
    }
    return result;
  }

  Future<void> _generatePassword(BuildContext context) async {
    // ДОБАВЬТЕ ЭТУ ПРОВЕРКУ В НАЧАЛО ФУНКЦИИ
    if (!_uppercase && !_lowercase && !_numbers && !_symbols) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите хотя бы один тип символов!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return; // Выходим из функции
    }

    final newPassword = _generateRandomPassword();
    if (newPassword != 'Выберите типы символов!') {
      setState(() {
        _generatedPassword = newPassword;
        _passwordStrength = _calculateStrength();
      });

      try {
        final passwordRecord = await _passwordRepository.createPasswordRecord(
          password: newPassword,
          strength: (_passwordStrength * 100).toInt(),
        );

        // Сохраняем через ViewModel
        final viewModel = Provider.of<PasswordViewModel>(context, listen: false);
        await viewModel.savePassword(passwordRecord);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Новый пароль сгенерирован и сохранен в историю'),
            duration: Duration(seconds: 1),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _copyToClipboard() {
    if (_generatedPassword == 'Выберите типы символов!' ||
        _generatedPassword == 'Нажмите "Сгенерировать"') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала сгенерируйте валидный пароль'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // ДОБАВЬТЕ РЕАЛЬНОЕ КОПИРОВАНИЕ
    Clipboard.setData(ClipboardData(text: _generatedPassword));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Пароль скопирован в буфер обмена'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToHistory(BuildContext context) {
    Navigator.pushNamed(context, '/history');
  }

  double _calculateStrength() {
    if (!_uppercase && !_lowercase && !_numbers && !_symbols) {
      return 0.0;
    }

    double strength = 0.0;
    if (_uppercase) strength += 0.2;
    if (_lowercase) strength += 0.2;
    if (_numbers) strength += 0.3;
    if (_symbols) strength += 0.3;

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
            // Security API статус
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Проверяем пароли через Have I Been Pwned API',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

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
                    onPressed: () => _generatePassword(context),
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
              onPressed: () => _navigateToHistory(context),
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