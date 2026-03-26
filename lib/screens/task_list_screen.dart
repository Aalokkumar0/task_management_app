// lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/calendar_view_widget.dart';
import 'task_form_screen.dart';
import 'streak_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();
  bool _isCalendarView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TaskFormScreen()),
    );
  }

  void _openEdit(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TaskFormScreen(existingTask: task)),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello there 👋',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'My Tasks',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, right: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_isCalendarView ? Icons.list_rounded : Icons.calendar_month_rounded, color: Colors.indigo.shade700),
                  onPressed: () => setState(() => _isCalendarView = !_isCalendarView),
                ),
                const SizedBox(width: 8),
                const _StreakBadge(),
                const SizedBox(width: 8),
                const _SavingIndicator(),
              ],
            ),
          ),
        ],
      ),
      body: _isCalendarView
          ? const CalendarViewWidget()
          : Column(
              children: [
                _SearchBar(controller: _searchController),
                const SizedBox(height: 6),
                const _FilterChips(),
                const SizedBox(height: 6),
                Expanded(
                    child: _TaskList(onEdit: _openEdit, onDelete: _confirmDelete)),
              ],
            ),
      floatingActionButton: _AnimatedNewTaskButton(
        onPressed: () => _openCreate(context),
      ),
    );
  }
}

// 🔄 Saving Indicator
class _SavingIndicator extends StatelessWidget {
  const _SavingIndicator();

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        if (!provider.isSaving) return const SizedBox.shrink();

        return Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 6),
            Text(
              'Saving...',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

// 🔥 Animated Streak Badge
class _StreakBadge extends StatefulWidget {
  const _StreakBadge();

  @override
  State<_StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<_StreakBadge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final streak = provider.dailyStreak;
        if (streak == 0) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StreakScreen()),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$streak ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 🔍 Search Bar
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        onChanged: context.read<TaskProvider>().setSearchDebounced,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// 🏷 Filter Chips
class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final active = provider.filterStatus;
        final options = [null, ...TaskStatus.values];

        return SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: options.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final status = options[i];
              final label = status?.label ?? 'All';
              final isSelected = active == status;

              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (_) =>
                    provider.setFilter(isSelected ? null : status),
              );
            },
          ),
        );
      },
    );
  }
}

// 📋 Task List
class _TaskList extends StatelessWidget {
  final void Function(BuildContext, Task) onEdit;
  final Future<bool?> Function(BuildContext, Task) onDelete;

  const _TaskList({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final tasks = provider.filteredTasks;

        if (tasks.isEmpty) {
          return const _AnimatedEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: tasks.length,
          itemBuilder: (context, i) {
            final task = tasks[i];
            final blocked = provider.isBlocked(task);
            final blocker = task.blockedById != null
                ? provider.getTaskById(task.blockedById!)
                : null;

            return Dismissible(
              key: ValueKey('dismiss_${task.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 30),
              ),
              confirmDismiss: (_) => onDelete(context, task),
              onDismissed: (_) {
                context.read<TaskProvider>().deleteTask(task.id);
              },
              child: TaskCard(
                task: task,
                isBlocked: blocked,
                blockerTitle: blocker?.title,
                searchQuery: provider.searchQuery,
                onTap: () => onEdit(context, task),
                onToggleDone: (bool isDone) {
                  provider.updateTask(task.copyWith(
                    status: isDone ? TaskStatus.done : TaskStatus.todo,
                  ));
                },
              ),
            );
          },
        );
      },
    );
  }
}

// 🌟 Animated New Task Button
class _AnimatedNewTaskButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedNewTaskButton({required this.onPressed});

  @override
  State<_AnimatedNewTaskButton> createState() => _AnimatedNewTaskButtonState();
}

class _AnimatedNewTaskButtonState extends State<_AnimatedNewTaskButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: _isHovered ? 0.5 : 0.3),
                  blurRadius: _isHovered ? 14 : 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'New Task',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 📋 Animated Empty State Box
class _AnimatedEmptyState extends StatelessWidget {
  const _AnimatedEmptyState();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.task_alt_rounded,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No tasks found',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enjoy your free time or add a new task!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
