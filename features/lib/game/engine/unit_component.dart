import 'dart:math' as math;
import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flame/components.dart';

import 'field_components.dart';
import 'game_tuning.dart';
import 'hit_capsule.dart';
import 'line_duty_game.dart';

/// Точка стёртого следа: где фигура проехала и когда.
class TracePoint {
  final Vector2 point;
  final double time;

  const TracePoint(this.point, this.time);
}

/// Фигура потока: едет сама по [heading] (по умолчанию вниз); если игрок
/// нарисовал [route], едет по нему, съедая точки и оставляя [trace]. Маршрут,
/// доведённый до своих ворот, [docked] — заканчивается точкой входа в них.
/// За концом маршрута поворачивает **вниз** (маршрут — временное
/// отклонение), а над своими воротами доворачивает к центру входа (магнит).
/// Боковые края поля разворачивают её вниз. Ворота проверяет игра.
class UnitComponent extends PositionComponent
    with HasGameReference<LineDutyGame> {
  final LaneColor color;
  final Vector2 heading = Vector2(0, 1);
  final List<Vector2> route = <Vector2>[];
  final List<TracePoint> trace = <TracePoint>[];

  /// Ворота, к которым пристыкован маршрут (его последняя точка — вход в
  /// них); null — маршрут не доведён или его нет.
  GateComponent? docked;

  /// Фигура уже сталкивалась (заморожена вспышкой).
  bool crashed = false;

  /// Несёт щит: следующее столкновение прощается.
  bool shielded = false;

  /// После сработавшего щита фигура столько секунд «призрак»: сквозь других.
  double ghostLeft = 0;

  /// Сколько маршрутов игрок нарисовал этой фигуре (демо рисует само).
  int routesDrawn = 0;

  /// Сдвиг фазы анимации спрайта, чтобы фигуры не двигались синхронно.
  final double phase = (identityHashCode(Object()) % 628) / 100;

  UnitComponent({required this.color, required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(AppDimens.unitSize),
          anchor: Anchor.center,
        );

  /// Радиус базового круга (32 ед.): захват пальцем, край поля, ворота.
  double get radius => AppDimens.unitSize / 2;

  /// Хитбокс по силуэту спрайта текущей темы.
  HitCapsule get hitbox => game.skin.hitbox;

  /// Зазор между хитбоксами (< 0 — столкновение).
  double gapTo(UnitComponent other) => HitCapsule.gap(
        hitbox,
        position,
        heading,
        other.hitbox,
        other.position,
        other.heading,
      );

  /// Зазор от хитбокса до точки (< 0 — точка внутри).
  double gapToPoint(Vector2 point) =>
      hitbox.gapToPoint(position, heading, point);

  /// Новый маршрут игрока: старый стирается, след остаётся.
  void beginRoute() {
    route.clear();
    docked = null;
    routesDrawn++;
  }

  void addRoutePoint(Vector2 p) {
    final Vector2 last = route.isEmpty ? position : route.last;
    if (last.distanceTo(p) < GameTuning.routePointSpacing) return;
    route.add(p.clone());
  }

  /// Завершить маршрут входом в [gate]: по X — где палец, но целиком внутри
  /// ворот, по Y — их верхняя кромка. Дальше точки не добавляются.
  void dockTo(GateComponent gate, double x) {
    final double half = gate.size.x / 2 - radius;
    final Vector2 entry = Vector2(
      x.clamp(gate.position.x - half, gate.position.x + half),
      gate.top,
    );
    // Не дублировать вход, если палец уже стоит ровно на нём.
    if (route.isNotEmpty && route.last.distanceTo(entry) < 1e-3) {
      route.removeLast();
    }
    route.add(entry);
    docked = gate;
  }

  @override
  void update(double dt) {
    if (crashed || game.frozen) return;
    if (ghostLeft > 0) ghostLeft = (ghostLeft - dt).clamp(0, ghostLeft);
    if (game.freezeActive) {
      _pruneTrace();
      return;
    }
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
    if (remaining > 0) {
      if (route.isEmpty) heading.setValues(0, 1);
      position.add(heading * remaining);
      if (route.isEmpty) _magnet(dt);
    }
    _keepInside();
    _pruneTrace();
  }

  /// Без маршрута над своими воротами — плавно к центру входа.
  void _magnet(double dt) {
    final GateComponent gate = game.gateFor(color);
    final double dx = gate.position.x - position.x;
    if (position.y >= gate.top ||
        dx.abs() > gate.size.x / 2 + GameTuning.gateMagnetSlack) {
      return;
    }
    final double step = GameTuning.gateMagnetSpeed * dt;
    position.x += dx.clamp(-step, step);
  }

  /// Зазор между хитбоксом и формой базы [gate] (< 0 — задела).
  double gapToGate(GateComponent gate) {
    final (Vector2 p0, Vector2 p1) = hitbox.segment(position, heading);
    double best = double.infinity;
    for (int i = 0; i <= 4; i++) {
      final Vector2 p = p0 + (p1 - p0) * (i / 4);
      best = math.min(best, gate.distanceTo(p));
    }
    return best - hitbox.radius;
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
      docked = null;
    }
  }

  /// Направление движения в радианах (вниз = π/2) — для спрайтов темы.
  /// Сам компонент не вращается (`angle` Flame = 0): хитбокс и значок
  /// остаются осевыми, поворачивает только скин.
  double get headingAngle => math.atan2(heading.y, heading.x);

  @override
  void render(Canvas canvas) {
    final bool ghost = ghostLeft > 0;
    if (ghost) {
      canvas.saveLayer(
        null,
        Paint()..color = const Color(0xFFFFFFFF).withValues(alpha: 0.45),
      );
    }
    game.skin.paintUnit(
      canvas,
      center: Offset(size.x / 2, size.y / 2),
      angle: headingAngle,
      color: color,
      time: game.time + phase,
    );
    if (ghost) canvas.restore();
  }
}
