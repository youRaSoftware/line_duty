import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_fonts.dart';

/// Бейдж «★ НОВЫЙ РЕКОРД» (спека 2a): текст [AppColors.record], заливка
/// 14 %, обводка 4 px, пилюля.
class RecordBadge extends StatelessWidget {
  final String label;

  const RecordBadge({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.record.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.record, width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.star_rounded, size: 18, color: AppColors.record),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppFonts.button.copyWith(
              color: AppColors.record,
              fontSize: 15,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
