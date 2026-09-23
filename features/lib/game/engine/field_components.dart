import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flame/components.dart';

import 'gate_shape.dart';
import 'line_duty_game.dart';

/// Ворота потока (спека: зона 200×130; вид рисует скин темы). [pulse] —
/// вспышка при доставке, [armed] — к воротам пристыкован маршрут (заливка
/// ярче).
class GateComponent extends PositionComponent
    with HasGameReference<LineDutyGame> {
  final LaneColor color;
  double pulse = 0;
  bool armed = false;

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

  /// Зона стыковки: над воротами по X и не выше кромки на [margin].
  bool inDockZone(Vector2 p, {double margin = 0}) =>
      containsX(p.x) && p.y >= top - margin;

  /// Форма базы скина в локальных координатах зоны.
  GateShape get shape => game.skin.gateShape;

  Offset _local(Vector2 world) => Offset(
      world.x - position.x + size.x / 2, world.y - position.y + size.y / 2);

  /// Знаковое расстояние от точки мира до формы базы (< 0 — внутри).
  double distanceTo(Vector2 world) =>
      shape.distance(_local(world), size.toSize());

  /// Центр фигуры внутри формы базы (не путать с `containsPoint` Flame).
  bool holds(Vector2 world) => distanceTo(world) <= 0;

  @override
  void update(double dt) {
    if (pulse > 0) pulse = (pulse - dt * 2.2).clamp(0, 1);
  }

  @override
  void render(Canvas canvas) {
    final double base = armed ? 0.34 : 0.16;
    game.skin.paintGate(
      canvas,
      size: size.toSize(),
      color: color,
      fill: base + (0.66 - base) * pulse,
    );
  }
}

/// Спавн (спека: 160×88 r20) с шевроном вниз под ним; вид рисует скин.
class SpawnerComponent extends PositionComponent
    with HasGameReference<LineDutyGame> {
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
  void render(Canvas canvas) => game.skin.paintSpawner(canvas, size.toSize());
}
