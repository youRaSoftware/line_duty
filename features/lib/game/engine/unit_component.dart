import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flame/components.dart';

import 'game_tuning.dart';
import 'line_duty_game.dart';

/// Точка стёртого следа: где фигура проехала и когда.
class TracePoint {
  final Vector2 point;
  final double time;

  const TracePoint(this.point, this.time);
}

/// Фигура потока: едет сама по [heading] (по умолчанию вниз); если игрок
/// нарисовал [route], едет по нему, съедая точки и оставляя [trace]. За
/// концом маршрута продолжает в направлении последнего отрезка. Боковые
/// края поля разворачивают её вниз. Ворота проверяет игра.
class UnitComponent extends PositionComponent
    with HasGameReference<LineDutyGame> {
  final LaneColor color;
  final Vector2 heading = Vector2(0, 1);
  final List<Vector2> route = <Vector2>[];
  final List<TracePoint> trace = <TracePoint>[];

  /// Фигура уже сталкивалась (заморожена вспышкой).
  bool crashed = false;

  /// Сколько маршрутов игрок нарисовал этой фигуре (демо рисует само).
  int routesDrawn = 0;

  UnitComponent({required this.color, required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(AppDimens.unitSize),
          anchor: Anchor.center,
        );

  double get radius => AppDimens.unitSize / 2;

  /// Новый маршрут игрока: старый стирается, след остаётся.
  void beginRoute() {
    route.clear();
    routesDrawn++;
  }

  void addRoutePoint(Vector2 p) {
    final Vector2 last = route.isEmpty ? position : route.last;
    if (last.distanceTo(p) < GameTuning.routePointSpacing) return;
    route.add(p.clone());
  }

  @override
  void update(double dt) {
    if (crashed || game.frozen) return;
    double remaining = game.unitSpeed * dt;
    while (remaining > 0 && route.isNotEmpty) {
      final Vector2 to = route.first - position;
      final double dist = to.length;
      if (dist < 1e-3) {
        _consume();
        continue;
      }
      heading.setFrom(to / dist);
      if (dist <= remaining) {
        position.setFrom(route.first);
        remaining -= dist;
        _consume();
      } else {
        position.add(heading * remaining);
        remaining = 0;
      }
    }
    if (remaining > 0) position.add(heading * remaining);
    _keepInside();
    _pruneTrace();
  }

  void _consume() {
    trace.add(TracePoint(route.removeAt(0), game.time));
  }

  void _pruneTrace() {
    final double cutoff = game.time - GameTuning.traceSeconds;
    while (trace.isNotEmpty && trace.first.time < cutoff) {
      trace.removeAt(0);
    }
  }

  /// Боковые и верхний края: фигура прижимается и едет вниз.
  void _keepInside() {
    final double w = game.fieldWidth;
    bool bumped = false;
    if (position.x < radius) {
      position.x = radius;
      bumped = true;
    } else if (position.x > w - radius) {
      position.x = w - radius;
      bumped = true;
    }
    if (position.y < radius) {
      position.y = radius;
      bumped = true;
    }
    if (bumped) {
      heading.setValues(0, 1);
      route.clear();
    }
  }

  @override
  void render(Canvas canvas) {
    final Color fill = AppColors.lane(color);
    final Rect rect = Offset.zero & size.toSize();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          rect, const Radius.circular(AppDimens.unitRadius)),
      Paint()..color = fill,
    );
    LaneGlyphPainter.draw(
      canvas,
      color.glyph,
      center: rect.center,
      radius: radius * 0.42,
      color: AppColors.white,
      strokeWidth: 2,
    );
  }
}
