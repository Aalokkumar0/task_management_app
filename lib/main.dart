// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_provider.dart';
import 'providers/draft_provider.dart';
import 'screens/task_list_screen.dart';
import 'package:task_management_app/ theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => DraftProvider()..loadDraft()),
      ],
      child: MaterialApp(
        title: 'Task Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const TaskListScreen(),
      ),
    );
  }
}