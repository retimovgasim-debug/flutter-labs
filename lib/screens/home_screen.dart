import 'package:flutter/material.dart';
import '../widgets/password_strength_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'A7#k9!pQ2xVm',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Индикатор сложности
                  PasswordStrengthIndicator(strength: 0.8),
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
                const Text(
                  '12',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: 12,
                    min: 6,
                    max: 32,
                    divisions: 26,
                    onChanged: null, // Пока без логики
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Типы символов
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Типы символов:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SymbolTypeCheckbox(label: 'A-Z', value: true),
                    ),
                    Expanded(
                      child: _SymbolTypeCheckbox(label: 'a-z', value: true),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _SymbolTypeCheckbox(label: '0-9', value: true),
                    ),
                    Expanded(
                      child: _SymbolTypeCheckbox(label: '!@#\$', value: true),
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
                    onPressed: null,
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
                    onPressed: null,
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
              onPressed: null,
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

// Вспомогательный виджет для чекбоксов
class _SymbolTypeCheckbox extends StatelessWidget {
  final String label;
  final bool value;

  const _SymbolTypeCheckbox({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: null,
        ),
        Text(label),
      ],
    );
  }
}