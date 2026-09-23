import 'dart:math' as math;

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:features/game/engine/field_components.dart';
import 'package:features/game/engine/game_tuning.dart';
import 'package:features/game/engine/hit_capsule.dart';
import 'package:features/game/engine/line_duty_game.dart';
import 'package:features/game/engine/pickup_component.dart';
import 'package:features/game/engine/unit_component.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

class _Listener implements GameListener {
  int delivered = 0;
  int doubledDeliveries = 0;
  int warnings = 0;
  int routes = 0;
  bool? crashWrongGate;
  final List<BonusKind> bonuses = <BonusKind>[];

  @override
  void onDelivered({bool doubled = false}) {
    delivered++;
    if (doubled) doubledDeliveries++;
  }

  @override
  void onBonusPicked(BonusKind kind) => bonuses.add(kind);

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

  test('unit follows its route point by point and then heads down', () async {
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
    // За концом маршрута — вниз.
    expect(u.heading.y, closeTo(1, 1e-6));
    expect(u.position.y, greaterThan(260));
  });

  test(
      'past the end of a sideways route the unit turns down and the magnet '
      'pulls it into its own gate', () async {
    final (LineDutyGame game, _Listener listener) = await _game();
    final GateComponent red = game.gates.first;
    // Маршрут заканчивается горизонтальным отрезком над красными воротами,
    // чуть левее центра входа.
    final UnitComponent u = _put(game, LaneColor.red, 120, red.top - 120);
    u.beginRoute();
    u.addRoutePoint(Vector2(80, red.top - 120));
    u.addRoutePoint(Vector2(red.position.x - 20, red.top - 120));
    await _tick(game, 2.5);
    expect(u.route, isEmpty);
    expect(u.heading.y, closeTo(1, 1e-6), reason: 'turned down, not on');
    await _tick(game, 4);
    expect(game.frozen, isFalse);
    expect(listener.delivered, 1, reason: 'magnet steered it into the gate');
  });

  test(
      'riding along the gate row above the bases is safe; entering a '
      'foreign base or dropping below the row is not', () async {
    final (LineDutyGame game, _) = await _game();
    final GateComponent amber = game.gates[1];
    // Красная фигура едет вправо ровно над янтарной базой, чуть выше зоны.
    final UnitComponent u =
        _put(game, LaneColor.red, amber.position.x - 40, amber.top - 20);
    u.beginRoute();
    u.addRoutePoint(Vector2(amber.position.x + 60, amber.top - 20));
    await _tick(game, 1.5);
    expect(game.frozen, isFalse, reason: 'touching a foreign zone is fine');
    // Заезд центром в чужую базу — конец.
    u.route.clear();
    u.position.setValues(amber.position.x, amber.top + 10);
    game.update(1 / 60);
    expect(game.frozen, isTrue);
    game.reset();
    // Промах: в зазоре между базами вниз до низа ряда.
    final UnitComponent m = _put(game, LaneColor.green, 95, amber.top - 5);
    await _tick(game, 0.5);
    expect(game.frozen, isFalse, reason: 'still inside the row, not judged');
    await _tick(game, 1.5);
    expect(game.frozen, isTrue, reason: 'went past the bases');
    expect(m.crashed, isTrue);
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

  test('a unit whose centre is in the gap still enters the gate it touches',
      () async {
    final (LineDutyGame game, _Listener listener) = await _game();
    final GateComponent green = game.gates[2];
    // Центр на 6 ед. левее левого края зелёных ворот — в зазоре, но фигура
    // (радиус 16) задевает ворота краем.
    final double x = green.position.x - green.size.x / 2 - 6;
    _put(game, LaneColor.green, x, green.top - 5);
    await _tick(game, 0.3);
    expect(game.frozen, isFalse);
    expect(listener.delivered, 1);
    expect(green.pulse, greaterThan(0));

    // Тот же зазор, но фигура чужого цвета: никого своего не задевает, едет
    // вниз мимо баз и разбивается под рядом ворот.
    _put(game, LaneColor.red, x, green.top - 5);
    await _tick(game, 2);
    expect(game.frozen, isTrue);
  });

  test('a docked route running along the gate line is not judged early',
      () async {
    final (LineDutyGame game, _Listener listener) = await _game();
    final GateComponent red = game.gates[0];
    // Едет над воротами почти горизонтально мимо янтарных к своим красным.
    final UnitComponent u = _put(game, LaneColor.red, 150, red.top - 12);
    u.beginRoute();
    u.addRoutePoint(Vector2(70, red.top - 12));
    u.dockTo(red, 60);
    await _tick(game, 5);
    expect(game.frozen, isFalse, reason: 'was riding to its own gate');
    expect(listener.delivered, 1);
  });

  test('a unit touching both its own and a nearer foreign gate is delivered',
      () async {
    final (LineDutyGame game, _Listener listener) = await _game();
    final GateComponent red = game.gates[0];
    final GateComponent amber = game.gates[1];
    // Спорная полоса: ближе к центру янтарных, но краем задевает красные.
    final double x = red.position.x + red.size.x / 2 + 12;
    expect((amber.position.x - x).abs(), lessThan((red.position.x - x).abs()));
    _put(game, LaneColor.red, x, red.top - 5);
    await _tick(game, 0.3);
    expect(game.frozen, isFalse);
    expect(listener.delivered, 1);
    // Та же точка, но жёлтая фигура: свои ворота — янтарные, доставлена тоже.
    _put(game, LaneColor.amber, x, red.top - 5);
    await _tick(game, 0.3);
    expect(listener.delivered, 2);
    // А зелёная здесь никого своего не задевает — едет вниз мимо баз и
    // разбивается под рядом ворот.
    _put(game, LaneColor.green, x, red.top - 5);
    await _tick(game, 2);
    expect(game.frozen, isTrue);
  });

  test(
      'collisions follow the sprite silhouette: buses side by side vs nose to tail',
      () async {
    AppColors.apply(AppPalettes.city);
    addTearDown(() => AppColors.apply(AppPalettes.metro));
    final (LineDutyGame game, _) = await _game();
    // Два автобуса едут вправо, борт к борту: центры на 30 ед., корпуса по
    // 28 в ширину — зазор 4, столкновения нет.
    // Маршруты вправо держат курс (без маршрута фигура поворачивает вниз).
    final UnitComponent a = _put(game, LaneColor.red, 100, 300);
    final UnitComponent b = _put(game, LaneColor.blue, 100, 330);
    a.beginRoute();
    a.addRoutePoint(Vector2(300, 300));
    b.beginRoute();
    b.addRoutePoint(Vector2(300, 330));
    a.heading.setValues(1, 0);
    b.heading.setValues(1, 0);
    expect(a.gapTo(b), greaterThan(0));
    game.update(1 / 60);
    expect(game.frozen, isFalse);
    // Те же 30 ед. нос к хвосту вдоль курса — корпуса по 46.7 в длину
    // перекрываются, столкновение.
    b.position.setValues(130, 300);
    b.route
      ..clear()
      ..add(Vector2(300, 300));
    a.heading.setValues(1, 0);
    b.heading.setValues(1, 0);
    expect(a.gapTo(b), lessThan(0));
    game.update(1 / 60);
    expect(game.frozen, isTrue);
  });

  test('segment distance handles parallel, crossing and point cases', () {
    expect(
      HitCapsule.segmentDistance(
          Vector2(0, 0), Vector2(10, 0), Vector2(0, 5), Vector2(10, 5)),
      closeTo(5, 1e-9),
    );
    expect(
      HitCapsule.segmentDistance(
          Vector2(0, 0), Vector2(10, 10), Vector2(0, 10), Vector2(10, 0)),
      closeTo(0, 1e-9),
    );
    expect(
      HitCapsule.segmentDistance(
          Vector2(0, 0), Vector2(0, 0), Vector2(3, 4), Vector2(3, 4)),
      closeTo(5, 1e-9),
    );
    expect(
      HitCapsule.segmentDistance(
          Vector2(0, 0), Vector2(10, 0), Vector2(20, 0), Vector2(30, 0)),
      closeTo(10, 1e-9),
    );
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

  test('a pickup appears after the first delay away from gates and spawners',
      () async {
    final (LineDutyGame game, _Listener listener) = await _game();
    await _tick(game, GameTuning.firstPickupDelay + 0.5);
    final PickupComponent? p = game.pickup;
    // Пикап мог сразу подобрать случайно проезжавший юнит.
    if (p == null) {
      expect(listener.bonuses, isNotEmpty);
      return;
    }
    for (final GateComponent g in game.gates) {
      expect(g.position.distanceTo(p.position),
          greaterThan(GameTuning.pickupKeepOut));
    }
    for (final SpawnerComponent s in game.spawners) {
      expect(s.exit.distanceTo(p.position),
          greaterThanOrEqualTo(GameTuning.pickupKeepOut));
    }
  });

  test('a pickup nobody reaches expires after its life', () async {
    final (LineDutyGame game, _) = await _game();
    game.spawnPickupNow(BonusKind.multiplier, Vector2(340, 640));
    await _tick(game, 0.5);
    expect(game.pickup, isNotNull);
    await _tick(game, GameTuning.pickupLife + 0.5);
    expect(game.pickup, isNull);
  });

  test('freeze stops every unit for freezeSeconds; drawing still works',
      () async {
    final (LineDutyGame game, _Listener listener) = await _game();
    final UnitComponent u = _put(game, LaneColor.red, 100, 300);
    game.spawnPickupNow(BonusKind.freeze, Vector2(100, 300));
    game.update(1 / 60);
    expect(listener.bonuses, <BonusKind>[BonusKind.freeze]);
    expect(game.pickup, isNull);
    expect(game.freezeActive, isTrue);
    final double y = u.position.y;
    await _tick(game, 1);
    expect(u.position.y, closeTo(y, 0.01), reason: 'frozen');
    game.routeStart(u.position.clone());
    expect(game.drawing, same(u), reason: 'drawing allowed while frozen');
    game.routeEnd();
    await _tick(game, GameTuning.freezeSeconds);
    expect(game.freezeActive, isFalse);
    expect(u.position.y, greaterThan(y));
  });

  test('multiplier doubles deliveries while it lasts', () async {
    final (LineDutyGame game, _Listener listener) = await _game();
    final GateComponent red = game.gates.first;
    _put(game, LaneColor.red, 100, 300);
    game.spawnPickupNow(BonusKind.multiplier, Vector2(100, 300));
    game.update(1 / 60);
    expect(game.multiplierActive, isTrue);
    _put(game, LaneColor.red, red.position.x, red.top - 5);
    await _tick(game, 0.3);
    expect(listener.delivered, 1);
    expect(listener.doubledDeliveries, 1);
    await _tick(game, GameTuning.multiplierSeconds);
    expect(game.multiplierActive, isFalse);
  });

  test('shield forgives one collision and then wears off', () async {
    final (LineDutyGame game, _) = await _game();
    final UnitComponent a = _put(game, LaneColor.red, 100, 300);
    game.spawnPickupNow(BonusKind.shield, Vector2(100, 300));
    game.update(1 / 60);
    expect(a.shielded, isTrue);
    expect(game.shieldActive, isTrue);
    final UnitComponent b =
        _put(game, LaneColor.blue, 100, 300 + GameTuning.crashDistance - 2);
    game.update(1 / 60);
    expect(game.frozen, isFalse, reason: 'shield absorbed the collision');
    expect(a.shielded, isFalse);
    expect(a.ghostLeft, greaterThan(0));
    // Разъехались — щита больше нет, следующее касание разбивает.
    b.position.y = a.position.y + 200;
    await _tick(game, GameTuning.shieldGhostSeconds + 0.2);
    expect(a.ghostLeft, 0);
    b.position.setFrom(a.position + Vector2(0, GameTuning.crashDistance - 2));
    game.update(1 / 60);
    expect(game.frozen, isTrue);
  });

  test('autopilot routes the collecting unit to its own gate', () async {
    final (LineDutyGame game, _) = await _game();
    final UnitComponent u = _put(game, LaneColor.green, 200, 300);
    game.spawnPickupNow(BonusKind.autopilot, Vector2(200, 300));
    game.update(1 / 60);
    expect(u.route, isNotEmpty);
    expect(u.docked?.color, LaneColor.green);
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
