import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'task_card.dart';

class CalendarViewWidget extends StatefulWidget {
  const CalendarViewWidget({super.key});

  @override
  State<CalendarViewWidget> createState() => _CalendarViewWidgetState();
}

class _CalendarViewWidgetState extends State<CalendarViewWidget> {
  DateTime _selectedDate = DateTime.now();
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 500);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStartDate(int pageIndex) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final offsetWeeks = pageIndex - 500;
    return currentWeekStart.add(Duration(days: offsetWeeks * 7));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final allTasks = provider.allTasks;

    final selectedDayTasks = allTasks.where((t) {
      return t.dueDate.year == _selectedDate.year &&
             t.dueDate.month == _selectedDate.month &&
             t.dueDate.day == _selectedDate.day;
    }).toList();

    return Column(
      children: [
        Container(
          height: 120,
          color: Colors.white,
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              final weekStart = _getWeekStartDate(index);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(7, (dayIndex) {
                  final currentDate = weekStart.add(Duration(days: dayIndex));
                  final isSelected = currentDate.year == _selectedDate.year &&
                                     currentDate.month == _selectedDate.month &&
                                     currentDate.day == _selectedDate.day;
                  final isToday = currentDate.year == DateTime.now().year &&
                                  currentDate.month == DateTime.now().month &&
                                  currentDate.day == DateTime.now().day;
                                     
                  final tasksForDate = allTasks.where((t) => t.dueDate.year == currentDate.year && t.dueDate.month == currentDate.month && t.dueDate.day == currentDate.day).toList();

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = currentDate),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.indigo : (isToday ? Colors.indigo.shade50 : Colors.transparent),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? Colors.indigo : Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('E').format(currentDate).substring(0, 3).toUpperCase(), style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white70 : (isToday ? Colors.indigo : Colors.grey.shade500),
                          )),
                          const SizedBox(height: 8),
                          Text('${currentDate.day}', style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800,
                            color: isSelected ? Colors.white : Colors.black87,
                          )),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: tasksForDate.take(3).map((t) {
                               return Container(
                                 margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                 width: 6, height: 6,
                                 decoration: BoxDecoration(
                                   color: t.isDone ? (isSelected ? Colors.white54 : Colors.green) : (isSelected ? Colors.white : Colors.orange),
                                   shape: BoxShape.circle,
                                 ),
                               );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        
        Container(height: 1, color: Colors.grey.shade200),
        
        Expanded(
          child: selectedDayTasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_available_rounded, size: 80, color: Colors.indigo.shade100),
                      const SizedBox(height: 16),
                      Text('No assignments for this day!', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: selectedDayTasks.length,
                  itemBuilder: (context, index) {
                    final task = selectedDayTasks[index];
                    final isBlocked = provider.isBlocked(task);
                    final blocker = task.blockedById != null
                        ? allTasks.where((t) => t.id == task.blockedById).firstOrNull
                        : null;

                    return TaskCard(
                      key: ValueKey(task.id),
                      task: task,
                      isBlocked: isBlocked,
                      blockerTitle: blocker?.title,
                      searchQuery: '',
                      onTap: () {
                         Navigator.pushNamed(context, '/task-form', arguments: task);
                      },
                      onToggleDone: (val) {
                        provider.updateTask(task.copyWith(status: val ? TaskStatus.done : TaskStatus.todo));
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
