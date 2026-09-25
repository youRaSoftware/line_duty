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
import 'pickup_component.dart';
import 'skins/field_skin.dart';
import 'unit_component.dart';

/// Кому движок сообщает о событиях забега (в игре — `GameCubit`; в демо
/// меню слушателя нет).
abstract interface class GameListener {
  /// Доставка; [doubled] — под бонусом «×2».
  void onDelivered({bool doubled = false});
  void onWarning();
  void onRouteStarted();

  /// Фигура проехала через пикап.
  void onBonusPicked(BonusKind kind);

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

  /// Пикап на поле (не больше одного) и таймер до следующего.
  PickupComponent? pickup;
  double _pickupIn = GameTuning.firstPickupDelay;

  /// Снимок, который надо восстановить, как только появится разметка
  /// (`onLoad`); форма ставит его до монтирования виджета.
  RunSnapshot? pendingSnapshot;

  /// Активные эффекты: секунды заморозки и «×2»; щит — на фигуре.
  double freezeLeft = 0;
  double multiplierLeft = 0;

  /// Вспышка подбора / щита: точка и возраст.
  Vector2? burstAt;
  double burstAge = 0;

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

  FieldSkin _skin = FieldSkins.metro;

  /// Скин текущей темы ([AppColors.current]); компоненты читают его в
  /// `render`, так что смена темы видна на следующем кадре.
  FieldSkin get skin {
    final String id = AppColors.current.id;
    if (_skin.id != id) _skin = FieldSkins.byId(id);
    return _skin;
  }

  /// Ширина поля в единицах: на телефоне `AppDimens.fieldWidth` = 360, на
  /// планшете больше — зум упирается в [GameTuning.maxZoom], а поле всё
  /// равно занимает всю ширину виджета; спавны и ворота стоят по долям
  /// ширины, фигуры остаются телефонного размера.
  double get fieldWidth => size.x / _zoom;

  double get fieldHeight => size.y / _zoom;

  /// Логических px виджета на единицу поля.
  double get _zoom =>
      math.min(size.x / AppDimens.fieldWidth, GameTuning.maxZoom);

  /// Точка виджета (логические px) → единицы поля.
  Vector2 toField(Vector2 canvasPosition) => canvasPosition / _zoom;

  /// Единицы поля → точка виджета (логические px).
  Vector2 toCanvas(Vector2 fieldPosition) => fieldPosition * _zoom;

  bool get frozen => crashPoint != null;

  bool get freezeActive => freezeLeft > 0;

  bool get multiplierActive => multiplierLeft > 0;

  bool get shieldActive => units.any((UnitComponent u) => u.shielded);

  /// Верхний отступ (HUD) в единицах поля — там рисуются индикаторы эффектов.
  double get topInset => _topInset;

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
    _placeCamera();
    world.add(DecorLayer());
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
    final RunSnapshot? pending = pendingSnapshot;
    if (pending != null) {
      pendingSnapshot = null;
      restore(pending);
    }
  }

  // --- Снимок забега --------------------------------------------------------

  /// Состояние поля для сохранения: фигуры с маршрутами, пикап, таймеры.
  /// Счёт и продолжения добавляет кубит.
  RunSnapshot capture({
    required int score,
    required int delivered,
    required int continues,
    required bool counted,
    required int savedDelivered,
  }) {
    final PickupComponent? p = pickup;
    return RunSnapshot(
      score: score,
      delivered: delivered,
      continues: continues,
      counted: counted,
      savedDelivered: savedDelivered,
      freezeLeft: freezeLeft,
      multiplierLeft: multiplierLeft,
      spawnIn: _spawnIn,
      pickupIn: _pickupIn,
      pickup: p == null
          ? null
          : PickupSnapshot(
              kind: p.kind,
              x: p.position.x,
              y: p.position.y,
              life: p.life,
            ),
      units: <UnitSnapshot>[
        for (final UnitComponent u in units)
          if (!u.crashed)
            UnitSnapshot(
              color: u.color,
              x: u.position.x,
              y: u.position.y,
              headingX: u.heading.x,
              headingY: u.heading.y,
              route: <double>[
                for (final Vector2 p in u.route) ...<double>[p.x, p.y],
              ],
              docked: u.docked?.color,
              shielded: u.shielded,
              ghostLeft: u.ghostLeft,
            ),
      ],
      savedAt: DateTime.now(),
    );
  }

  /// Восстановить поле из снимка (после разметки: ворота уже есть).
  void restore(RunSnapshot s) {
    reset();
    delivered = s.delivered;
    freezeLeft = s.freezeLeft;
    multiplierLeft = s.multiplierLeft;
    _spawnIn = s.spawnIn;
    _pickupIn = s.pickupIn;
    final PickupSnapshot? p = s.pickup;
    if (p != null) {
      spawnPickupNow(p.kind, Vector2(p.x, p.y));
      pickup!.life = p.life;
    }
    for (final UnitSnapshot su in s.units) {
      final UnitComponent u =
          UnitComponent(color: su.color, position: Vector2(su.x, su.y));
      u.heading.setValues(su.headingX, su.headingY);
      if (u.heading.length2 < 1e-6) u.heading.setValues(0, 1);
      u.heading.normalize();
      for (int i = 0; i + 1 < su.route.length; i += 2) {
        u.route.add(Vector2(su.route[i], su.route[i + 1]));
      }
      final LaneColor? docked = su.docked;
      if (docked != null && u.route.isNotEmpty) u.docked = gateFor(docked);
      u.shielded = su.shielded;
      u.ghostLeft = su.ghostLeft;
      units.add(u);
      world.add(u);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _placeCamera();
    _layout();
  }

  /// Камера смотрит на поле из левого верхнего угла.
  void _placeCamera() {
    camera.viewfinder.zoom = _zoom;
    camera.viewfinder.position = Vector2.zero();
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
    burstAge += dt;
    if (freezeLeft > 0) freezeLeft = (freezeLeft - dt).clamp(0, freezeLeft);
    if (multiplierLeft > 0) {
      multiplierLeft = (multiplierLeft - dt).clamp(0, multiplierLeft);
    }
    if (!freezeActive) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        if (_spawn()) {
          _spawnIn = demo ? GameTuning.demoRespawnDelay : _spawnInterval;
        } else {
          // Не получилось (под спавном занято) — попробовать чуть позже.
          _spawnIn = 0.25;
        }
      }
    }
    if (!demo) _tickPickup(dt);
    _checkGates();
    _checkProximity();
    _armGates();
  }

  // --- Бонусы ---------------------------------------------------------------

  void _tickPickup(double dt) {
    final PickupComponent? p = pickup;
    if (p != null) {
      if (p.expired) {
        _removePickup();
        return;
      }
      for (final UnitComponent u in units) {
        if (u.gapToPoint(p.position) < p.radius) {
          _collect(u, p);
          return;
        }
      }
      return;
    }
    _pickupIn -= dt;
    if (_pickupIn <= 0) {
      _pickupIn = _spawnPickup()
          ? GameTuning.pickupEvery +
              (random.nextDouble() * 2 - 1) * GameTuning.pickupJitter
          : 1;
    }
  }

  /// Случайный бонус в случайной точке не ближе [GameTuning.pickupKeepOut]
  /// к воротам и спавнам и не под фигурой; false — места не нашлось.
  bool _spawnPickup() {
    if (!hasLayout || gates.isEmpty) return false;
    final double top = _topInset + GameTuning.spawnRowOffset + 40;
    final double bottom = gates.first.top - 30;
    if (bottom - top < 60) return false;
    for (int attempt = 0; attempt < 20; attempt++) {
      final Vector2 at = Vector2(
        30 + random.nextDouble() * (fieldWidth - 60),
        top + random.nextDouble() * (bottom - top),
      );
      if (_pickupSpotFree(at)) {
        spawnPickupNow(
          BonusKind.values[random.nextInt(BonusKind.values.length)],
          at,
        );
        return true;
      }
    }
    return false;
  }

  bool _pickupSpotFree(Vector2 at) {
    for (final GateComponent g in gates) {
      if (g.position.distanceTo(at) < GameTuning.pickupKeepOut + g.size.x / 2) {
        return false;
      }
    }
    for (final SpawnerComponent s in spawners) {
      if (s.exit.distanceTo(at) < GameTuning.pickupKeepOut) return false;
    }
    for (final UnitComponent u in units) {
      if (u.position.distanceTo(at) < GameTuning.pickupUnitClearance) {
        return false;
      }
    }
    return true;
  }

  /// Поставить пикап [kind] в точку [at] (тесты и отладка).
  @visibleForTesting
  void spawnPickupNow(BonusKind kind, Vector2 at) {
    _removePickup();
    final PickupComponent p = PickupComponent(kind: kind, position: at);
    pickup = p;
    world.add(p);
  }

  void _removePickup() {
    pickup?.removeFromParent();
    pickup = null;
  }

  void _collect(UnitComponent u, PickupComponent p) {
    burstAt = p.position.clone();
    burstAge = 0;
    switch (p.kind) {
      case BonusKind.freeze:
        freezeLeft = GameTuning.freezeSeconds;
      case BonusKind.shield:
        u.shielded = true;
      case BonusKind.multiplier:
        multiplierLeft = GameTuning.multiplierSeconds;
      case BonusKind.autopilot:
        _autoRoute(u);
        if (identical(drawing, u)) routeEnd();
    }
    _removePickup();
    listener?.onBonusPicked(p.kind);
  }

  /// Ворота с пристыкованным маршрутом подсвечены.
  void _armGates() {
    for (final GateComponent g in gates) {
      g.armed = false;
    }
    for (final UnitComponent u in units) {
      if (u.route.isNotEmpty) u.docked?.armed = true;
    }
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

  /// Ворота по форме базы скина ([FieldSkin.gateShape]):
  /// 1. **свои ловят** — хитбокс фигуры задел форму своих ворот (с любой
  ///    стороны) → доставка;
  /// 2. **чужие убивают только при заезде** — центр фигуры внутри формы
  ///    чужих ворот → «Не те ворота»; проезд вдоль ряда и касание краем
  ///    безопасны;
  /// 3. **мимо** — центр опустился ниже низа ряда ворот, не попав ни в одни
  ///    → тоже конец забега.
  void _checkGates() {
    if (gates.isEmpty) return;
    final double bottom = gates.first.top + gates.first.size.y;
    for (final UnitComponent u in List<UnitComponent>.of(units)) {
      final GateComponent own = gateFor(u.color);
      if (u.gapToGate(own) < 0) {
        _deliver(u, own);
        continue;
      }
      final bool entered =
          gates.any((GateComponent g) => g != own && g.holds(u.position));
      if (!entered && u.position.y < bottom) continue;
      if (demo) {
        _respawnDemo(u);
      } else {
        _crash(u, null, wrongGate: true);
      }
    }
  }

  /// Ворота цвета [color].
  GateComponent gateFor(LaneColor color) =>
      gates.firstWhere((GateComponent g) => g.color == color);

  void _deliver(UnitComponent u, GateComponent gate) {
    gate.pulse = 1;
    _remove(u);
    delivered++;
    listener?.onDelivered(doubled: multiplierActive);
  }

  void _checkProximity() {
    warnings.clear();
    if (demo) return;
    for (int i = 0; i < units.length; i++) {
      for (int j = i + 1; j < units.length; j++) {
        final UnitComponent a = units[i];
        final UnitComponent b = units[j];
        if (a.ghostLeft > 0 || b.ghostLeft > 0) continue;
        // Зазор между хитбоксами по силуэту (капсулы скина).
        final double gap = a.gapTo(b);
        if (gap < 0) {
          if (a.shielded || b.shielded) {
            // Щит прощает: держатель на время становится призраком.
            final UnitComponent holder = a.shielded ? a : b;
            holder.shielded = false;
            holder.ghostLeft = GameTuning.shieldGhostSeconds;
            burstAt = holder.position.clone();
            burstAge = 0;
            continue;
          }
          _crash(a, b, wrongGate: false);
          return;
        }
        if (gap < GameTuning.warnGap) {
          final Vector2 pa =
              a.hitbox.closestAxisPoint(a.position, a.heading, b.position);
          final Vector2 pb =
              b.hitbox.closestAxisPoint(b.position, b.heading, a.position);
          warnings.add((pa + pb) / 2);
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
    _clearEffects();
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
    _clearEffects();
  }

  void _clearEffects() {
    freezeLeft = 0;
    multiplierLeft = 0;
    burstAt = null;
    _removePickup();
    _pickupIn = GameTuning.firstPickupDelay;
  }

  // --- Рисование маршрута ------------------------------------------------

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
    routeStart(toField(event.canvasPosition));
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    // Именно start: Flame считает `canvasEndPosition` как позицию + дельту,
    // то есть на шаг впереди настоящего пальца.
    routeMove(toField(event.canvasStartPosition));
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    routeEnd();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    routeEnd();
  }

  /// Палец лёг на поле (координаты поля): если под ним фигура — ей рисуется
  /// новый маршрут, старый стирается.
  void routeStart(Vector2 p) {
    if (paused || frozen || demo) return;
    final UnitComponent? unit = _pick(p);
    if (unit == null) return;
    unit.beginRoute();
    drawing = unit;
    finger = p;
    listener?.onRouteStarted();
  }

  /// Палец ведёт маршрут. Над своими воротами маршрут стыкуется: заканчивается
  /// входом в ворота и жест завершается сам — поверх ворот линия не рисуется.
  /// Чужие ворота не стыкуют: линия идёт как есть, приезд туда — конец забега.
  void routeMove(Vector2 p) {
    final UnitComponent? unit = drawing;
    if (unit == null || paused || frozen) return;
    p.x = p.x.clamp(unit.radius, fieldWidth - unit.radius);
    p.y = p.y.clamp(unit.radius, fieldHeight - unit.radius);
    final GateComponent? own = _dockGateAt(p, unit.color);
    if (own != null) {
      unit.dockTo(own, p.x);
      routeEnd();
      return;
    }
    finger = p;
    unit.addRoutePoint(p);
  }

  /// Палец отпущен: маршрут остаётся как нарисован.
  void routeEnd() {
    drawing = null;
    finger = null;
  }

  GateComponent? _dockGateAt(Vector2 p, LaneColor color) {
    for (final GateComponent g in gates) {
      if (g.color == color &&
          g.inDockZone(p, margin: GameTuning.gateDockMargin)) {
        return g;
      }
    }
    return null;
  }

  // --- Демо ----------------------------------------------------------------

  /// Плавный ломаный маршрут от спавна к своим воротам через 2–3 точки.
  void _autoRoute(UnitComponent unit) {
    final GateComponent gate =
        gates.firstWhere((GateComponent g) => g.color == unit.color);
    final Vector2 from = unit.position;
    final Vector2 to = Vector2(gate.position.x, gate.top);
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
    unit.dockTo(gate, to.x);
  }

  void _respawnDemo(UnitComponent u) => _remove(u);

  @visibleForTesting
  void spawnNow() => _spawn();
}
