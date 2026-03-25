// lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchController = TextEditingController();

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

  Future<void> _confirmDelete(BuildContext context, Task task) async {
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

    if (confirmed == true && context.mounted) {
      context.read<TaskProvider>().deleteTask(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 0, 0),
        toolbarHeight: 50,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello there 👋',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 70,),
            const Text(
              'My Tasks',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: const [
          _SavingIndicator(),
          SizedBox(width: 16),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(controller: _searchController),
          const SizedBox(height: 6),
          const _FilterChips(),
          const SizedBox(height: 6),
          Expanded(
              child: _TaskList(onEdit: _openEdit, onDelete: _confirmDelete)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context),
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
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
  final void Function(BuildContext, Task) onDelete;

  const _TaskList({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        final tasks = provider.filteredTasks;

        if (tasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_rounded,
                    size: 80,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                Text(
                  'No tasks found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enjoy your free time or add a new task!',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          );
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: tasks.length,
          onReorder: provider.reorderTasks,
          itemBuilder: (context, i) {
            final task = tasks[i];
            final blocked = provider.isBlocked(task);
            final blocker = task.blockedById != null
                ? provider.getTaskById(task.blockedById!)
                : null;

            return ReorderableDragStartListener(
              key: ValueKey(task.id),
              index: i,
              child: TaskCard(
                task: task,
                isBlocked: blocked,
                blockerTitle: blocker?.title,
                searchQuery: provider.searchQuery,
                onTap: () => onEdit(context, task),
                onDelete: () => onDelete(context, task),
              ),
            );
          },
        );
      },
    );
  }
}
