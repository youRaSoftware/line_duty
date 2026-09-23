import 'package:flame/components.dart';

/// Хитбокс фигуры по форме спрайта: капсула вдоль направления движения —
/// отрезок с центром на [offset] единиц вперёд по курсу (минус — к хвосту)
/// и полудлиной [halfLength], утолщённый на [radius]. Круг — капсула с
/// нулевой длиной. Задаётся скином темы, поэтому столкновения у автобуса,
/// рыбки и муравья считаются по их силуэту, а не по общему кругу.
class HitCapsule {
  final double offset;
  final double halfLength;
  final double radius;

  const HitCapsule({
    required this.radius,
    this.offset = 0,
    this.halfLength = 0,
  });

  const HitCapsule.circle(double radius) : this(radius: radius);

  /// Концы отрезка капсулы в мире для фигуры с центром [center] и единичным
  /// [heading].
  (Vector2, Vector2) segment(Vector2 center, Vector2 heading) {
    final Vector2 mid = center + heading * offset;
    final Vector2 half = heading * halfLength;
    return (mid - half, mid + half);
  }

  /// Расстояние между поверхностями двух капсул (< 0 — пересекаются).
  static double gap(
    HitCapsule a,
    Vector2 aCenter,
    Vector2 aHeading,
    HitCapsule b,
    Vector2 bCenter,
    Vector2 bHeading,
  ) {
    final (Vector2 p0, Vector2 p1) = a.segment(aCenter, aHeading);
    final (Vector2 q0, Vector2 q1) = b.segment(bCenter, bHeading);
    return segmentDistance(p0, p1, q0, q1) - a.radius - b.radius;
  }

  /// Расстояние от точки до поверхности капсулы (< 0 — внутри).
  double gapToPoint(Vector2 center, Vector2 heading, Vector2 point) {
    final (Vector2 p0, Vector2 p1) = segment(center, heading);
    return _pointSegmentDistance(point, p0, p1) - radius;
  }

  /// Ближайшая к [point] точка на оси капсулы.
  Vector2 closestAxisPoint(Vector2 center, Vector2 heading, Vector2 point) {
    final (Vector2 p0, Vector2 p1) = segment(center, heading);
    return _closestOnSegment(point, p0, p1);
  }

  static Vector2 _closestOnSegment(Vector2 p, Vector2 a, Vector2 b) {
    final Vector2 ab = b - a;
    final double len2 = ab.length2;
    if (len2 < 1e-9) return a.clone();
    final double t = ((p - a).dot(ab) / len2).clamp(0.0, 1.0);
    return a + ab * t;
  }

  static double _pointSegmentDistance(Vector2 p, Vector2 a, Vector2 b) =>
      p.distanceTo(_closestOnSegment(p, a, b));

  /// Минимальное расстояние между отрезками [p0]–[p1] и [q0]–[q1]
  /// (Ericson, Real-Time Collision Detection, 5.1.9).
  static double segmentDistance(
    Vector2 p0,
    Vector2 p1,
    Vector2 q0,
    Vector2 q1,
  ) {
    final Vector2 d1 = p1 - p0;
    final Vector2 d2 = q1 - q0;
    final Vector2 r = p0 - q0;
    final double a = d1.length2;
    final double e = d2.length2;
    final double f = d2.dot(r);
    const double eps = 1e-9;
    double s;
    double t;
    if (a <= eps && e <= eps) {
      return p0.distanceTo(q0);
    }
    if (a <= eps) {
      s = 0;
      t = (f / e).clamp(0.0, 1.0);
    } else {
      final double c = d1.dot(r);
      if (e <= eps) {
        t = 0;
        s = (-c / a).clamp(0.0, 1.0);
      } else {
        final double b = d1.dot(d2);
        final double denom = a * e - b * b;
        s = denom != 0 ? ((b * f - c * e) / denom).clamp(0.0, 1.0) : 0;
        t = (b * s + f) / e;
        if (t < 0) {
          t = 0;
          s = (-c / a).clamp(0.0, 1.0);
        } else if (t > 1) {
          t = 1;
          s = ((b - c) / a).clamp(0.0, 1.0);
        }
      }
    }
    return (p0 + d1 * s).distanceTo(q0 + d2 * t);
  }
}
