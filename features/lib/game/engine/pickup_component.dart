import 'dart:math' as math;
import 'dart:ui' hide TextStyle;

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart' show TextPainter, TextSpan, TextStyle;

import 'game_tuning.dart';
import 'line_duty_game.dart';

/// Пикап-бонус на поле (спека § 5): шестиугольник 110 px холста с обводкой
/// цветом пикапа темы, заливкой 14 % и пиктограммой; вокруг — пульсирующее
/// кольцо ожидания. Живёт [GameTuning.pickupLife] секунд и тает в конце;
/// подбор проверяет игра.
class PickupComponent extends PositionComponent
    with HasGameReference<LineDutyGame> {
  final BonusKind kind;
  double life = GameTuning.pickupLife;

  PickupComponent({required this.kind, required Vector2 position})
      : super(
          position: position,
          size: Vector2.all(GameTuning.pickupRadius * 2),
          anchor: Anchor.center,
          priority: -5,
        );

  double get radius => GameTuning.pickupRadius;

  bool get expired => life <= 0;

  @override
  void update(double dt) {
    if (game.frozen) return;
    life -= dt;
  }

  @override
  void render(Canvas canvas) {
    final Offset c = Offset(size.x / 2, size.y / 2);
    final double fade = life.clamp(0, 1).toDouble();
    final Color color = AppColors.pickup.withValues(alpha: fade);
    final double pulse = 0.5 + 0.5 * math.sin(game.time * 3.5);
    canvas.drawCircle(
      c,
      GameTuning.pickupRingRadius * (0.92 + 0.08 * pulse),
      Paint()
        ..color = color.withValues(alpha: 0.35 * fade * (0.6 + 0.4 * pulse))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    BonusPainter.hexagon(canvas, center: c, radius: radius, color: color);
    BonusPainter.icon(
      canvas,
      kind,
      center: c,
      radius: radius * 0.5,
      color: color,
    );
  }
}

/// Пиктограммы бонусов и шестиугольник — общие для поля, HUD и обучения.
abstract final class BonusPainter {
  /// Шестиугольник с вершиной вверх: обводка 1.7 (5 px), заливка 14 %.
  static void hexagon(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final Path hex = Path();
    for (int i = 0; i < 6; i++) {
      final double a = -math.pi / 2 + i * math.pi / 3;
      final Offset p = center + Offset(math.cos(a), math.sin(a)) * radius;
      if (i == 0) {
        hex.moveTo(p.dx, p.dy);
      } else {
        hex.lineTo(p.dx, p.dy);
      }
    }
    hex.close();
    canvas.drawPath(hex, Paint()..color = color.withValues(alpha: 0.14));
    canvas.drawPath(
      hex,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// Пиктограмма [kind] штрихом 1.7 (5 px), вписанная в круг [radius].
  static void icon(
    Canvas canvas,
    BonusKind kind, {
    required Offset center,
    required double radius,
    required Color color,
    TextStyle? textStyle,
  }) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.19
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    switch (kind) {
      case BonusKind.freeze:
        // Снежинка: три оси с рожками.
        for (int i = 0; i < 3; i++) {
          final double a = i * math.pi / 3;
          final Offset d = Offset(math.cos(a), math.sin(a));
          canvas.drawLine(center - d * radius, center + d * radius, p);
          for (final double s in <double>[-1, 1]) {
            final Offset tip = center + d * radius * s;
            final Offset back = tip - d * radius * 0.35 * s;
            final Offset n = Offset(-d.dy, d.dx) * radius * 0.3;
            canvas.drawLine(tip, back + n, p);
            canvas.drawLine(tip, back - n, p);
          }
        }
      case BonusKind.shield:
        // Полумесяц-щит: дуга и внутренняя дуга.
        final Rect box = Rect.fromCircle(center: center, radius: radius);
        canvas.drawArc(box, math.pi * 0.55, math.pi * 1.2, false, p);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.5),
          -math.pi * 0.35,
          math.pi * 0.9,
          false,
          p,
        );
      case BonusKind.multiplier:
        final TextPainter text = TextPainter(
          text: TextSpan(
            text: '×2',
            style: (textStyle ?? AppFonts.score).copyWith(
              color: color,
              fontSize: radius * 1.4,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        text.paint(
          canvas,
          center - Offset(text.width / 2, text.height / 2),
        );
      case BonusKind.autopilot:
        // «Крыша» с пунктиром под ней.
        final Path roof = Path()
          ..moveTo(center.dx - radius, center.dy + radius * 0.2)
          ..lineTo(center.dx, center.dy - radius)
          ..lineTo(center.dx + radius, center.dy + radius * 0.2);
        canvas.drawPath(roof, p);
        canvas.drawLine(
          Offset(center.dx - radius * 0.8, center.dy + radius * 0.3),
          Offset(center.dx - radius * 0.8, center.dy + radius),
          p,
        );
        canvas.drawLine(
          Offset(center.dx + radius * 0.8, center.dy + radius * 0.3),
          Offset(center.dx + radius * 0.8, center.dy + radius),
          p,
        );
        for (final double y in <double>[0.15, 0.55, 0.95]) {
          canvas.drawCircle(
            Offset(center.dx, center.dy + radius * y),
            p.strokeWidth * 0.6,
            Paint()..color = color,
          );
        }
    }
  }
}
