import 'package:flutter/material.dart';

import 'screens/diary/diary_shell_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

class EchoDiaryApp extends StatelessWidget {
  const EchoDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo Diary App',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: StreamBuilder(
        stream: AuthService.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (user == null) return const HomeScreen();
          return const DiaryShellScreen();
        },
      ),
    );
  }
}

