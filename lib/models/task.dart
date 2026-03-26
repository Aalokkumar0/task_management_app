// lib/models/task.dart

enum TaskStatus {
  todo('To-Do'),
  inProgress('In Progress'),
  done('Done');

  final String label;
  const TaskStatus(this.label);

  static TaskStatus fromString(String s) {
    return TaskStatus.values.firstWhere(
      (e) => e.label == s,
      orElse: () => TaskStatus.todo,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final String? blockedById;
  final int sortOrder;
  final DateTime? recurrenceEndDate;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedById,
    this.sortOrder = 0,
    this.recurrenceEndDate,
  });

  bool get isDone => status == TaskStatus.done;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    String? blockedById,
    bool clearBlockedBy = false,
    int? sortOrder,
    DateTime? recurrenceEndDate,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: clearBlockedBy ? null : (blockedById ?? this.blockedById),
      sortOrder: sortOrder ?? this.sortOrder,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'status': status.label,
      'blocked_by_id': blockedById,
      'sort_order': sortOrder,
      'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: DateTime.parse(map['due_date'] as String),
      status: TaskStatus.fromString(map['status'] as String),
      blockedById: map['blocked_by_id'] as String?,
      sortOrder: (map['sort_order'] as int?) ?? 0,
      recurrenceEndDate: map['recurrence_end_date'] != null 
          ? DateTime.parse(map['recurrence_end_date'] as String) 
          : null,
    );
  }
}