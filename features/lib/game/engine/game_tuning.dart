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

  /// Потолок зума (логических px на единицу поля). Телефоны (≤ 440 px
  /// ширины → зум ≤ 1.22) не упираются; на планшетах поле становится
  /// колонкой 540 px по центру, фигуры остаются телефонного размера.
  static const double maxZoom = 1.5;

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

  /// Магнит входа: фигура без маршрута, едущая вниз над своими воротами
  /// (центр по X в пределах ворот ± запас), доворачивает к центру входа с
  /// такой боковой скоростью (ед/с).
  static const double gateMagnetSlack = 10;
  static const double gateMagnetSpeed = 34;

  /// Стыковка: палец над своими воротами (или выше их верхней кромки не
  /// больше чем на столько) завершает маршрут точкой входа в ворота.
  static const double gateDockMargin = 8;

  // --- Сближение и столкновение -------------------------------------------

  /// Метро: столкновение при расстоянии центров < [crashDistance] (круглый
  /// хитбокс радиуса `crashDistance / 2`); у остальных тем хитбокс — капсула
  /// по силуэту спрайта (`FieldSkin.hitbox`). Предупреждение — когда зазор
  /// между хитбоксами меньше [warnGap] (для Метро это центры < 54).
  static const double crashDistance = AppDimens.unitSize * 0.92;
  static const double warnDistance = 54;
  static const double warnGap = warnDistance - crashDistance;

  /// Звук/вибрация предупреждения — не чаще раза в столько секунд.
  static const double warnCooldown = 0.8;

  /// После столкновения поле замирает на столько секунд (вспышка), потом
  /// экран проигрыша.
  static const double crashFreeze = 0.7;

  /// «Продолжить» убирает фигуры в этом радиусе от точки столкновения.
  static const double continueClearRadius = 90;

  // --- Бонусы-пикапы (спека § 5) -------------------------------------------

  /// Первый пикап — через столько секунд после старта; дальше — раз в
  /// [pickupEvery] ± [pickupJitter]. Пикап живёт [pickupLife] секунд.
  static const double firstPickupDelay = 12;
  static const double pickupEvery = 20;
  static const double pickupJitter = 4;
  static const double pickupLife = 8;

  /// Шестиугольник 110 px холста и кольцо ожидания Ø184.
  static const double pickupRadius = 18.3;
  static const double pickupRingRadius = 30.7;

  /// Не ближе 150 px (50 ед.) к воротам и спавнам и не под фигурой.
  static const double pickupKeepOut = 50;
  static const double pickupUnitClearance = 40;

  /// Длительности эффектов и «призрака» после сработавшего щита (фигура
  /// проходит сквозь других, пока разъезжаются).
  static const double freezeSeconds = 3;
  static const double multiplierSeconds = 10;
  static const double shieldGhostSeconds = 1.2;

  /// Вспышка подбора / срабатывания щита.
  static const double burstSeconds = 0.5;

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
