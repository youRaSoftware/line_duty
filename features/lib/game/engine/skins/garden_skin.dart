import 'dart:math' as math;
import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';

import '../hit_capsule.dart';
import 'field_skin.dart';

/// «Сад» — божьи коровки (спека § 4.4, референс 7g). Панцирь Ø108 px
/// (r 18 ед.) цветом потока, голова-полукруг спереди, центральная линия,
/// четыре точки, лапки и усики. Ворота — лист с пунктирным кольцом цветом
/// потока. Декор — листья и травинки по краям.
class GardenSkin extends FieldSkin {
  static const double _shell = 18;

  const GardenSkin();

  @override
  String get id => 'garden';

  /// Панцирь r 18 — круг чуть меньше; лапки декоративные.
  @override
  HitCapsule get hitbox => const HitCapsule.circle(16.5);

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
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    // Лапки — три пары, чуть шевелятся.
    final double wiggle = 0.12 * math.sin(time * 10);
    for (int i = 0; i < 3; i++) {
      final double base = 0.5 - i * 0.5;
      for (final double side in <double>[-1, 1]) {
        final double a = -side * (math.pi / 2 - base) + wiggle * side;
        final Offset from = Offset(math.cos(a), math.sin(a)) * (_shell - 3);
        final Offset to = Offset(math.cos(a), math.sin(a)) * (_shell + 6);
        canvas.drawLine(from, to, line);
      }
    }
    // Голова-полукруг спереди с усиками.
    canvas.drawCircle(const Offset(_shell - 4, 0), 8, Paint()..color = dark);
    for (final double side in <double>[-1, 1]) {
      canvas.drawLine(
          Offset(_shell + 3, side * 3), Offset(_shell + 9, side * 8), line);
    }
    // Панцирь, центральная линия и четыре точки.
    canvas.drawCircle(Offset.zero, _shell, Paint()..color = body);
    canvas.drawLine(
      const Offset(-_shell, 0),
      const Offset(_shell - 6, 0),
      line..strokeWidth = 1.6,
    );
    final Paint dot = Paint()..color = dark;
    for (final Offset p in const <Offset>[
      Offset(-10, -9),
      Offset(-10, 9),
      Offset(4, -12),
      Offset(4, 12),
    ]) {
      canvas.drawCircle(p, 2.6, dot);
    }
    canvas.restore();
    LaneGlyphPainter.draw(
      canvas,
      color.glyph,
      center: center,
      radius: AppDimens.unitSize / 2 * 0.42,
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
    final Offset centre = Offset(size.width / 2, size.height / 2 + 2);
    // Лист: заострённый эллипс под углом, 35 % цветом листвы.
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(-0.35);
    canvas.drawPath(
      Path()
        ..moveTo(-34, 0)
        ..quadraticBezierTo(0, -24, 34, 0)
        ..quadraticBezierTo(0, 24, -34, 0)
        ..close(),
      Paint()..color = AppColors.structure.withValues(alpha: 0.35),
    );
    canvas.restore();
    // Пунктирное кольцо Ø104 px (r 17.3), штрих 10 px (3.3).
    canvas.drawCircle(
      centre,
      17.3,
      Paint()..color = c.withValues(alpha: (fill - 0.16).clamp(0, 0.5)),
    );
    FieldSkin.dashed(
      canvas,
      Path()..addOval(Rect.fromCircle(center: centre, radius: 17.3)),
      Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.3
        ..strokeCap = StrokeCap.round,
      dash: 5,
      gap: 4.2,
    );
    LaneGlyphPainter.draw(
      canvas,
      color.glyph,
      center: centre,
      radius: 6.5,
      color: AppColors.textPrimary,
      filled: true,
    );
  }

  @override
  void paintDecor(Canvas canvas, Size field, {double time = 0}) {
    final double w = field.width;
    final double h = field.height;
    final Paint leaf = Paint()..color = AppColors.decor;
    // Листья по краям: пары заострённых эллипсов.
    for (final (double x, double y, double a, double s)
        in <(double, double, double, double)>[
      (-10, h * 0.18, 0.5, 1.0),
      (w + 8, h * 0.34, 2.7, 1.2),
      (-6, h * 0.66, 0.2, 0.9),
      (w + 12, h * 0.8, 3.4, 1.1),
    ]) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(a);
      canvas.scale(s);
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(30, -22, 64, 0)
          ..quadraticBezierTo(30, 22, 0, 0)
          ..close(),
        leaf,
      );
      canvas.drawLine(
        Offset.zero,
        const Offset(58, 0),
        Paint()
          ..color = AppColors.decor2
          ..strokeWidth = 1.5,
      );
      canvas.restore();
    }
    // Травинки внизу.
    final Paint grass = Paint()
      ..color = AppColors.decor2
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 14; i++) {
      final double x = w * ((i * 0.23 + 0.03) % 1);
      final double lean = 4 * math.sin(i * 1.7);
      canvas.drawPath(
        Path()
          ..moveTo(x, h)
          ..quadraticBezierTo(x + lean, h - 12, x + lean * 2, h - 22),
        grass,
      );
    }
  }
}
