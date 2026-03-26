// lib/screens/streak_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streak History'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final history = provider.activeDatesHistory.reversed.toList();
          final streak = provider.dailyStreak;

          return Column(
            children: [
              const SizedBox(height: 20),
              Icon(Icons.local_fire_department_rounded, size: 80, color: Colors.orange.shade400),
              const SizedBox(height: 10),
              Text(
                '$streak Day Streak!',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: history.length,
                  itemBuilder: (context, i) {
                    final date = history[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: Colors.green),
                        ),
                        title: Text(
                          DateFormat('EEEE, MMM d, yyyy').format(date),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: const Text('Active Day'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
