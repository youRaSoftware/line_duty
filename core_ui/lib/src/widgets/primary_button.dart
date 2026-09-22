import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_fonts.dart';
import 'app_pressable.dart';
import 'button_label.dart';

/// Светлая кнопка (спека: «Играть» 720×190 r44 со свечением 18 %, «Заново»
/// 660×150 r36): заливка [AppColors.buttonLight], текст [AppColors.bgField].
/// При нажатии сжимается до 97 % и слегка темнеет. [glow] — мягкое свечение
/// вокруг (только у «Играть»).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double radius;
  final bool glow;
  final Widget? icon;

  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.height = AppDimens.buttonHeight,
    this.radius = AppDimens.buttonRadius,
    this.glow = false,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    return AppPressable(
      onPressed: onPressed,
      child: ButtonLabel(label: label, style: AppFonts.button, icon: icon),
      builder: (BuildContext context, double pressed, Widget? child) {
        return Transform.scale(
          scale: 1 - 0.03 * pressed,
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Container(
              height: height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: Color.lerp(
                  AppColors.buttonLight,
                  AppColors.textSecondary,
                  0.25 * pressed,
                ),
                boxShadow: glow
                    ? <BoxShadow>[
                        BoxShadow(
                          color: AppColors.buttonLight.withValues(alpha: 0.18),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
