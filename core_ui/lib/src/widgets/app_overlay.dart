import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Модальный оверлей поверх игры: затемнение [AppColors.scrim] и по центру
/// либо панель [AppColors.panel] с обводкой (пауза, подтверждения), либо
/// [panel] = false — содержимое прямо на затемнении (экран проигрыша,
/// спека 2a). Появляется с анимацией: затемнение проявляется, содержимое
/// всплывает с лёгким overshoot.
class AppOverlay extends StatelessWidget {
  static const Duration duration = Duration(milliseconds: 280);

  final Widget child;
  final double width;
  final bool panel;

  const AppOverlay({
    required this.child,
    this.width = 300,
    this.panel = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double t, Widget? child) {
        final double pop = Curves.easeOutBack.transform(t);
        return ColoredBox(
          color: AppColors.scrim.withValues(alpha: AppColors.scrim.a * t),
          child: Center(
            child: Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - pop)),
                child: Transform.scale(scale: 0.94 + 0.06 * pop, child: child),
              ),
            ),
          ),
        );
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(AppDimens.panelPadding),
        decoration: panel
            ? BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(AppDimens.panelRadius),
                border: Border.all(
                  color: AppColors.stroke,
                  width: AppDimens.strokeWidth,
                ),
              )
            : null,
        child: child,
      ),
    );
  }
}
