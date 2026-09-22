import 'dart:math' as math;
import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';

import 'field_skin.dart';

/// «Аквариум» — рыбки (спека § 4.2, референсы 7e / 6d). Рыбка плывёт
/// головой по направлению движения: тело Ø100 px (r 16.7 ед.), хвост
/// 40×64 (13.3×21.3) виляет, спинной плавник, глаз Ø18 (6). Ворота — грот:
/// арка с обводкой цветом потока и тёмным нутром. Декор — лучи света,
/// всплывающие пузырьки, песчаное дно, волна поверхности.
class AquariumSkin extends FieldSkin {
  static const double _body = 16.7;

  const AquariumSkin();

  @override
  String get id => 'aquarium';

  @override
  void paintUnit(
    Canvas canvas, {
    required Offset center,
    required double angle,
    required LaneColor color,
    double time = 0,
  }) {
    final Color body = AppColors.lane(color);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    // Хвост: треугольник у кормы, виляет вокруг точки крепления.
    final double wag = 0.35 * math.sin(time * 9);
    canvas.save();
    canvas.translate(-_body + 3, 0);
    canvas.rotate(wag);
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(-13.3, -10.7)
        ..lineTo(-13.3, 10.7)
        ..close(),
      Paint()..color = body,
    );
    canvas.restore();
    // Спинной плавник.
    canvas.drawPath(
      Path()
        ..moveTo(-6, -_body + 2)
        ..lineTo(2, -_body - 5)
        ..lineTo(7, -_body + 3)
        ..close(),
      Paint()..color = body,
    );
    canvas.drawCircle(Offset.zero, _body, Paint()..color = body);
    // Глаз у головы (+X).
    canvas.drawCircle(
      Offset(_body * 0.55, -_body * 0.35),
      3,
      Paint()..color = AppColors.current.bgFieldEnd ?? AppColors.bgField,
    );
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
    const double stroke = 4;
    // Арка 190×105 px (63.3×35 ед.) от нижней кромки, обводка 12 px.
    final double w = 63.3 - stroke;
    final double left = (size.width - w) / 2;
    final double top = size.height - 35 + stroke / 2;
    final double r = w / 2;
    final Path arch = Path()
      ..moveTo(left, size.height)
      ..lineTo(left, top + r)
      ..arcTo(
        Rect.fromCircle(center: Offset(left + r, top + r), radius: r),
        math.pi,
        math.pi,
        false,
      )
      ..lineTo(left + w, size.height);
    canvas.drawPath(arch, Paint()..color = AppColors.structure);
    // Взведение / вспышка — подсветка нутра цветом потока.
    canvas.drawPath(
      arch,
      Paint()..color = c.withValues(alpha: (fill - 0.16).clamp(0, 0.5)),
    );
    canvas.drawPath(
      arch,
      Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
    LaneGlyphPainter.draw(
      canvas,
      color.glyph,
      center: Offset(size.width / 2, size.height - 13),
      radius: 7,
      color: AppColors.textPrimary,
      filled: true,
    );
  }

  @override
  void paintDecor(Canvas canvas, Size field, {double time = 0}) {
    final double w = field.width;
    final double h = field.height;
    // Два луча света сверху.
    final Paint ray = Paint()..color = AppColors.decor.withValues(alpha: 0.05);
    for (final (double x, double width) in <(double, double)>[
      (w * 0.12, 70),
      (w * 0.55, 46),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 0)
          ..lineTo(x + width, 0)
          ..lineTo(x + width + w * 0.3, h)
          ..lineTo(x + w * 0.3 - width * 0.4, h)
          ..close(),
        ray,
      );
    }
    // Песчаное дно и волна поверхности.
    canvas.drawRect(
      Rect.fromLTWH(0, h - 30, w, 30),
      Paint()..color = AppColors.decor2,
    );
    final Path wave = Path()..moveTo(0, 14);
    for (double x = 0; x <= w; x += 6) {
      wave.lineTo(x, 14 + 2.5 * math.sin(x / 18 + time * 1.2));
    }
    canvas.drawPath(
      wave,
      Paint()
        ..color = AppColors.decor.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    // Пузырьки-кольца всплывают; позиции детерминированы по индексу.
    final Paint bubble = Paint()
      ..color = AppColors.textSecondary.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (int i = 0; i < 9; i++) {
      final double x = w * ((i * 0.37 + 0.08) % 1);
      final double speed = 9 + (i % 3) * 3;
      final double span = h + 20;
      final double y = h - ((time * speed + i * 97) % span) + 10;
      final double r = 2 + (i % 4);
      canvas.drawCircle(Offset(x + 4 * math.sin(time + i), y), r, bubble);
    }
  }
}
