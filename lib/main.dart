import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/history_screen.dart';
import 'presentation/view_models/password_view_model.dart';
import 'data/repositories/password_repository_impl.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/security_api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStorageService>(
          create: (_) => LocalStorageService(),
        ),
        Provider<SecurityApiService>(
          create: (_) => SecurityApiService(),
        ),
        Provider<PasswordRepositoryImpl>(
          create: (context) => PasswordRepositoryImpl(
            localStorageService: context.read<LocalStorageService>(),
            securityApiService: context.read<SecurityApiService>(),
          ),
        ),
        ChangeNotifierProvider<PasswordViewModel>(
          create: (context) => PasswordViewModel(
            passwordRepository: context.read<PasswordRepositoryImpl>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Генератор паролей',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        routes: {
          '/history': (context) => const HistoryScreen(),
        },
      ),
    );
  }
}