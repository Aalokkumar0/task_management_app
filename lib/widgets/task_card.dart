// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import 'package:task_management_app/ theme/app_theme.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final bool isBlocked;
  final String? blockerTitle;
  final String searchQuery;
  final VoidCallback onTap;
  final ValueChanged<bool>? onToggleDone;

  const TaskCard({
    super.key,
    required this.task,
    required this.isBlocked,
    this.blockerTitle,
    required this.searchQuery,
    required this.onTap,
    this.onToggleDone,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;
  bool _isVisible = false;
  bool? _localIsDone;

  bool get _isCurrentlyDone => _localIsDone ?? widget.task.isDone;

  void _handleToggle(bool? value) {
    if (value == null) return;
    setState(() => _localIsDone = value);
    if (widget.onToggleDone != null) {
      widget.onToggleDone!(value);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isVisible = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(_) {
    if (!widget.isBlocked) _controller.forward();
  }

  void _onPointerUp(_) {
    if (!widget.isBlocked) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;
    final task = widget.task;
    final isBlocked = widget.isBlocked;

    final isOverdue = !task.isDone && task.dueDate.isBefore(DateTime.now());

    final statusColor = isBlocked
        ? AppTheme.colorBlocked
        : AppTheme.statusColor(task.status.label);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _isVisible ? (isBlocked ? 0.55 : 1.0) : 0.0,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isVisible ? 0 : 20, 0),
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) => _onPointerDown(_),
            onTapUp: (_) {
              _onPointerUp(_);
              if (!isBlocked) widget.onTap();
            },
            onTapCancel: () => _onPointerUp(null),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Card(
                elevation: _isHovered ? 6 : 2,
                shadowColor: color.shadow.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _isHovered
                        ? statusColor.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 Gradient top bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: _isHovered ? 8 : 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor,
                            statusColor.withValues(alpha: 0.6),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🎯 Title row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: _isCurrentlyDone,
                                  onChanged: isBlocked ? null : _handleToggle,
                                  activeColor: AppTheme.colorDone,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  side: BorderSide(color: statusColor.withValues(alpha: 0.5), width: 2),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Title
                              Expanded(
                                child: _HighlightedText(
                                  text: task.title,
                                  query: widget.searchQuery,
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    fontWeight: _isCurrentlyDone ? FontWeight.w500 : FontWeight.w700,
                                    letterSpacing: 0.2,
                                    color: isBlocked
                                        ? color.onSurface.withValues(alpha: 0.5)
                                        : (_isCurrentlyDone ? color.onSurface.withValues(alpha: 0.4) : color.onSurface),
                                    decoration: _isCurrentlyDone
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                  highlightColor: color.primaryContainer,
                                ),
                              ),
                            ],
                          ),

                          // 📝 Description
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 40),
                              child: Text(
                                task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall!.copyWith(
                                  color: color.onSurface.withValues(alpha: 0.6),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),

                          // 🏷 Chips
                          Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                _ModernChip(
                                  label: task.status.label,
                                  color: statusColor,
                                ),
                                _ModernChip(
                                  icon: Icons.calendar_today_rounded,
                                  label: DateFormat('MMM d').format(task.dueDate),
                                  color: isOverdue
                                      ? Colors.red
                                      : color.onSurface.withValues(alpha: 0.5),
                                ),
                                if (isBlocked && widget.blockerTitle != null)
                                  const _ModernChip(
                                    icon: Icons.lock_rounded,
                                    label: 'Blocked',
                                    color: Colors.redAccent,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 🔍 Highlight text
class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final Color highlightColor;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index =
          lowerText.indexOf(lowerQuery, start);

      if (index == -1) {
        spans.add(TextSpan(
            text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(
            text: text.substring(start, index)));
      }

      spans.add(
        TextSpan(
          text: text.substring(
              index, index + query.length),
          style: style.copyWith(
            backgroundColor: highlightColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

      start = index + query.length;
    }

    return Text.rich(
      TextSpan(style: style, children: spans),
    );
  }
}

// 🏷 Modern chip
class _ModernChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _ModernChip({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}