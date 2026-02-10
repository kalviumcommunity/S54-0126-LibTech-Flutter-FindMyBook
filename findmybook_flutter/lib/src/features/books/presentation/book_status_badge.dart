import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class BookStatusBadge extends StatelessWidget {
  final bool available;
  const BookStatusBadge({Key? key, required this.available}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.success : AppColors.errorLight;
    final text = available ? 'Available' : 'Checked out';
    final icon = available ? Icons.check_circle : Icons.cancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(text, style: AppTypography.bodySmall.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
