import 'dart:math' as math;
import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:flame/components.dart';

import 'package:domain/domain.dart';

import 'game_tuning.dart';
import 'line_duty_game.dart';
import 'pickup_component.dart';
import 'unit_component.dart';

/// Самый нижний слой: декор фона темы (схемы, лучи, пятна) на всё поле.
class DecorLayer extends Component with HasGameReference<LineDutyGame> {
  DecorLayer() : super(priority: -20);

  @override
  void render(Canvas canvas) {
    game.skin.paintDecor(
      canvas,
      Size(game.fieldWidth, game.fieldHeight),
      time: game.time,
    );
  }
}

/// Слой под фигурами: маршруты (линия цветом фигуры), стёртые следы
/// (пунктир 30 %, гаснет) и ореол линии под пальцем.
class RouteLayer extends Component with HasGameReference<LineDutyGame> {
  RouteLayer() : super(priority: -10);

  @override
  void render(Canvas canvas) {
    for (final UnitComponent unit in game.units) {
      _renderTrace(canvas, unit);
      if (unit.route.isEmpty) continue;
      final Path path = Path()..moveTo(unit.position.x, unit.position.y);
      for (final Vector2 p in unit.route) {
        path.lineTo(p.x, p.y);
      }
      final Color c = AppColors.lane(unit.color);
      if (identical(unit, game.drawing)) {
        canvas.drawPath(
          path,
          Paint()
            ..color = AppColors.fingerHalo
            ..style = PaintingStyle.stroke
            ..strokeWidth = AppDimens.routeWidth + AppDimens.routeHalo
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppDimens.routeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  /// Пунктир 4/34 px холста (1.3/11.3 ед.) по пройденным точкам, прозрачнее
  /// с возрастом.
  void _renderTrace(Canvas canvas, UnitComponent unit) {
    if (unit.trace.length < 2) return;
    final Color c = AppColors.lane(unit.color);
    final Paint paint = Paint()
      ..strokeWidth = AppDimens.routeWidth * 0.8
      ..strokeCap = StrokeCap.round;
    const double dash = 1.3;
    const double gap = 11.3;
    double carry = 0;
    for (int i = 0; i < unit.trace.length - 1; i++) {
      final Vector2 a = unit.trace[i].point;
      final Vector2 b = unit.trace[i + 1].point;
      final double age =
          (game.time - unit.trace[i].time) / GameTuning.traceSeconds;
      paint.color = c.withValues(alpha: 0.3 * (1 - age).clamp(0, 1));
      final double len = a.distanceTo(b);
      if (len < 1e-3) continue;
      final Vector2 dir = (b - a) / len;
      double at = carry;
      while (at < len) {
        final double end = math.min(at + dash, len);
        if (at >= 0) {
          final Vector2 p = a + dir * at;
          final Vector2 q = a + dir * end;
          canvas.drawLine(Offset(p.x, p.y), Offset(q.x, q.y), paint);
        }
        at += dash + gap;
      }
      carry = at - len;
    }
  }
}

/// Слой над фигурами: точка пальца в кольце, кольца сближения с «!»,
/// вспышка столкновения.
class OverlayLayer extends Component with HasGameReference<LineDutyGame> {
  OverlayLayer() : super(priority: 10);

  @override
  void render(Canvas canvas) {
    _renderEffects(canvas);
    _renderWarnings(canvas);
    _renderFinger(canvas);
    _renderCrash(canvas);
    _renderBurst(canvas);
    _renderEffectPills(canvas);
  }

  /// Щит — ореол вокруг держателя; заморозка — кольцо вокруг каждой фигуры.
  void _renderEffects(Canvas canvas) {
    final Color pickup = AppColors.pickup;
    for (final UnitComponent u in game.units) {
      final Offset c = Offset(u.position.x, u.position.y);
      if (u.shielded) {
        canvas.drawCircle(
          c,
          u.radius + 7,
          Paint()
            ..color = pickup.withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
        canvas.drawCircle(
          c,
          u.radius + 5,
          Paint()
            ..color = pickup.withValues(alpha: 0.85)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
      if (game.freezeActive) {
        canvas.drawCircle(
          c,
          u.radius + 4,
          Paint()
            ..color = pickup.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }
    }
  }

  /// Вспышка подбора: расходящееся кольцо цветом пикапа.
  void _renderBurst(Canvas canvas) {
    final Vector2? at = game.burstAt;
    if (at == null || game.burstAge > GameTuning.burstSeconds) return;
    final double t = game.burstAge / GameTuning.burstSeconds;
    canvas.drawCircle(
      Offset(at.x, at.y),
      GameTuning.pickupRadius + 40 * t,
      Paint()
        ..color = AppColors.pickup.withValues(alpha: 0.8 * (1 - t))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - t) + 0.5,
    );
  }

  /// Индикаторы активных эффектов по центру строки HUD: шестиугольник с
  /// пиктограммой, у таймеров — дуга оставшегося времени.
  void _renderEffectPills(Canvas canvas) {
    final List<(BonusKind, double?)> active = <(BonusKind, double?)>[
      if (game.freezeActive)
        (BonusKind.freeze, game.freezeLeft / GameTuning.freezeSeconds),
      if (game.shieldActive) (BonusKind.shield, null),
      if (game.multiplierActive)
        (
          BonusKind.multiplier,
          game.multiplierLeft / GameTuning.multiplierSeconds,
        ),
    ];
    if (active.isEmpty) return;
    const double step = 34;
    final double y = game.topInset - 30;
    double x = game.fieldWidth / 2 - step * (active.length - 1) / 2;
    for (final (BonusKind kind, double? left) in active) {
      final Offset c = Offset(x, y);
      canvas.drawCircle(c, 13, Paint()..color = AppColors.panel);
      BonusPainter.hexagon(
        canvas,
        center: c,
        radius: 9.5,
        color: AppColors.pickup,
      );
      BonusPainter.icon(
        canvas,
        kind,
        center: c,
        radius: 4.6,
        color: AppColors.pickup,
      );
      if (left != null) {
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: 13),
          -math.pi / 2,
          2 * math.pi * left,
          false,
          Paint()
            ..color = AppColors.pickup
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.7
            ..strokeCap = StrokeCap.round,
        );
      }
      x += step;
    }
  }

  void _renderFinger(Canvas canvas) {
    final Vector2? f = game.finger;
    if (f == null) return;
    final Offset c = Offset(f.x, f.y);
    canvas.drawCircle(
        c, AppDimens.fingerDot / 2, Paint()..color = AppColors.finger);
    canvas.drawCircle(
      c,
      AppDimens.fingerRing / 2,
      Paint()
        ..color = AppColors.finger.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7,
    );
  }

  void _renderWarnings(Canvas canvas) {
    if (game.frozen) return;
    final Paint ring = Paint()
      ..color = AppColors.danger
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    for (final Vector2 at in game.warnings) {
      final Offset c = Offset(at.x, at.y);
      const double r = AppDimens.warnRing / 2;
      // Пунктир 18/18 px холста (6/6 ед.) по окружности.
      const double seg = 6;
      final double step = seg / r;
      for (double a = 0; a < 2 * math.pi; a += 2 * step) {
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: r),
          a,
          step,
          false,
          ring,
        );
      }
      _bang(canvas, c.translate(0, -r - 8));
    }
  }

  void _bang(Canvas canvas, Offset at) {
    final Paint p = Paint()
      ..color = AppColors.danger
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(at.translate(0, -6), at.translate(0, 2), p);
    canvas.drawCircle(at.translate(0, 6), 1.5, p);
  }

  void _renderCrash(Canvas canvas) {
    final Vector2? at = game.crashPoint;
    if (at == null) return;
    final double t = (game.crashAge / GameTuning.crashFreeze).clamp(0, 1);
    final Offset c = Offset(at.x, at.y);
    final Paint glow = Paint()
      ..color = AppColors.danger.withValues(alpha: 0.35 * (1 - t))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(c, 26 + 40 * t, glow);
    final Paint rays = Paint()
      ..color = AppColors.danger.withValues(alpha: 0.9 * (1 - t * 0.6))
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    const int n = 8;
    for (int i = 0; i < n; i++) {
      final double a = i * 2 * math.pi / n + math.pi / n;
      final Offset dir = Offset(math.cos(a), math.sin(a));
      final double r0 = 18 + 30 * t;
      final double r1 = r0 + 14 + 10 * t;
      canvas.drawLine(c + dir * r0, c + dir * r1, rays);
    }
  }
}
