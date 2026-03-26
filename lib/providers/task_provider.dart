// lib/providers/task_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isSaving = false;
  String _searchQuery = '';
  TaskStatus? _filterStatus;
  Timer? _debounce;

  // ── Getters ──────────────────────────────────────────────────────────────
  List<Task> get allTasks => _tasks;
  bool get isSaving => _isSaving;
  String get searchQuery => _searchQuery;
  TaskStatus? get filterStatus => _filterStatus;

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
    notifyListeners();
  }

  // ── Create ────────────────────────────────────────────────────────────────
  Future<void> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskStatus status,
    String? blockedById,
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

    await DatabaseHelper.instance.updateTask(updatedTask);
    final idx = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (idx != -1) {
      _tasks[idx] = updatedTask;
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