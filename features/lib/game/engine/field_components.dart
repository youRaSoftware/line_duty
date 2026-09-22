import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flame/components.dart';

/// Ворота потока (спека: 200×130 r24, обводка 8 px цветом, заливка 16 %,
/// внутри — залитый белый значок). [pulse] — вспышка при доставке.
class GateComponent extends PositionComponent {
  final LaneColor color;
  double pulse = 0;

  GateComponent({required this.color, required Vector2 position})
      : super(
          position: position,
          size: Vector2(AppDimens.gateWidth, AppDimens.gateHeight),
          anchor: Anchor.center,
        );

  /// Верхняя кромка ворот в координатах поля — линия, за которой фигура
  /// либо доставлена, либо разбита.
  double get top => position.y - size.y / 2;

  bool containsX(double x) => (x - position.x).abs() <= size.x / 2;

  @override
  void update(double dt) {
    if (pulse > 0) pulse = (pulse - dt * 2.2).clamp(0, 1);
  }

  @override
  void render(Canvas canvas) {
    final Color c = AppColors.lane(color);
    final Rect rect = Offset.zero & size.toSize();
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(AppDimens.gateRadius),
    );
    canvas.drawRRect(
      rrect,
      Paint()..color = c.withValues(alpha: 0.16 + 0.5 * pulse),
    );
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
      color: AppColors.white,
      filled: true,
    );
  }
}

/// Спавн (спека: 160×88 r20, заливка `panel`, обводка 4 px `stroke`) с
/// шевроном вниз под ним.
class SpawnerComponent extends PositionComponent {
  SpawnerComponent({required Vector2 position})
      : super(
          position: position,
          size: Vector2(AppDimens.spawnWidth, AppDimens.spawnHeight),
          anchor: Anchor.center,
        );

  /// Где появляется фигура: сразу под спавном.
  Vector2 get exit =>
      position + Vector2(0, size.y / 2 + AppDimens.unitSize / 2);

  @override
  void render(Canvas canvas) {
    final Rect rect = Offset.zero & size.toSize();
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(AppDimens.spawnRadius),
    );
    canvas.drawRRect(rrect, Paint()..color = AppColors.panel);
    final Paint stroke = Paint()
      ..color = AppColors.stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(rrect, stroke);
    // Шеврон под спавном.
    final double cx = rect.center.dx;
    final double y = rect.bottom + 8;
    canvas.drawPath(
      Path()
        ..moveTo(cx - 6, y)
        ..lineTo(cx, y + 5)
        ..lineTo(cx + 6, y),
      stroke..strokeWidth = 2,
    );
  }
}
