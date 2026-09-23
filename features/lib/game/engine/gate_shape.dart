import 'dart:math' as math;
import 'dart:ui';

/// Форма базы под капотом — совпадает с тем, что нарисовано: прямоугольник
/// у Метро и Города, полукруг-арка у Аквариума, купол у Муравейника, кольцо
/// у Сада. Координаты локальные, (0,0) — левый верх зоны ворот 66.7×43.3.
/// [distance] — знаковое расстояние от точки до границы (< 0 — внутри).
abstract class GateShape {
  const GateShape();

  double distance(Offset p, Size zone);

  bool contains(Offset p, Size zone) => distance(p, zone) <= 0;

  /// Контур для отладочной отрисовки.
  Path outline(Size zone);
}

/// Вся зона ворот.
class RectGateShape extends GateShape {
  const RectGateShape();

  @override
  double distance(Offset p, Size zone) {
    final Rect r = Offset.zero & zone;
    final double dx = math.max(r.left - p.dx, p.dx - r.right);
    final double dy = math.max(r.top - p.dy, p.dy - r.bottom);
    if (dx <= 0 && dy <= 0) return math.max(dx, dy);
    return math.sqrt(
        math.max(dx, 0) * math.max(dx, 0) + math.max(dy, 0) * math.max(dy, 0));
  }

  @override
  Path outline(Size zone) => Path()..addRect(Offset.zero & zone);
}

/// Полуэллипс от нижней кромки зоны: полуоси [a] (по X) и [b] (вверх).
/// Полукруг — при a == b.
class DomeGateShape extends GateShape {
  final double a;
  final double b;

  const DomeGateShape({required this.a, required this.b});

  Offset _centre(Size zone) => Offset(zone.width / 2, zone.height);

  @override
  double distance(Offset p, Size zone) {
    final Offset c = _centre(zone);
    final double dx = p.dx - c.dx;
    // Ниже кромки купол не продолжается — считаем от кромки.
    final double dy = math.min(p.dy - c.dy, 0);
    final double n = math.sqrt((dx * dx) / (a * a) + (dy * dy) / (b * b));
    return (n - 1) * math.min(a, b);
  }

  @override
  Path outline(Size zone) {
    final Offset c = _centre(zone);
    return Path()
      ..addArc(
        Rect.fromCenter(center: c, width: 2 * a, height: 2 * b),
        math.pi,
        math.pi,
      )
      ..close();
  }
}

/// Круг радиуса [r] с центром, смещённым от центра зоны на [dy] вниз.
class RingGateShape extends GateShape {
  final double r;
  final double dy;

  const RingGateShape({required this.r, this.dy = 0});

  Offset _centre(Size zone) => Offset(zone.width / 2, zone.height / 2 + dy);

  @override
  double distance(Offset p, Size zone) => (p - _centre(zone)).distance - r;

  @override
  Path outline(Size zone) =>
      Path()..addOval(Rect.fromCircle(center: _centre(zone), radius: r));
}
