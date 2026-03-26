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

          final completedCount = provider.allTasks.where((t) => t.isDone).length;
          final currentXP = completedCount * 100;
          final currentLevel = (currentXP / 1000).floor() + 1;
          final progressToNext = (currentXP % 1000) / 1000.0;
          
          String title = "Freshman";
          if (currentLevel == 2) title = "Sophomore";
          else if (currentLevel == 3) title = "Junior";
          else if (currentLevel == 4) title = "Senior";
          else if (currentLevel >= 5) title = "Scholar";

          return Column(
            children: [
              const SizedBox(height: 20),
              
              // 🎓 XP Level Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade600, Colors.indigo.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.indigo.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Level $currentLevel: $title', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('$currentXP XP Total', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                          child: const Icon(Icons.school_rounded, color: Colors.white, size: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressToNext,
                        backgroundColor: Colors.white24,
                        color: Colors.amberAccent,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${1000 - (currentXP % 1000)} XP to next level', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              // 🔥 Streak Overview
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department_rounded, size: 40, color: Colors.orange.shade400),
                  const SizedBox(width: 12),
                  Text(
                    '$streak Day Streak!',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: history.length,
                  itemBuilder: (context, i) {
                    final date = history[i];
                    // Filter tasks completed on this active date
                    final completedTasks = provider.allTasks.where((task) =>
                        task.isDone &&
                        task.dueDate.year == date.year &&
                        task.dueDate.month == date.month &&
                        task.dueDate.day == date.day).toList();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          iconColor: Colors.orange,
                          collapsedIconColor: Colors.grey,
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
                          subtitle: Text(
                            completedTasks.isNotEmpty 
                                ? '${completedTasks.length} Task${completedTasks.length == 1 ? '' : 's'} Completed' 
                                : 'Active Day',
                          ),
                          children: [
                            if (completedTasks.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No tasks completed on this day.', style: TextStyle(color: Colors.grey)),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: completedTasks.length,
                                itemBuilder: (context, index) {
                                  final task = completedTasks[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                                    leading: const Icon(Icons.check_box_rounded, color: Colors.green, size: 20),
                                    title: Text(
                                      task.title,
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    dense: true,
                                  );
                                },
                              )
                          ],
                        ),
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
