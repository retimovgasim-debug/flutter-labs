import 'package:flutter/material.dart';
import '../services/password_service.dart';
import '../models/password_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final PasswordService _passwordService = PasswordService();
  final TextEditingController _searchController = TextEditingController();
  List<PasswordRecord> _displayedHistory = [];

  @override
  void initState() {
    super.initState();
    _updateDisplayedHistory();
  }

  void _updateDisplayedHistory() {
    setState(() {
      _displayedHistory = _passwordService.passwordHistory;
    });
  }

  void _searchPasswords(String query) {
    setState(() {
      if (query.isEmpty) {
        _displayedHistory = _passwordService.passwordHistory;
      } else {
        _displayedHistory = _passwordService.searchPasswords(query);
      }
    });
  }

  void _copyPassword(String password) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Пароль "$password" скопирован'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deletePassword(int index) {
    // Получаем реальный индекс в основном списке
    final recordToDelete = _displayedHistory[index];
    final mainIndex = _passwordService.passwordHistory.indexOf(recordToDelete);

    _passwordService.deletePassword(mainIndex);
    _updateDisplayedHistory();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Пароль удален из истории'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearHistory() {
    _passwordService.clearHistory();
    _updateDisplayedHistory();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('История очищена'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История паролей'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
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
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск в истории...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: _searchPasswords,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _displayedHistory.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'История паролей пуста',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Сгенерируйте пароли на главном экране',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _displayedHistory.length,
              itemBuilder: (context, index) {
                final record = _displayedHistory[index];
                return _PasswordHistoryItem(
                  password: record.password,
                  date: record.formattedDate,
                  onCopy: () => _copyPassword(record.password),
                  onDelete: () => _deletePassword(index),
                );
              },
            ),
          ),
          if (_passwordService.passwordHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _clearHistory,
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
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _PasswordHistoryItem({
    required this.password,
    required this.date,
    required this.onCopy,
    required this.onDelete,
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
              onPressed: onCopy,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}