// lib/screens/task_form_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/draft_provider.dart';
import '../providers/task_provider.dart';
import 'package:task_management_app/ theme/app_theme.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? existingTask;
  const TaskFormScreen({super.key, this.existingTask});

  bool get isEditing => existingTask != null;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late DateTime _dueDate;
  late TaskStatus _status;
  String? _blockedById;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final t = widget.existingTask!;
      _titleCtrl = TextEditingController(text: t.title);
      _descCtrl = TextEditingController(text: t.description);
      _dueDate = t.dueDate;
      _status = t.status;
      _blockedById = t.blockedById;
    } else {
      // For new tasks, load draft
      final draft = context.read<DraftProvider>();
      _titleCtrl = TextEditingController(text: draft.title);
      _descCtrl = TextEditingController(text: draft.description);
      _dueDate = DateTime.now().add(const Duration(days: 1));
      _status = TaskStatus.todo;
      _blockedById = null;
    }

    // Auto-save draft while typing (new tasks only)
    if (!widget.isEditing) {
      _titleCtrl.addListener(_saveDraft);
      _descCtrl.addListener(_saveDraft);
    }
  }

  void _saveDraft() {
    context.read<DraftProvider>().saveDraft(
          title: _titleCtrl.text,
          description: _descCtrl.text,
        );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<TaskProvider>();

    if (widget.isEditing) {
      final updated = widget.existingTask!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        dueDate: _dueDate,
        status: _status,
        blockedById: _blockedById,
        clearBlockedBy: _blockedById == null,
      );
      await provider.updateTask(updated);
    } else {
      await provider.createTask(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        dueDate: _dueDate,
        status: _status,
        blockedById: _blockedById,
      );
      // Clear draft on successful create
      if (mounted) context.read<DraftProvider>().clearDraft();
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final taskProvider = context.watch<TaskProvider>();

    // Available tasks for "Blocked By" dropdown (excluding self)
    final otherTasks = taskProvider.allTasks
        .where((t) => t.id != widget.existingTask?.id && !t.isDone)
        .toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Title ─────────────────────────────────────────────────────
            const _FormLabel('Title'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'What needs to be done?',
                prefixIcon: Icon(Icons.title_rounded, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 20),

            // ── Description ───────────────────────────────────────────────
            const _FormLabel('Description'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add details…',
                alignLabelWithHint: true,
              ),
              textInputAction: TextInputAction.newline,
            ),

            const SizedBox(height: 20),

            // ── Due Date ──────────────────────────────────────────────────
            const _FormLabel('Due Date'),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 18, color: color.primary),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMM d, y').format(_dueDate),
                      style: theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: color.onSurface.withValues(alpha: 0.3)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Status ────────────────────────────────────────────────────
            const _FormLabel('Status'),
            const SizedBox(height: 6),
            Row(
              children: TaskStatus.values.map((s) {
                final isSelected = _status == s;
                final statusColor = AppTheme.statusColor(s.label);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: s == TaskStatus.values[1] ? 8.0 : 0.0),
                    child: InkWell(
                      onTap: () => setState(() => _status = s),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? statusColor.withValues(alpha: 0.1) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? statusColor : const Color(0xFFE0E0E0),
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(AppTheme.statusIcon(s.label),
                                size: 24, color: isSelected ? statusColor : Colors.grey),
                            const SizedBox(height: 6),
                            Text(
                              s.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? statusColor : Colors.grey.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Blocked By ────────────────────────────────────────────────
            const _FormLabel('Blocked By (Optional)'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: _blockedById,
                  isExpanded: true,
                  hint: const Text('No dependency'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('— None —'),
                    ),
                    ...otherTasks.map(
                      (t) => DropdownMenuItem<String?>(
                        value: t.id,
                        child: Row(
                          children: [
                            Icon(AppTheme.statusIcon(t.status.label),
                                size: 14, color: AppTheme.statusColor(t.status.label)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                t.title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _blockedById = v),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Save button ───────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(
                _isSaving ? 'Saving…' : (widget.isEditing ? 'Update Task' : 'Create Task'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge!.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
    );
  }
}