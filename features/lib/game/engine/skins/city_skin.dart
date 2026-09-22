import 'dart:math' as math;
import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';

import 'field_skin.dart';

/// «Город» — автобусы (спека § 4.1, референсы 7b / 6b). Автобус 140×84 px
/// холста (46.7×28 ед.) едет носом по направлению движения: лобовое
/// стекло спереди, заднее окно сзади, четыре колеса; значок не вращается и
/// чуть смещён к корме. Ворота — парковочное место (П-обводка, две
/// разметочные черты), декор — светлые линии «схемы».
class CitySkin extends FieldSkin {
  static const double _length = 46.7;
  static const double _width = 28;

  const CitySkin();

  @override
  String get id => 'city';

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
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    // Колёса — под корпусом, торчат за борт.
    final Paint wheel = Paint()..color = dark;
    for (final double x in <double>[-13, 13]) {
      for (final double y in <double>[-_width / 2 - 1, _width / 2 - 3]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x - 4.35, y, 8.7, 4),
            const Radius.circular(1.5),
          ),
          wheel,
        );
      }
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: _length, height: _width),
        const Radius.circular(6),
      ),
      Paint()..color = body,
    );
    // Лобовое стекло спереди (+X), заднее окно сзади.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(_length / 2 - 2 - 6.7, -21.3 / 2, 6.7, 21.3),
        const Radius.circular(2),
      ),
      Paint()..color = dark.withValues(alpha: 0.7),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-_length / 2 + 2, -17.3 / 2, 3.3, 17.3),
        const Radius.circular(1.5),
      ),
      Paint()..color = dark.withValues(alpha: 0.45),
    );
    canvas.restore();
    // Значок — без поворота, на 3 ед. ближе к корме.
    final Offset back = Offset(math.cos(angle), math.sin(angle)) * -3;
    LaneGlyphPainter.draw(
      canvas,
      color.glyph,
      center: center + back,
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
    const double stroke = 2.7;
    final Rect rect = Offset.zero & size;
    // Спека: заливка 12 % в покое; взведение и вспышка поверх.
    canvas.drawRect(
      rect.deflate(stroke / 2),
      Paint()..color = c.withValues(alpha: fill - 0.04),
    );
    final Paint line = Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final double inset = stroke / 2;
    canvas.drawPath(
      Path()
        ..moveTo(inset, 0)
        ..lineTo(inset, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset)
        ..lineTo(size.width - inset, 0),
      line,
    );
    // Разметочные черты у въезда.
    final Paint mark = Paint()
      ..color = c
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (final double x in <double>[12, size.width - 12]) {
      canvas.drawLine(Offset(x, 4), Offset(x, 13), mark);
    }
    LaneGlyphPainter.draw(
      canvas,
      color.glyph,
      center: rect.center.translate(0, 3),
      radius: 7.5,
      color: AppColors.textPrimary,
      filled: true,
    );
  }

  @override
  void paintDecor(Canvas canvas, Size field, {double time = 0}) {
    final double w = field.width;
    final double h = field.height;
    final Paint paint = Paint()
      ..color = AppColors.decor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Вертикальная «ветка» слева с изломом.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.18, 0)
        ..lineTo(w * 0.18, h * 0.26)
        ..lineTo(w * 0.11, h * 0.31)
        ..lineTo(w * 0.11, h),
      paint,
    );
    // Горизонтальная ветка, уходящая вправо-вниз.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.30)
        ..lineTo(w * 0.36, h * 0.30)
        ..lineTo(w * 0.52, h * 0.37)
        ..lineTo(w, h * 0.37),
      paint,
    );
  }
}
