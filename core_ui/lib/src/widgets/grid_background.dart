import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Точечная сетка фона (спека: точки Ø7 px с шагом 72 px холста), от
/// центра экрана, чтобы на любой ширине рисунок был симметричен.
class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: GridPainter(color: AppColors.gridDot),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double step;
  final double dot;
  final Color color;

  const GridPainter({
    required this.color,
    this.step = AppDimens.gridStep,
    this.dot = AppDimens.gridDot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;
    final double r = dot / 2;
    final double x0 = (size.width / 2) % step;
    final double y0 = (size.height / 2) % step;
    for (double y = y0; y < size.height; y += step) {
      for (double x = x0; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(GridPainter old) =>
      old.step != step || old.dot != dot || old.color != color;
}
