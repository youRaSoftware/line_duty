import 'package:core_ui/core_ui.dart';

/// Все числа геймплея — здесь, крутить «на ощупь» только тут. Единицы —
/// логические (ширина поля [AppDimens.fieldWidth] = 360, 1 ед. = 3 px
/// холста спеки), время — секунды.
abstract final class GameTuning {
  // --- Движение фигур -----------------------------------------------------

  /// Скорость фигуры в начале забега и потолок; растёт с числом доведённых
  /// фигур до [rampDeliveries].
  static const double speedStart = 38;
  static const double speedMax = 74;

  /// Интервал появления новых фигур: стартовый и минимальный.
  static const double spawnIntervalStart = 3.2;
  static const double spawnIntervalMin = 1.25;

  /// Сколько доведённых фигур нужно, чтобы дойти до потолка скорости и
  /// минимального интервала.
  static const int rampDeliveries = 45;

  /// Больше фигур на поле одновременно не появляется.
  static const int maxUnits = 8;

  /// Спавн ждёт, пока под спавном не станет свободно (по вертикали).
  static const double spawnClearance = 70;

  /// Первая фигура появляется через столько секунд после старта.
  static const double firstSpawnDelay = 0.6;

  // --- Маршрут ------------------------------------------------------------

  /// Радиус захвата фигуры пальцем (от центра).
  static const double pickRadius = 26;

  /// Минимальное расстояние между точками записываемого маршрута.
  static const double routePointSpacing = 3;

  /// Стёртый след держится столько секунд и гаснет.
  static const double traceSeconds = 1.1;

  /// Фигура у линии ворот попадает в ближайшие по X ворота, если задевает их
  /// краем: центр не дальше половины ширины ворот плюс этот запас. Зазор
  /// между воротами (≈20 ед.) уже ширины фигуры (32), так что «мимо» при
  /// таком запасе не бывает — только не тот цвет.
  static const double gateCatchSlack = AppDimens.unitSize / 2;

  /// Стыковка: палец над своими воротами (или выше их верхней кромки не
  /// больше чем на столько) завершает маршрут точкой входа в ворота.
  static const double gateDockMargin = 8;

  // --- Сближение и столкновение -------------------------------------------

  /// Расстояние между центрами: столкновение и предупреждение.
  static const double crashDistance = AppDimens.unitSize * 0.92;
  static const double warnDistance = 54;

  /// Звук/вибрация предупреждения — не чаще раза в столько секунд.
  static const double warnCooldown = 0.8;

  /// После столкновения поле замирает на столько секунд (вспышка), потом
  /// экран проигрыша.
  static const double crashFreeze = 0.7;

  /// «Продолжить» убирает фигуры в этом радиусе от точки столкновения.
  static const double continueClearRadius = 90;

  // --- Разметка поля ------------------------------------------------------

  /// Центр спавнов — ниже верхнего отступа (HUD) на столько.
  static const double spawnRowOffset = 22;

  /// Центр ворот — выше нижнего отступа на столько.
  static const double gateRowOffset = 34;

  /// Доли ширины поля для трёх спавнов и четырёх ворот.
  static const List<double> spawnFractions = <double>[0.2, 0.5, 0.8];
  static const List<double> gateFractions = <double>[0.14, 0.38, 0.62, 0.86];

  // --- Демо в меню --------------------------------------------------------

  static const int demoUnits = 2;
  static const double demoSpeed = 34;
  static const double demoRespawnDelay = 1.2;
}
