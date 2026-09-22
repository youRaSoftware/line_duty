import 'dart:math' as math;
import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// Шаги онбординга — по одной иллюстрации на каждый.
enum TutorialStep { units, route, danger, score }

/// Иллюстрация шага «Как играть», нарисованная примитивами игры: фигуры со
/// значками, ворота, линия маршрута со следом, палец, кольцо «!» и вспышка
/// доставки — теми же цветами и пропорциями, что на поле.
class TutorialArt extends StatelessWidget {
  static const double height = 110;

  final TutorialStep step;

  const TutorialArt({required this.step, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, height),
      painter: switch (step) {
        TutorialStep.units => const _UnitsPainter(),
        TutorialStep.route => const _RoutePainter(),
        TutorialStep.danger => const _DangerPainter(),
        TutorialStep.score => const _ScorePainter(),
      },
    );
  }
}

/// Общие кисти: фигура, ворота, пунктир — в масштабе иллюстрации
/// (фигура 26 px вместо 32 ед. поля).
abstract final class _Art {
  static const double unit = 26;
  static const double gateW = 46;
  static const double gateH = 28;

  static void unitAt(Canvas canvas, Offset c, LaneColor color) {
    final Rect rect = Rect.fromCenter(center: c, width: unit, height: unit);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(7.5)),
      Paint()..color = AppColors.lane(color),
    );
    LaneGlyphPainter.draw(
      canvas,
      color.glyph,
      center: c,
      radius: unit / 2 * 0.42,
      color: AppColors.white,
      strokeWidth: 1.8,
    );
  }

  static void gateAt(
    Canvas canvas,
    Offset c,
    LaneColor color, {
    double fill = 0.16,
  }) {
    final Color lane = AppColors.lane(color);
    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: gateW, height: gateH),
      const Radius.circular(6),
    );
    canvas.drawRRect(rrect, Paint()..color = lane.withValues(alpha: fill));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = lane
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    LaneGlyphPainter.draw(
      canvas,
      color.glyph,
      center: c,
      radius: 5.5,
      color: AppColors.white,
      filled: true,
    );
  }

  static void dashed(
    Canvas canvas,
    Path path,
    Paint paint, {
    double dash = 4,
    double gap = 6,
  }) {
    for (final PathMetric metric in path.computeMetrics()) {
      double at = 0;
      while (at < metric.length) {
        final double end = math.min(at + dash, metric.length);
        canvas.drawPath(metric.extractPath(at, end), paint);
        at += dash + gap;
      }
    }
  }
}

/// Четыре фигуры над воротами своего цвета, пунктир между парами.
class _UnitsPainter extends CustomPainter {
  const _UnitsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const List<double> fr = <double>[0.14, 0.38, 0.62, 0.86];
    for (int i = 0; i < LaneColor.values.length; i++) {
      final LaneColor color = LaneColor.values[i];
      final double x = size.width * fr[i];
      final Paint link = Paint()
        ..color = AppColors.lane(color).withValues(alpha: 0.45)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      _Art.dashed(
        canvas,
        Path()
          ..moveTo(x, 20 + _Art.unit / 2)
          ..lineTo(x, size.height - 18 - _Art.gateH / 2),
        link,
      );
      _Art.unitAt(canvas, Offset(x, 20), color);
      _Art.gateAt(canvas, Offset(x, size.height - 18), color);
    }
  }

  @override
  bool shouldRepaint(_UnitsPainter old) => false;
}

/// Фигура на середине маршрута: за ней гаснущий пунктирный след, впереди
/// линия до взведённых ворот, у входа — точка пальца в кольце.
class _RoutePainter extends CustomPainter {
  const _RoutePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const LaneColor color = LaneColor.blue;
    final Color lane = AppColors.lane(color);
    final Offset gate = Offset(size.width * 0.74, size.height - 20);
    final Offset entry = gate.translate(0, -_Art.gateH / 2);
    final Path route = Path()
      ..moveTo(size.width * 0.12, 22)
      ..cubicTo(
          size.width * 0.45, 12, size.width * 0.42, 70, entry.dx, entry.dy);
    final PathMetric metric = route.computeMetrics().first;
    final double split = metric.length * 0.38;
    final Offset unit = metric.getTangentForOffset(split)!.position;

    _Art.gateAt(canvas, gate, color, fill: 0.34);
    _Art.dashed(
      canvas,
      metric.extractPath(0, split),
      Paint()
        ..color = lane.withValues(alpha: 0.45)
        ..strokeWidth = AppDimens.routeWidth * 0.8
        ..strokeCap = StrokeCap.round,
      dash: 3,
      gap: 7,
    );
    canvas.drawPath(
      metric.extractPath(split, metric.length),
      Paint()
        ..color = lane
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppDimens.routeWidth
        ..strokeCap = StrokeCap.round,
    );
    _Art.unitAt(canvas, unit, color);
    canvas.drawCircle(
      entry,
      AppDimens.fingerDot / 2,
      Paint()..color = AppColors.white,
    );
    canvas.drawCircle(
      entry,
      AppDimens.fingerRing / 2,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7,
    );
  }

  @override
  bool shouldRepaint(_RoutePainter old) => false;
}

/// Слева две фигуры в красном кольце «!», справа фигура над чужими
/// воротами с крестом.
class _DangerPainter extends CustomPainter {
  const _DangerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset a = Offset(size.width * 0.22, size.height * 0.5);
    final Offset b = a.translate(30, 10);
    final Offset mid = (a + b) / 2;
    const double r = 34;
    final Paint ring = Paint()
      ..color = AppColors.danger
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    _Art.dashed(
      canvas,
      Path()..addOval(Rect.fromCircle(center: mid, radius: r)),
      ring,
      dash: 5,
      gap: 5,
    );
    final Paint bang = Paint()
      ..color = AppColors.danger
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final Offset top = mid.translate(0, -r - 9);
    canvas.drawLine(top.translate(0, -8), top.translate(0, 0), bang);
    canvas.drawCircle(top.translate(0, 4), 1.4, bang);
    _Art.unitAt(canvas, a, LaneColor.red);
    _Art.unitAt(canvas, b, LaneColor.green);

    final Offset gate = Offset(size.width * 0.74, size.height - 20);
    _Art.gateAt(canvas, gate, LaneColor.blue);
    _Art.unitAt(
        canvas, gate.translate(0, -_Art.gateH / 2 - 26), LaneColor.amber);
    final Offset x = gate.translate(0, -_Art.gateH / 2 - 4);
    final Paint cross = Paint()
      ..color = AppColors.danger
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(x.translate(-7, -7), x.translate(7, 7), cross);
    canvas.drawLine(x.translate(-7, 7), x.translate(7, -7), cross);
  }

  @override
  bool shouldRepaint(_DangerPainter old) => false;
}

/// Фигура въезжает во вспыхнувшие ворота, рядом «+10».
class _ScorePainter extends CustomPainter {
  const _ScorePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const LaneColor color = LaneColor.green;
    final Offset gate = Offset(size.width * 0.36, size.height - 22);
    canvas.drawCircle(
      gate,
      34,
      Paint()
        ..color = AppColors.lane(color).withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    _Art.gateAt(canvas, gate, color, fill: 0.5);
    _Art.unitAt(canvas, gate.translate(0, -_Art.gateH / 2 - 8), color);

    final TextPainter text = TextPainter(
      text: TextSpan(
        text: '+${GameRules.scorePerDelivery}',
        style: AppFonts.score.copyWith(fontSize: 30),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(
      canvas,
      Offset(size.width * 0.58, size.height / 2 - text.height / 2),
    );
  }

  @override
  bool shouldRepaint(_ScorePainter old) => false;
}
