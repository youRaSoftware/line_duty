import 'dart:math' as math;

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:features/game/engine/field_components.dart';
import 'package:features/game/engine/game_tuning.dart';
import 'package:features/game/engine/line_duty_game.dart';
import 'package:features/game/engine/unit_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

class _Listener implements GameListener {
  int delivered = 0;
  int warnings = 0;
  int routes = 0;
  bool? crashWrongGate;

  @override
  void onDelivered() => delivered++;

  @override
  void onWarning() => warnings++;

  @override
  void onRouteStarted() => routes++;

  @override
  void onCrash({required bool wrongGate}) => crashWrongGate = wrongGate;
}

/// Поле 360×780 без спавна (первая фигура через `firstSpawnDelay`, тесты
/// тикают меньше или сами ставят фигуры).
Future<(LineDutyGame, _Listener)> _game({int seed = 1}) async {
  final _Listener listener = _Listener();
  final LineDutyGame game =
      LineDutyGame(listener: listener, random: math.Random(seed));
  game.onGameResize(Vector2(360, 780));
  await game.onLoad();
  game.setInsets(top: 80, bottom: 20);
  return (game, listener);
}

Future<void> _tick(LineDutyGame game, double seconds,
    {double dt = 1 / 60}) async {
  for (double t = 0; t < seconds; t += dt) {
    game.update(dt);
  }
}

UnitComponent _put(LineDutyGame game, LaneColor color, double x, double y) {
  final UnitComponent u = UnitComponent(color: color, position: Vector2(x, y));
  game.units.add(u);
  game.world.add(u);
  return u;
}

void main() {
  test(
      'layout: three spawners under the top inset, four gates above the bottom',
      () async {
    final (LineDutyGame game, _) = await _game();
    expect(game.spawners, hasLength(3));
    expect(game.gates.map((GateComponent g) => g.color),
        orderedEquals(LaneColor.values));
    expect(game.spawners.first.position.y,
        closeTo(80 + GameTuning.spawnRowOffset, 0.01));
    expect(game.gates.first.position.y,
        closeTo(780 - 20 - GameTuning.gateRowOffset, 0.01));
  });

  test('unit follows its route point by point and keeps the last heading',
      () async {
    final (LineDutyGame game, _) = await _game();
    final UnitComponent u = _put(game, LaneColor.red, 100, 200);
    u.beginRoute();
    u.addRoutePoint(Vector2(140, 200));
    u.addRoutePoint(Vector2(140, 260));
    // Едем ровно до первой точки: 40 ед. при скорости speedStart.
    game.update(40 / GameTuning.speedStart);
    expect(u.position.x, closeTo(140, 0.5));
    expect(u.position.y, closeTo(200, 0.5));
    expect(u.route, hasLength(1));
    expect(u.trace, hasLength(1));
    await _tick(game, 60 / GameTuning.speedStart + 0.5);
    expect(u.route, isEmpty);
    // За концом маршрута — дальше вниз (последний отрезок вертикальный).
    expect(u.heading.y, closeTo(1, 1e-6));
    expect(u.position.y, greaterThan(260));
  });

  test('matching gate delivers, wrong gate ends the run', () async {
    final (LineDutyGame game, _Listener listener) = await _game();
    final GateComponent red = game.gates.first;
    _put(game, LaneColor.red, red.position.x, red.top - 5);
    await _tick(game, 0.3);
    expect(listener.delivered, 1);
    expect(game.units, isEmpty);
    expect(red.pulse, greaterThan(0));

    final GateComponent blue = game.gates.last;
    _put(game, LaneColor.red, blue.position.x, blue.top - 5);
    await _tick(game, 0.3);
    expect(game.frozen, isTrue);
    expect(listener.crashWrongGate, isNull, reason: 'reported after the flash');
    await _tick(game, GameTuning.crashFreeze + 0.1);
    expect(listener.crashWrongGate, isTrue);
  });

  test('finger over its own gate docks the route and ends the gesture',
      () async {
    final (LineDutyGame game, _Listener listener) = await _game();
    final GateComponent red = game.gates.first;
    final UnitComponent u = _put(game, LaneColor.red, 100, 500);
    game.routeStart(Vector2(100, 500));
    expect(game.drawing, same(u));
    expect(listener.routes, 1);
    // Ведём к левому краю красных ворот и заходим чуть выше кромки.
    final double edgeX = red.position.x - red.size.x / 2 + 2;
    for (double y = 510; y < red.top - 20; y += 10) {
      game.routeMove(
          Vector2(100 + (edgeX - 100) * (y - 500) / (red.top - 500), y));
    }
    game.routeMove(Vector2(edgeX, red.top - GameTuning.gateDockMargin + 1));
    expect(u.docked, same(red));
    expect(game.drawing, isNull, reason: 'gesture closed by docking');
    expect(game.finger, isNull);
    expect(u.route.last.y, closeTo(red.top, 1e-3));
    expect(u.route.last.x, closeTo(edgeX + u.radius - 2, 1e-3),
        reason: 'entry is pulled inside the gate by the unit radius');
    // Дальнейшие точки не добавляются.
    final int n = u.route.length;
    game.routeMove(Vector2(edgeX, red.top + 20));
    expect(u.route, hasLength(n));
    game.update(1 / 60);
    expect(red.armed, isTrue);
    await _tick(game, 8);
    expect(game.frozen, isFalse);
    expect(listener.delivered, 1);
    expect(game.units, isNot(contains(u)));
    expect(red.armed, isFalse);
  });

  test('a foreign gate does not dock: the line goes on and the run ends',
      () async {
    final (LineDutyGame game, _Listener listener) = await _game();
    final GateComponent blue = game.gates.last;
    final UnitComponent u =
        _put(game, LaneColor.red, blue.position.x, blue.top - 60);
    game.routeStart(u.position.clone());
    game.routeMove(Vector2(blue.position.x, blue.top - 30));
    game.routeMove(Vector2(blue.position.x, blue.top + 10));
    expect(u.docked, isNull);
    expect(game.drawing, same(u), reason: 'gesture still live');
    expect(u.route.last.y, greaterThan(blue.top));
    game.routeEnd();
    await _tick(game, 4 + GameTuning.crashFreeze);
    expect(listener.crashWrongGate, isTrue);
  });

  test('a new gesture undocks the unit', () async {
    final (LineDutyGame game, _) = await _game();
    final GateComponent red = game.gates.first;
    final UnitComponent u = _put(game, LaneColor.red, 100, 200);
    u.beginRoute();
    u.dockTo(red, red.position.x);
    game.update(1 / 60);
    expect(red.armed, isTrue);
    game.routeStart(u.position.clone());
    expect(u.docked, isNull);
    expect(u.route, isEmpty);
    game.update(1 / 60);
    expect(red.armed, isFalse);
  });

  test('two units touching crash; continue clears them and the run goes on',
      () async {
    final (LineDutyGame game, _Listener listener) = await _game();
    final UnitComponent a = _put(game, LaneColor.red, 100, 300);
    final UnitComponent b =
        _put(game, LaneColor.blue, 100, 300 + GameTuning.warnDistance - 2);
    game.update(1 / 60);
    expect(game.warnings, hasLength(1));
    expect(listener.warnings, 1);
    // Сближаем до столкновения.
    b.position.y = a.position.y + GameTuning.crashDistance - 1;
    game.update(1 / 60);
    expect(game.frozen, isTrue);
    expect(a.crashed && b.crashed, isTrue);
    await _tick(game, GameTuning.crashFreeze + 0.1);
    expect(listener.crashWrongGate, isFalse);

    game.clearCrash();
    expect(game.frozen, isFalse);
    expect(game.units, isEmpty);
    await _tick(game, GameTuning.firstSpawnDelay + 0.1);
    expect(game.units, hasLength(1), reason: 'spawning resumed');
  });

  test('spawner waits while its exit is blocked and never exceeds the cap',
      () async {
    final (LineDutyGame game, _) = await _game();
    await _tick(game, 20);
    expect(game.units.length, lessThanOrEqualTo(GameTuning.maxUnits));
    for (final UnitComponent u in game.units) {
      expect(u.position.x,
          inInclusiveRange(u.radius, AppDimens.fieldWidth - u.radius));
    }
  });

  test('demo mode routes units to their own gates and never crashes', () async {
    final LineDutyGame game = LineDutyGame(demo: true, random: math.Random(3));
    game.onGameResize(Vector2(360, 780));
    await game.onLoad();
    await _tick(game, 60);
    expect(game.frozen, isFalse);
    expect(game.units.length, lessThanOrEqualTo(GameTuning.demoUnits));
    for (final UnitComponent u in game.units) {
      expect(u.docked?.color, u.color, reason: 'demo routes are docked');
    }
  });
}
