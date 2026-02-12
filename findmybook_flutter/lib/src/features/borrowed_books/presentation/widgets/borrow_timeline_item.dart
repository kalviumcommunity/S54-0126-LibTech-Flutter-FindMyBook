import 'package:flutter/material.dart';
import '../../domain/entities/borrow.dart';

/// Timeline item widget for borrowing history
/// Displays a borrow record in a timeline format with connecting lines
class BorrowTimelineItem extends StatelessWidget {
  final Borrow borrow;
  final bool isFirst;
  final bool isLast;

  const BorrowTimelineItem({
    required this.borrow,
    required this.isFirst,
    required this.isLast,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline connector and dot
        Column(
          children: [
            // Top connector line (hidden for first item)
            if (!isFirst)
              Container(
                width: 2,
                height: 16,
                color: Colors.grey.shade300,
              ),

            // Dot
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getDotColor(),
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getDotColor().withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Bottom connector line (hidden for last item)
            if (!isLast)
              Container(
                width: 2,
                height: 16,
                color: Colors.grey.shade300,
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildCard(context),
          ),
        ),
      ],
    );
  }

  /// Build the timeline card
  Widget _buildCard(BuildContext context) {
    return Card(
      elevation: borrow.isOverdue ? 2 : 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borrow.isOverdue ? Colors.red.shade200 : Colors.transparent,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book title and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        borrow.bookTitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        borrow.bookAuthor,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusChip(),
              ],
            ),

            const SizedBox(height: 10),

            // Dates
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildDateRow(
                    context,
                    'Borrowed',
                    borrow.borrowedAt,
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildDateRow(
                    context,
                    'Due',
                    borrow.dueDate,
                    Icons.event_available,
                    textColor: borrow.isOverdue ? Colors.red : null,
                  ),
                ),
              ],
            ),

            // Returned date (if applicable)
            if (borrow.returnedAt != null) ...[
              const SizedBox(height: 8),
              _buildDateRow(
                context,
                'Returned',
                borrow.returnedAt!,
                Icons.check_circle,
                textColor: Colors.green,
              ),
            ],

            // Duration info
            const SizedBox(height: 8),
            _buildDurationInfo(context),
          ],
        ),
      ),
    );
  }

  /// Build status chip
  Widget _buildStatusChip() {
    final color = borrow.isOverdue
        ? Colors.red
        : borrow.isActive
            ? Colors.blue
            : Colors.green;

    final icon = borrow.isOverdue
        ? Icons.warning_amber
        : borrow.isActive
            ? Icons.hourglass_bottom
            : Icons.check_circle;

    final label = borrow.isOverdue
        ? 'Overdue'
        : borrow.isActive
            ? 'Active'
            : 'Returned';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build date row widget
  Widget _buildDateRow(
    BuildContext context,
    String label,
    DateTime date,
    IconData icon, {
    Color? textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: textColor ?? Colors.grey.shade600),
        const SizedBox(width: 4),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build duration info
  Widget _buildDurationInfo(BuildContext context) {
    final borrowDays = borrow.dueDate.difference(borrow.borrowedAt).inDays;
    final daysBorrowed = (borrow.returnedAt ?? DateTime.now())
        .difference(borrow.borrowedAt)
        .inDays;

    String durationText;
    if (borrow.returnedAt != null) {
      durationText = 'Kept for $daysBorrowed days (borrowed for $borrowDays days)';
    } else if (borrow.isOverdue) {
      final overdaysDays = DateTime.now().difference(borrow.dueDate).inDays;
      durationText = 'Overdue by $overdaysDays days';
    } else {
      final daysRemaining = borrow.daysRemaining;
      durationText = '$daysRemaining days remaining (of $borrowDays days)';
    }

    return Text(
      durationText,
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade600,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  /// Get dot color based on borrow status
  Color _getDotColor() {
    if (borrow.isOverdue) {
      return Colors.red;
    } else if (borrow.isActive) {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
