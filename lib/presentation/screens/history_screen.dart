import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/password_view_model.dart';
import '../../../domain/entities/password_record.dart';
import 'package:flutter/services.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PasswordRecord> _displayedHistory = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<PasswordViewModel>(context, listen: false);
      viewModel.loadPasswordHistory();
    });
  }

  void _searchPasswords(String query, List<PasswordRecord> allHistory) {
    setState(() {
      if (query.isEmpty) {
        _displayedHistory = allHistory;
      } else {
        _displayedHistory = allHistory
            .where((record) => record.password.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _copyPassword(String password) {
    // КОПИРОВАНИЕ В БУФЕР ОБМЕНА
    Clipboard.setData(ClipboardData(text: password));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Пароль "$password" скопирован'),
        duration: const Duration(seconds: 2),
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
      body: Consumer<PasswordViewModel>(
        builder: (context, viewModel, child) {
          // ВСЕГДА используем актуальную историю из ViewModel
          _displayedHistory = viewModel.passwordHistory;

          // Если есть поисковый запрос, фильтруем
          if (_searchController.text.isNotEmpty) {
            _displayedHistory = _displayedHistory
                .where((record) => record.password.toLowerCase()
                .contains(_searchController.text.toLowerCase()))
                .toList();
          }

          return Column(
            children: [
              // Поле поиска
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
                        onChanged: (value) => _searchPasswords(value, viewModel.passwordHistory),
                      ),
                    ),
                  ],
                ),
              ),

              // Сообщение об ошибке
              if (viewModel.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: viewModel.clearError,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Индикатор загрузки
              if (viewModel.isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),

              // Список паролей
              Expanded(
                child: _displayedHistory.isEmpty && !viewModel.isLoading
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
                      strength: record.strength,
                      onCopy: () => _copyPassword(record.password),
                      onDelete: () => viewModel.deletePassword(record.id),
                    );
                  },
                ),
              ),

              // Кнопка очистки
              if (viewModel.passwordHistory.isNotEmpty && !viewModel.isLoading)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showClearConfirmationDialog(context, viewModel),
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
          );
        },
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context, PasswordViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Очистка истории'),
          content: const Text('Вы уверены, что хотите очистить всю историю паролей?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ОТМЕНА'),
            ),
            TextButton(
              onPressed: () {
                viewModel.clearHistory();
                Navigator.of(context).pop();
              },
              child: const Text('ОЧИСТИТЬ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// Элемент истории паролей
class _PasswordHistoryItem extends StatelessWidget {
  final String password;
  final String date;
  final int strength;
  final VoidCallback onCopy;
  final VoidCallback onDelete;

  const _PasswordHistoryItem({
    required this.password,
    required this.date,
    required this.strength,
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
                  Row(
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStrengthColor(strength).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$strength%',
                          style: TextStyle(
                            fontSize: 10,
                            color: _getStrengthColor(strength),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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

  Color _getStrengthColor(int strength) {
    if (strength < 30) return Colors.red;
    if (strength < 70) return Colors.orange;
    return Colors.green;
  }
}