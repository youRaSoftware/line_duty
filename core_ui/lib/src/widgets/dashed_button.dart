import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_fonts.dart';
import 'app_pressable.dart';
import 'button_label.dart';

/// Пунктирная кнопка «Продолжить · реклама» (спека, экран проигрыша):
/// рамка 4 px [AppColors.strokeSecondary] пунктиром, текст
/// [AppColors.textSecondary]. При нажатии тускнеет.
class DashedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  const DashedButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onPressed: onPressed,
      child: ButtonLabel(
        label: label,
        style: AppFonts.button.copyWith(
          color: AppColors.textSecondary,
          fontSize: 15,
        ),
        icon: icon,
      ),
      builder: (BuildContext context, double pressed, Widget? child) {
        return Opacity(
          opacity: onPressed == null ? 0.5 : 1 - 0.4 * pressed,
          child: CustomPaint(
            painter: const _DashedBorderPainter(),
            child: Container(
              height: AppDimens.minTapTarget,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.strokeSecondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final RRect rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );
    final Path path = Path()..addRRect(rect);
    const double dash = 6;
    const double gap = 4;
    for (final PathMetric metric in path.computeMetrics()) {
      double at = 0;
      while (at < metric.length) {
        canvas.drawPath(metric.extractPath(at, at + dash), paint);
        at += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => true;
}
