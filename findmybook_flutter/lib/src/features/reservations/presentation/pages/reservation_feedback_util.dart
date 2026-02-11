import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../domain/entities/reservation.dart';
import '../widgets/reservation_feedback_dialog.dart';

/// Utility to show reservation feedback after attempting reservation
Future<void> showReservationFeedback({
  required BuildContext context,
  required String bookId,
  required String bookTitle,
  required String bookAuthor,
}) async {
  bool success = false;
  String? message;
  try {
    final callable = FirebaseFunctions.instance.httpsCallable('reserveBook');
    final result = await callable.call({'bookId': bookId});
    success = true;
    message = 'Your reservation for "$bookTitle" is confirmed!\nExpires at: '
      '${result.data['expiresAt'] ?? ''}';
  } catch (e) {
    success = false;
    message = e is FirebaseFunctionsException
      ? e.message
      : 'Could not reserve the book. Please try again.';
  }
  if (context.mounted) {
    showDialog(
      context: context,
      builder: (ctx) => ReservationFeedbackDialog(
        success: success,
        message: message,
      ),
    );
  }
}
