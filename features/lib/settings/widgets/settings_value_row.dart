import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Строка «подпись — значение» (статистика, версия).
class SettingsValueRow extends StatelessWidget {
  final String label;
  final String value;

  const SettingsValueRow({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppDimens.minTapTarget),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: AppFonts.body)),
          Text(
            value,
            style: AppFonts.score.copyWith(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
