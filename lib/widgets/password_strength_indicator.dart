import 'package:flutter/material.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final double strength; // от 0.0 до 1.0

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    String getStrengthText() {
      if (strength < 0.3) return 'Слабый';
      if (strength < 0.7) return 'Средний';
      return 'Сильный';
    }

    Color getStrengthColor() {
      if (strength < 0.3) return Colors.red;
      if (strength < 0.7) return Colors.orange;
      return Colors.green;
    }

    return Column(
      children: [
        LinearProgressIndicator(
          value: strength,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(getStrengthColor()),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Сложность:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              getStrengthText(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: getStrengthColor(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}