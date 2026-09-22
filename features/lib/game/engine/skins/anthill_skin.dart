import 'dart:math' as math;
import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';

import 'field_skin.dart';

/// «Муравейник» — муравьи (спека § 4.3, референсы 7f / 6e). Муравей идёт
/// головой по направлению движения: брюшко-эллипс 112×72 px (37.3×24 ед.)
/// цветом потока, голова Ø52 (r 8.7) с обводкой, шесть лапок и усики
/// переставляются двухкадровым шагом. Ворота — холмик с тёмным входом и
/// кольцом цветом потока. Декор — пятна и камешки.
class AnthillSkin extends FieldSkin {
  const AnthillSkin();

  @override
  String get id => 'anthill';

  @override
  void paintUnit(
    Canvas canvas, {
    required Offset center,
    required double angle,
    required LaneColor color,
    double time = 0,
  }) {
    final Color body = AppColors.lane(color);
    final Color dark = AppColors.textPrimary;
    final Paint line = Paint()
      ..color = dark
      ..strokeWidth = 2.3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    // Два кадра шага: чётные лапки вперёд, нечётные назад, и наоборот.
    final int frame = (time * 6).floor() % 2;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    // Лапки от груди (x ≈ 2): три пары, у каждой свой наклон.
    for (int i = 0; i < 3; i++) {
      final double base = 0.35 - i * 0.35; // вперёд → назад
      final double step = ((i + frame) % 2 == 0 ? 0.18 : -0.18);
      for (final double side in <double>[-1, 1]) {
        final double a = -side * (math.pi / 2 - base - step);
        // Колено за бортом брюшка (полуширина 12), стопа ещё дальше.
        final Offset knee = Offset(2 + 14 * math.cos(a), 14 * math.sin(a));
        final Offset foot = knee +
            Offset(8 * math.cos(a + side * 0.6), 8 * math.sin(a + side * 0.6));
        canvas.drawLine(const Offset(2, 0), knee, line);
        canvas.drawLine(knee, foot, line);
      }
    }
    // Усики от головы.
    for (final double side in <double>[-1, 1]) {
      canvas.drawLine(
        const Offset(22, 0),
        Offset(32, side * 9),
        line..strokeWidth = 1.8,
      );
    }
    line.strokeWidth = 1.3;
    // Брюшко сзади, грудь, голова спереди.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-8, 0), width: 37.3, height: 24),
      Paint()..color = body,
    );
    canvas.drawCircle(const Offset(8, 0), 6, Paint()..color = body);
    canvas.drawCircle(const Offset(8, 0), 6, line);
    canvas.drawCircle(const Offset(17.5, 0), 8.7, Paint()..color = body);
    canvas.drawCircle(const Offset(17.5, 0), 8.7, line);
    canvas.restore();
    // Значок — в брюшке, без поворота.
    final Offset back = Offset(math.cos(angle), math.sin(angle)) * -8;
    LaneGlyphPainter.draw(
      canvas,
      color.glyph,
      center: center + back,
      radius: AppDimens.unitSize / 2 * 0.4,
      color: AppColors.glyph,
      strokeWidth: 2,
    );
  }

  @override
  void paintGate(
    Canvas canvas, {
    required Size size,
    required LaneColor color,
    required double fill,
  }) {
    final Color c = AppColors.lane(color);
    // Холмик: купол от нижней кромки.
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height)
        ..quadraticBezierTo(
            size.width * 0.5, -size.height * 0.5, size.width, size.height)
        ..close(),
      Paint()..color = AppColors.structure,
    );
    // Вход Ø88 px (r 14.7) с кольцом цветом потока; взведение — ярче кольцо.
    final Offset hole = Offset(size.width / 2, size.height - 16);
    canvas.drawCircle(hole, 14.7, Paint()..color = AppColors.textPrimary);
    canvas.drawCircle(
      hole,
      14.7,
      Paint()..color = c.withValues(alpha: (fill - 0.16).clamp(0, 0.5)),
    );
    canvas.drawCircle(
      hole,
      12.7,
      Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    LaneGlyphPainter.draw(
      canvas,
      color.glyph,
      center: hole,
      radius: 5.5,
      color: AppColors.glyph,
      filled: true,
    );
  }

  @override
  void paintDecor(Canvas canvas, Size field, {double time = 0}) {
    final double w = field.width;
    final double h = field.height;
    final Paint spot = Paint()..color = AppColors.decor;
    for (final (double x, double y, double rw, double rh)
        in <(double, double, double, double)>[
      (w * 0.12, h * 0.42, 190, 130),
      (w * 0.86, h * 0.62, 200, 150),
      (w * 0.4, h * 0.12, 120, 70),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: rw, height: rh),
        spot,
      );
    }
    final Paint pebble = Paint()..color = AppColors.decor2;
    for (int i = 0; i < 10; i++) {
      final double x = w * ((i * 0.43 + 0.1) % 1);
      final double y = h * ((i * 0.29 + 0.15) % 1);
      canvas.drawCircle(Offset(x, y), 3 + (i % 3) * 1.5, pebble);
    }
  }
}
