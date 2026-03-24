// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import 'package:task_management_app/ theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isBlocked;
  final String? blockerTitle;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.isBlocked,
    this.blockerTitle,
    required this.searchQuery,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme;

    final isOverdue =
        !task.isDone && task.dueDate.isBefore(DateTime.now());

    final statusColor = isBlocked
        ? AppTheme.colorBlocked
        : AppTheme.statusColor(task.status.label);

    return Opacity(
      opacity: isBlocked ? 0.55 : 1.0,
      child: Card(
        elevation: 4,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isBlocked ? null : onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 Gradient top bar
              Container(
                height: 5,
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
                padding:
                    const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🎯 Title row
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color:
                                statusColor.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Icon(
                            AppTheme.statusIcon(
                                task.status.label),
                            size: 18,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Title
                        Expanded(
                          child: _HighlightedText(
                            text: task.title,
                            query: searchQuery,
                            style: theme.textTheme.titleMedium!
                                .copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: isBlocked
                                  ? color.onSurface
                                      .withValues(alpha: 0.5)
                                  : color.onSurface,
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                            highlightColor:
                                color.primaryContainer,
                          ),
                        ),

                        // Delete button
                        InkWell(
                          borderRadius:
                              BorderRadius.circular(10),
                          onTap: isBlocked ? null : onDelete,
                          child: Padding(
                            padding:
                                const EdgeInsets.all(6),
                            child: Icon(
                              Icons
                                  .delete_outline_rounded,
                              size: 18,
                              color: color.onSurface
                                  .withValues(alpha: 0.35),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 📝 Description
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 40),
                        child: Text(
                          task.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall!
                              .copyWith(
                            color: color.onSurface
                                .withValues(alpha: 0.6),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // 🏷 Chips
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 40),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _ModernChip(
                            label: task.status.label,
                            color: statusColor,
                          ),
                          _ModernChip(
                            icon:
                                Icons.calendar_today_rounded,
                            label: DateFormat('MMM d')
                                .format(task.dueDate),
                            color: isOverdue
                                ? Colors.red
                                : color.onSurface
                                    .withValues(alpha: 0.5),
                          ),
                          if (isBlocked &&
                              blockerTitle != null)
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