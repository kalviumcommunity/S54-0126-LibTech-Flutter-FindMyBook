import 'package:flutter/material.dart';
import '../../domain/entities/borrow.dart';

/// Card widget for displaying a borrowed book
/// Shows book info, due date, and action buttons
class BorrowCard extends StatelessWidget {
  final Borrow borrow;
  final String userId;
  final VoidCallback onReturn;
  final VoidCallback onRenew;

  const BorrowCard({
    required this.borrow,
    required this.userId,
    required this.onReturn,
    required this.onRenew,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${borrow.bookAuthor}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context),
              ],
            ),
            const SizedBox(height: 12),

            // Dates row
            Row(
              children: [
                Expanded(
                  child: _buildDateInfo(
                    context,
                    'Borrowed',
                    borrow.borrowedAt,
                    Icons.check_circle_outline,
                  ),
                ),
                Expanded(
                  child: _buildDateInfo(
                    context,
                    'Due',
                    borrow.dueDate,
                    Icons.schedule,
                    isOverdue: borrow.isOverdue,
                  ),
                ),
              ],
            ),

            // Days remaining
            if (borrow.isActive) ...[
              const SizedBox(height: 12),
              _buildDaysRemainingBar(context),
            ],

            // Action buttons
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRenew,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Renew'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReturn,
                    icon: const Icon(Icons.check),
                    label: const Text('Return'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build status badge
  Widget _buildStatusBadge(BuildContext context) {
    final color = borrow.isOverdue
        ? Colors.red
        : borrow.isActive
            ? Colors.blue
            : Colors.grey;

    final icon = borrow.isOverdue
        ? Icons.warning
        : borrow.isActive
            ? Icons.check_circle
            : Icons.done_all;

    final label = borrow.isOverdue
        ? 'Overdue'
        : borrow.isActive
            ? 'Active'
            : 'Returned';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build date information widget
  Widget _buildDateInfo(
    BuildContext context,
    String label,
    DateTime date,
    IconData icon, {
    bool isOverdue = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isOverdue ? Colors.red : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _formatDate(date),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isOverdue ? Colors.red : null,
                fontWeight: isOverdue ? FontWeight.bold : null,
              ),
        ),
      ],
    );
  }

  /// Build days remaining progress bar
  Widget _buildDaysRemainingBar(BuildContext context) {
    final daysRemaining = borrow.daysRemaining;
    final maxDays = borrow.dueDate.difference(borrow.borrowedAt).inDays;
    final progress = (maxDays - daysRemaining) / maxDays;

    final progressColor = daysRemaining <= 0
        ? Colors.red
        : daysRemaining <= 3
            ? Colors.orange
            : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Time remaining',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              daysRemaining <= 0
                  ? 'Overdue by ${(-daysRemaining).abs()} days'
                  : '$daysRemaining days left',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }

  /// Format date to readable string (e.g., "Jan 15, 2026")
  String _formatDate(DateTime date) {
    return '${_monthName(date.month)} ${date.day}, ${date.year}';
  }

  /// Get month name
  String _monthName(int month) {
    const month_names = [
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
    return month_names[month - 1];
  }
}
