import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_fonts.dart';
import 'app_pressable.dart';
import 'button_label.dart';

/// Контурная кнопка (спека: «В меню» 660×150 r36, обводка 5 px
/// [AppColors.strokeSecondary], текст [AppColors.textPrimary]). При нажатии
/// заливается панелью и сжимается до 97 %.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final Widget? icon;

  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.height = AppDimens.buttonHeight,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onPressed: onPressed,
      child: ButtonLabel(
        label: label,
        style: AppFonts.button.copyWith(color: AppColors.textPrimary),
        icon: icon,
      ),
      builder: (BuildContext context, double pressed, Widget? child) {
        return Transform.scale(
          scale: 1 - 0.03 * pressed,
          child: Opacity(
            opacity: onPressed == null ? 0.5 : 1,
            child: Container(
              height: height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                color: AppColors.panel.withValues(alpha: pressed),
                border: Border.all(
                  color: AppColors.strokeSecondary,
                  width: AppDimens.strokeWidth,
                ),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
