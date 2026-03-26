// lib/providers/task_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isSaving = false;
  String _searchQuery = '';
  TaskStatus? _filterStatus;
  Timer? _debounce;
  int _dailyStreak = 0;
  List<DateTime> _activeDatesHistory = [];

  // ── Getters ──────────────────────────────────────────────────────────────
  List<Task> get allTasks => _tasks;
  bool get isSaving => _isSaving;
  String get searchQuery => _searchQuery;
  TaskStatus? get filterStatus => _filterStatus;
  
  int get dailyStreak => _dailyStreak;
  List<DateTime> get activeDatesHistory => _activeDatesHistory;

  int get completedTasksCount => _tasks.where((t) => t.isDone).length;

  List<Task> get filteredTasks {
    List<Task> result = List<Task>.from(_tasks);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((t) => t.title.toLowerCase().contains(q)).toList();
    }
    if (_filterStatus != null) {
      result = result.where((t) => t.status == _filterStatus).toList();
    }
    return result;
  }

  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if [task] is blocked by another task that isn't Done yet.
  bool isBlocked(Task task) {
    if (task.blockedById == null) return false;
    final blocker = getTaskById(task.blockedById!);
    return blocker != null && !blocker.isDone;
  }

  // ── Load ─────────────────────────────────────────────────────────────────
  Future<void> loadTasks() async {
    _tasks = await DatabaseHelper.instance.getTasks();
    await _updateDailyStreak();
    notifyListeners();
  }

  Future<void> _updateDailyStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveStr = prefs.getString('last_active_date');
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    int streak = prefs.getInt('daily_streak') ?? 0;

    if (lastActiveStr != null) {
      final lastActive = DateTime.parse(lastActiveStr);
      final difference = todayDate.difference(lastActive).inDays;

      if (difference == 1) {
        streak += 1;
      } else if (difference > 1) {
        streak = 1;
      }
    } else {
      streak = 1;
    }

    _dailyStreak = streak;
    await prefs.setString('last_active_date', todayDate.toIso8601String());
    await prefs.setInt('daily_streak', streak);

    final activeDatesStr = prefs.getStringList('active_dates') ?? [];
    final todayStr = todayDate.toIso8601String();
    if (!activeDatesStr.contains(todayStr)) {
      activeDatesStr.add(todayStr);
      await prefs.setStringList('active_dates', activeDatesStr);
    }
    _activeDatesHistory = activeDatesStr.map((e) => DateTime.parse(e)).toList();
  }

  // ── Create ────────────────────────────────────────────────────────────────
  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskStatus status,
    String? blockedById,
    DateTime? recurrenceEndDate,
  }) async {
    _isSaving = true;
    notifyListeners();

    // Simulated 2-second network/API delay (as required)
    await Future.delayed(const Duration(seconds: 2));

    final task = Task(
      id: const Uuid().v4(),
      title: title.trim(),
      description: description.trim(),
      dueDate: dueDate,
      status: status,
      blockedById: blockedById,
      sortOrder: _tasks.length,
      recurrenceEndDate: recurrenceEndDate,
    );

    await DatabaseHelper.instance.insertTask(task);
    _tasks.add(task);

    _isSaving = false;
    notifyListeners();
  }

  // ── Update ────────────────────────────────────────────────────────────────
  Future<void> updateTask(Task updatedTask) async {
    _isSaving = true;
    notifyListeners();

    // Simulated 2-second network/API delay (as required)
    await Future.delayed(const Duration(seconds: 2));

    final idx = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (idx != -1) {
      final oldTask = _tasks[idx];
      _tasks[idx] = updatedTask;
      await DatabaseHelper.instance.updateTask(updatedTask);

      if (!oldTask.isDone && updatedTask.isDone && updatedTask.recurrenceEndDate != null) {
        final nextDate = updatedTask.dueDate.add(const Duration(days: 1));
        final nextDateBase = DateTime(nextDate.year, nextDate.month, nextDate.day);
        final endDateBase = DateTime(
            updatedTask.recurrenceEndDate!.year,
            updatedTask.recurrenceEndDate!.month,
            updatedTask.recurrenceEndDate!.day);

        if (nextDateBase.isBefore(endDateBase) || nextDateBase.isAtSameMomentAs(endDateBase)) {
          final nextTask = Task(
            id: const Uuid().v4(),
            title: updatedTask.title,
            description: updatedTask.description,
            dueDate: nextDate,
            status: TaskStatus.todo,
            blockedById: updatedTask.blockedById,
            sortOrder: _tasks.length,
            recurrenceEndDate: updatedTask.recurrenceEndDate,
          );
          await DatabaseHelper.instance.insertTask(nextTask);
          _tasks.add(nextTask);
        }
      }
    }

    _isSaving = false;
    notifyListeners();
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  Future<void> deleteTask(String id) async {
    await DatabaseHelper.instance.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    // Unblock tasks that referenced the deleted task
    _tasks = _tasks
        .map((t) => t.blockedById == id ? t.copyWith(clearBlockedBy: true) : t)
        .toList();
    notifyListeners();
  }

  // ── Reorder (drag-and-drop) ───────────────────────────────────────────────
  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final task = filteredTasks[oldIndex];
    final actualOld = _tasks.indexOf(task);
    int actualNew = newIndex;

    if (actualOld < actualNew) actualNew--;

    _tasks.removeAt(actualOld);
    _tasks.insert(actualNew, task);
    await DatabaseHelper.instance.updateSortOrders(_tasks);
    notifyListeners();
  }

  // ── Search / Filter (with debounce) ──────────────────────────────────────
  void setSearchDebounced(String query) {
    _searchQuery = query;
    notifyListeners();

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (kDebugMode && query.isNotEmpty) {
        debugPrint('Simulated debounced API search logic for: $query');
      }
    });
  }

  void setFilter(TaskStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}