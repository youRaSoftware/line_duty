import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'app_pressable.dart';

/// Квадратная иконка-кнопка (спека: звук / настройки 150×150 r36, пауза
/// 88×88 r24): прозрачная, обводка [AppColors.stroke]. При нажатии
/// заливается панелью и сжимается до 90 %.
class IconSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;

  const IconSquareButton({
    required this.icon,
    required this.onPressed,
    this.size = AppDimens.iconButtonSize,
    this.iconSize = 24,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onPressed: onPressed,
      builder: (BuildContext context, double pressed, Widget? _) {
        return Transform.scale(
          scale: 1 - 0.1 * pressed,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.24),
              color: AppColors.panel.withValues(alpha: pressed),
              border: Border.all(
                color: AppColors.stroke,
                width: AppDimens.strokeWidth,
              ),
            ),
            child: Icon(icon, size: iconSize, color: AppColors.textSecondary),
          ),
        );
      },
    );
  }
}
