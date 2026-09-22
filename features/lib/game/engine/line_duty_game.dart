import 'dart:math' as math;

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color, Colors;

import 'field_components.dart';
import 'field_layers.dart';
import 'game_tuning.dart';
import 'unit_component.dart';

/// Кому движок сообщает о событиях забега (в игре — `GameCubit`; в демо
/// меню слушателя нет).
abstract interface class GameListener {
  void onDelivered();
  void onWarning();
  void onRouteStarted();

  /// Столкновение или чужие ворота — забег окончен (после вспышки).
  void onCrash({required bool wrongGate});
}

/// Поле «Диспетчера»: фигуры выезжают из спавнов сверху и едут вниз, игрок
/// пальцем рисует им маршруты, ворота своего цвета внизу принимают фигуру,
/// касание двух фигур (или чужие ворота) — конец забега.
///
/// Координаты поля — логические единицы (`AppDimens.fieldWidth` = 360 в
/// ширину, высота от пропорции виджета): камера смотрит на мир из левого
/// верхнего угла с зумом `ширина виджета / 360`. Верхний и нижний отступы
/// ([setInsets]) — под HUD и жест-бар, туда спавны и ворота не заходят.
class LineDutyGame extends FlameGame with DragCallbacks {
  final GameListener? listener;

  /// Демо в меню: фигуры ездят сами по случайным маршрутам, столкновений нет.
  final bool demo;
  final math.Random random;

  final List<UnitComponent> units = <UnitComponent>[];
  final List<GateComponent> gates = <GateComponent>[];
  final List<SpawnerComponent> spawners = <SpawnerComponent>[];

  /// Кольца сближения на этот кадр (середины пар).
  final List<Vector2> warnings = <Vector2>[];

  /// Фигура, которой сейчас рисуют маршрут, и точка пальца.
  UnitComponent? drawing;
  Vector2? finger;

  /// Точка столкновения и время с него; пока [crashPoint] != null, поле
  /// [frozen] и играет вспышка.
  Vector2? crashPoint;
  double crashAge = 0;
  bool _crashReported = false;
  bool _crashWrongGate = false;

  double time = 0;
  int delivered = 0;
  double _spawnIn = GameTuning.firstSpawnDelay;
  double _warnAt = -1;
  double _topInsetPx = 0;
  double _bottomInsetPx = 0;
  double _topInset = 0;
  double _bottomInset = 0;
  LaneColor? _lastColor;
  int _sameColorRun = 0;

  LineDutyGame({this.listener, this.demo = false, math.Random? random})
      : random = random ?? math.Random();

  double get fieldWidth => AppDimens.fieldWidth;

  double get fieldHeight => size.y / _zoom;

  double get _zoom => size.x / AppDimens.fieldWidth;

  bool get frozen => crashPoint != null;

  /// Скорость фигур: растёт с числом доведённых.
  double get unitSpeed {
    if (demo) return GameTuning.demoSpeed;
    final double t = (delivered / GameTuning.rampDeliveries).clamp(0, 1);
    return GameTuning.speedStart +
        (GameTuning.speedMax - GameTuning.speedStart) * t;
  }

  double get _spawnInterval {
    final double t = (delivered / GameTuning.rampDeliveries).clamp(0, 1);
    return GameTuning.spawnIntervalStart +
        (GameTuning.spawnIntervalMin - GameTuning.spawnIntervalStart) * t;
  }

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    world.add(RouteLayer());
    world.add(OverlayLayer());
    for (int i = 0; i < GameTuning.spawnFractions.length; i++) {
      final SpawnerComponent s = SpawnerComponent(position: Vector2.zero());
      spawners.add(s);
      world.add(s);
    }
    for (final LaneColor color in LaneColor.values) {
      final GateComponent g =
          GateComponent(color: color, position: Vector2.zero());
      gates.add(g);
      world.add(g);
    }
    _layout();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    camera.viewfinder.zoom = _zoom;
    _layout();
  }

  /// Отступы сверху (HUD + safe area) и снизу (жест-бар) в логических
  /// пикселях виджета; в единицы поля переводятся при разметке, потому что
  /// до первого кадра размера у игры ещё нет.
  void setInsets({required double top, required double bottom}) {
    _topInsetPx = top;
    _bottomInsetPx = bottom;
    _layout();
  }

  /// До `onLoad` спавнов и ворот ещё нет — разметка применится при загрузке.
  void _layout() {
    if (gates.isEmpty || !hasLayout) return;
    _topInset = _topInsetPx / _zoom;
    _bottomInset = _bottomInsetPx / _zoom;
    final double w = fieldWidth;
    final double spawnY = _topInset + GameTuning.spawnRowOffset;
    for (int i = 0; i < spawners.length; i++) {
      spawners[i].position.setValues(w * GameTuning.spawnFractions[i], spawnY);
    }
    final double gateY = fieldHeight - _bottomInset - GameTuning.gateRowOffset;
    for (int i = 0; i < gates.length; i++) {
      gates[i].position.setValues(w * GameTuning.gateFractions[i], gateY);
    }
  }

  // --- Цикл ---------------------------------------------------------------

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
    if (frozen) {
      crashAge += dt;
      if (!_crashReported && crashAge >= GameTuning.crashFreeze) {
        _crashReported = true;
        listener?.onCrash(wrongGate: _crashWrongGate);
      }
      return;
    }
    _spawnIn -= dt;
    if (_spawnIn <= 0) {
      if (_spawn()) {
        _spawnIn = demo ? GameTuning.demoRespawnDelay : _spawnInterval;
      } else {
        // Не получилось (под спавном занято) — попробовать чуть позже.
        _spawnIn = 0.25;
      }
    }
    _checkGates();
    _checkProximity();
  }

  bool _spawn() {
    final int cap = demo ? GameTuning.demoUnits : GameTuning.maxUnits;
    if (units.length >= cap) return false;
    final List<SpawnerComponent> free = spawners.where(_isClear).toList();
    if (free.isEmpty) return false;
    final SpawnerComponent s = free[random.nextInt(free.length)];
    final UnitComponent unit =
        UnitComponent(color: _nextColor(), position: s.exit);
    units.add(unit);
    world.add(unit);
    if (demo) _autoRoute(unit);
    return true;
  }

  bool _isClear(SpawnerComponent s) {
    final Vector2 exit = s.exit;
    for (final UnitComponent u in units) {
      if ((u.position.x - exit.x).abs() < AppDimens.unitSize * 1.5 &&
          u.position.y - exit.y < GameTuning.spawnClearance &&
          u.position.y >= exit.y - AppDimens.unitSize) {
        return false;
      }
    }
    return true;
  }

  /// Случайный цвет, но не больше двух одинаковых подряд.
  LaneColor _nextColor() {
    LaneColor c = LaneColor.values[random.nextInt(LaneColor.values.length)];
    if (c == _lastColor && _sameColorRun >= 2) {
      final List<LaneColor> others =
          LaneColor.values.where((LaneColor o) => o != c).toList();
      c = others[random.nextInt(others.length)];
    }
    _sameColorRun = c == _lastColor ? _sameColorRun + 1 : 1;
    _lastColor = c;
    return c;
  }

  /// Ворота: фигура, дошедшая до линии ворот, либо доставлена (свои), либо
  /// разбилась (чужие / мимо).
  void _checkGates() {
    if (gates.isEmpty) return;
    final double line = gates.first.top;
    for (final UnitComponent u in List<UnitComponent>.of(units)) {
      if (u.position.y + u.radius < line) continue;
      GateComponent? hit;
      for (final GateComponent g in gates) {
        if (g.containsX(u.position.x)) {
          hit = g;
          break;
        }
      }
      if (hit != null && hit.color == u.color) {
        _deliver(u, hit);
      } else if (demo) {
        _respawnDemo(u);
      } else {
        _crash(u, null, wrongGate: true);
      }
    }
  }

  void _deliver(UnitComponent u, GateComponent gate) {
    gate.pulse = 1;
    _remove(u);
    delivered++;
    listener?.onDelivered();
  }

  void _checkProximity() {
    warnings.clear();
    if (demo) return;
    for (int i = 0; i < units.length; i++) {
      for (int j = i + 1; j < units.length; j++) {
        final UnitComponent a = units[i];
        final UnitComponent b = units[j];
        final double d = a.position.distanceTo(b.position);
        if (d < GameTuning.crashDistance) {
          _crash(a, b, wrongGate: false);
          return;
        }
        if (d < GameTuning.warnDistance) {
          warnings.add((a.position + b.position) / 2);
        }
      }
    }
    if (warnings.isNotEmpty && time - _warnAt > GameTuning.warnCooldown) {
      _warnAt = time;
      listener?.onWarning();
    }
  }

  void _crash(UnitComponent a, UnitComponent? b, {required bool wrongGate}) {
    a.crashed = true;
    b?.crashed = true;
    crashPoint = b == null ? a.position.clone() : (a.position + b.position) / 2;
    crashAge = 0;
    _crashReported = false;
    _crashWrongGate = wrongGate;
    warnings.clear();
    drawing = null;
    finger = null;
  }

  void _remove(UnitComponent u) {
    units.remove(u);
    u.removeFromParent();
    if (identical(drawing, u)) {
      drawing = null;
      finger = null;
    }
  }

  // --- Управление забегом (из кубита / формы) -----------------------------

  /// «Продолжить»: убрать разбитые фигуры и всё рядом, ехать дальше.
  void clearCrash() {
    final Vector2? at = crashPoint;
    if (at == null) return;
    for (final UnitComponent u in List<UnitComponent>.of(units)) {
      if (u.crashed ||
          u.position.distanceTo(at) < GameTuning.continueClearRadius) {
        _remove(u);
      }
    }
    crashPoint = null;
    _spawnIn = GameTuning.firstSpawnDelay;
  }

  /// Новый забег с пустым полем.
  void reset() {
    for (final UnitComponent u in List<UnitComponent>.of(units)) {
      _remove(u);
    }
    crashPoint = null;
    delivered = 0;
    _spawnIn = GameTuning.firstSpawnDelay;
    _lastColor = null;
    _sameColorRun = 0;
    warnings.clear();
  }

  // --- Рисование маршрута ------------------------------------------------

  Vector2 _toField(Vector2 canvasPosition) => canvasPosition / _zoom;

  UnitComponent? _pick(Vector2 p) {
    UnitComponent? best;
    double bestD = GameTuning.pickRadius;
    for (final UnitComponent u in units) {
      final double d = u.position.distanceTo(p);
      if (d < bestD) {
        bestD = d;
        best = u;
      }
    }
    return best;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (paused || frozen || demo) return;
    final Vector2 p = _toField(event.canvasPosition);
    final UnitComponent? unit = _pick(p);
    if (unit == null) return;
    unit.beginRoute();
    drawing = unit;
    finger = p;
    listener?.onRouteStarted();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    final UnitComponent? unit = drawing;
    if (unit == null || paused || frozen) return;
    final Vector2 p = _toField(event.canvasEndPosition);
    p.x = p.x.clamp(unit.radius, fieldWidth - unit.radius);
    p.y = p.y.clamp(unit.radius, fieldHeight - unit.radius);
    finger = p;
    unit.addRoutePoint(p);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    drawing = null;
    finger = null;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    drawing = null;
    finger = null;
  }

  // --- Демо ----------------------------------------------------------------

  /// Плавный ломаный маршрут от спавна к своим воротам через 2–3 точки.
  void _autoRoute(UnitComponent unit) {
    final GateComponent gate =
        gates.firstWhere((GateComponent g) => g.color == unit.color);
    final Vector2 from = unit.position;
    final Vector2 to = gate.position - Vector2(0, gate.size.y);
    final int n = 2 + random.nextInt(2);
    unit.route.clear();
    for (int i = 1; i <= n; i++) {
      final double t = i / (n + 1);
      final double x =
          from.x + (to.x - from.x) * t + (random.nextDouble() - 0.5) * 120;
      final double y = from.y + (to.y - from.y) * t;
      unit.route
          .add(Vector2(x.clamp(unit.radius, fieldWidth - unit.radius), y));
    }
    unit.route.add(to);
  }

  void _respawnDemo(UnitComponent u) => _remove(u);

  @visibleForTesting
  void spawnNow() => _spawn();
}
