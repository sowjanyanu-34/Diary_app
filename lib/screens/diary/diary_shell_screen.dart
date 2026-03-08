import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/snack.dart';
import 'diary_home_screen.dart';
import 'search_screen.dart';

class DiaryShellScreen extends StatelessWidget {
  const DiaryShellScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService.instance.signOut();
    } catch (e) {
      if (!context.mounted) return;
      showSnack(context, 'Logout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Echo Diary'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.search), text: 'Search'),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: const TabBarView(
          children: [
            DiaryHomeScreen(),
            SearchScreen(),
          ],
        ),
      ),
    );
  }
}

