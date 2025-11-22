import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История паролей'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: null, // Пока без логики
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Поиск в истории...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: null, // Пока без логики
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                _PasswordHistoryItem(
                  password: 'A7#k9!pQ2xVm',
                  date: '12.12.2023 14:30',
                ),
                _PasswordHistoryItem(
                  password: 'Bn8*ktP4!qWx',
                  date: '12.12.2023 14:25',
                ),
                _PasswordHistoryItem(
                  password: 'Mp5\$rT9@vNz2',
                  date: '12.12.2023 14:20',
                ),
                _PasswordHistoryItem(
                  password: 'Xy3#pL8!kMw9',
                  date: '12.12.2023 14:15',
                ),
                _PasswordHistoryItem(
                  password: 'Rt6\$qN2@zPx7',
                  date: '12.12.2023 14:10',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('ОЧИСТИТЬ ИСТОРИЮ'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Элемент истории паролей
class _PasswordHistoryItem extends StatelessWidget {
  final String password;
  final String date;

  const _PasswordHistoryItem({
    required this.password,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    password,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, color: Colors.blue),
              onPressed: null,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }
}