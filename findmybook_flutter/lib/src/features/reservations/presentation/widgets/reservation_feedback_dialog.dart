import 'package:flutter/material.dart';

/// Reservation feedback dialog for success or error
class ReservationFeedbackDialog extends StatelessWidget {
  final bool success;
  final String? message;
  final VoidCallback? onClose;

  const ReservationFeedbackDialog({
    Key? key,
    required this.success,
    this.message,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(success ? 'Reservation Successful' : 'Reservation Failed'),
        ],
      ),
      content: Text(message ?? (success
          ? 'Your book has been reserved!'
          : 'Could not reserve the book. Please try again.')),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (onClose != null) onClose!();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
