import 'dart:math' as math;

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Значок потока — круг / квадрат / треугольник / ромб (спека: белая
/// обводка 6 px холста внутри фигуры; на воротах — заливка). Общий painter
/// для виджетов и движка: [LaneGlyphPainter.draw].
class LaneGlyphIcon extends StatelessWidget {
  final LaneGlyph glyph;
  final double size;
  final bool filled;

  /// null — [AppColors.glyph] текущей темы.
  final Color? color;

  const LaneGlyphIcon({
    required this.glyph,
    this.size = 16,
    this.filled = false,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _GlyphPainter(
        glyph: glyph,
        filled: filled,
        color: color ?? AppColors.glyph,
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  final LaneGlyph glyph;
  final bool filled;
  final Color color;

  const _GlyphPainter({
    required this.glyph,
    required this.filled,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    LaneGlyphPainter.draw(
      canvas,
      glyph,
      center: Offset(size.width / 2, size.height / 2),
      radius: size.shortestSide / 2,
      color: color,
      filled: filled,
      strokeWidth: size.shortestSide * 0.14,
    );
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.filled != filled || old.color != color;
}

abstract final class LaneGlyphPainter {
  /// Рисует значок [glyph] вписанным в круг радиуса [radius].
  static void draw(
    Canvas canvas,
    LaneGlyph glyph, {
    required Offset center,
    required double radius,
    required Color color,
    bool filled = false,
    double strokeWidth = 2,
  }) {
    final Paint paint = Paint()
      ..color = color
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;
    // Контур рисуется по середине штриха — ужимаем, чтобы вписаться.
    final double r = filled ? radius : radius - strokeWidth / 2;
    switch (glyph) {
      case LaneGlyph.circle:
        canvas.drawCircle(center, r, paint);
      case LaneGlyph.square:
        final double side = r * 1.7;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: center, width: side, height: side),
            Radius.circular(side * 0.18),
          ),
          paint,
        );
      case LaneGlyph.triangle:
        final Path path = Path();
        for (int i = 0; i < 3; i++) {
          final double a = -math.pi / 2 + i * 2 * math.pi / 3;
          final Offset p =
              center + Offset(math.cos(a), math.sin(a)) * (r * 1.08);
          if (i == 0) {
            path.moveTo(p.dx, p.dy);
          } else {
            path.lineTo(p.dx, p.dy);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      case LaneGlyph.diamond:
        final Path path = Path()
          ..moveTo(center.dx, center.dy - r * 1.1)
          ..lineTo(center.dx + r * 1.1, center.dy)
          ..lineTo(center.dx, center.dy + r * 1.1)
          ..lineTo(center.dx - r * 1.1, center.dy)
          ..close();
        canvas.drawPath(path, paint);
    }
  }
}
