import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';

import 'field_skin.dart';

/// «Метро · ночь» (тема A): фигура — скруглённый квадрат цветом потока со
/// значком, ворота — скруглённый прямоугольник с обводкой и залитым
/// значком. Фигура не вращается.
class MetroSkin extends FieldSkin {
  const MetroSkin();

  @override
  String get id => 'metro';

  @override
  void paintUnit(
    Canvas canvas, {
    required Offset center,
    required double angle,
    required LaneColor color,
    double time = 0,
  }) {
    final Rect rect = Rect.fromCenter(
      center: center,
      width: AppDimens.unitSize,
      height: AppDimens.unitSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(AppDimens.unitRadius),
      ),
      Paint()..color = AppColors.lane(color),
    );
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
    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(AppDimens.gateRadius),
    );
    canvas.drawRRect(rrect, Paint()..color = c.withValues(alpha: fill));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.7,
    );
    LaneGlyphPainter.draw(
      canvas,
      color.glyph,
      center: rect.center,
      radius: 7.5,
      color: AppColors.glyph,
      filled: true,
    );
  }
}
