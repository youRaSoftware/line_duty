import 'package:equatable/equatable.dart';

import '../enums/bonus_kind.dart';
import '../enums/lane_color.dart';

/// Фигура в снимке забега: цвет, позиция и курс в единицах поля, остаток
/// маршрута (плоский список x, y, …), ворота стыковки, щит и «призрак».
class UnitSnapshot extends Equatable {
  final LaneColor color;
  final double x;
  final double y;
  final double headingX;
  final double headingY;
  final List<double> route;
  final LaneColor? docked;
  final bool shielded;
  final double ghostLeft;

  const UnitSnapshot({
    required this.color,
    required this.x,
    required this.y,
    required this.headingX,
    required this.headingY,
    this.route = const <double>[],
    this.docked,
    this.shielded = false,
    this.ghostLeft = 0,
  });

  @override
  List<Object?> get props => <Object?>[
        color,
        x,
        y,
        headingX,
        headingY,
        route,
        docked,
        shielded,
        ghostLeft,
      ];
}

/// Пикап на поле в снимке.
class PickupSnapshot extends Equatable {
  final BonusKind kind;
  final double x;
  final double y;
  final double life;

  const PickupSnapshot({
    required this.kind,
    required this.x,
    required this.y,
    required this.life,
  });

  @override
  List<Object?> get props => <Object?>[kind, x, y, life];
}

/// Снимок забега для продолжения после выхода из приложения: счёт и
/// продолжения (кубит), учёт в статистике, таймеры эффектов и спавна, пикап
/// и фигуры (движок). Хранится один — последний незавершённый забег.
class RunSnapshot extends Equatable {
  final int score;
  final int delivered;
  final int continues;

  /// Забег уже посчитан в статистике (после продолжения не считать снова)
  /// и сколько доведённых уже записано.
  final bool counted;
  final int savedDelivered;

  final double freezeLeft;
  final double multiplierLeft;
  final double spawnIn;
  final double pickupIn;
  final PickupSnapshot? pickup;
  final List<UnitSnapshot> units;
  final DateTime savedAt;

  const RunSnapshot({
    required this.score,
    required this.delivered,
    required this.continues,
    required this.counted,
    required this.savedDelivered,
    required this.freezeLeft,
    required this.multiplierLeft,
    required this.spawnIn,
    required this.pickupIn,
    required this.pickup,
    required this.units,
    required this.savedAt,
  });

  @override
  List<Object?> get props => <Object?>[
        score,
        delivered,
        continues,
        counted,
        savedDelivered,
        freezeLeft,
        multiplierLeft,
        spawnIn,
        pickupIn,
        pickup,
        units,
        savedAt,
      ];
}
