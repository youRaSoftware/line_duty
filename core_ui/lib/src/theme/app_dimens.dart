class AppDimens {
  const AppDimens._();

  /// Логическая ширина поля (спека: холст 1080 px = 360 ед., 1 ед. = 3 px).
  /// Высота — от пропорции виджета.
  static const double fieldWidth = 360;

  /// Сторона фигуры (96 px) и радиус её скругления (28 px).
  static const double unitSize = 32;
  static const double unitRadius = 9.3;

  /// Ворота 200×130, скругление 24.
  static const double gateWidth = 66.7;
  static const double gateHeight = 43.3;
  static const double gateRadius = 8;

  /// Спавн 160×88, скругление 20.
  static const double spawnWidth = 53.3;
  static const double spawnHeight = 29.3;
  static const double spawnRadius = 6.7;

  /// Линия маршрута 14 px; ореол под пальцем 30 px.
  static const double routeWidth = 4.7;
  static const double routeHalo = 10;

  /// Точка пальца Ø20 в кольце Ø92 (обводка 5).
  static const double fingerDot = 6.7;
  static const double fingerRing = 30.7;

  /// Сетка фона: точки Ø7, шаг 72.
  static const double gridStep = 24;
  static const double gridDot = 2.3;

  /// Кольцо сближения Ø220.
  static const double warnRing = 73;

  /// Кнопки: «Играть» 720×190 r44, обычные 660×150 r36, квадратные 150 r36.
  static const double playButtonHeight = 63;
  static const double playButtonRadius = 15;
  static const double buttonHeight = 50;
  static const double buttonRadius = 12;
  static const double iconButtonSize = 50;
  static const double iconButtonRadius = 12;
  static const double strokeWidth = 1.7;

  static const double panelRadius = 16;
  static const double panelPadding = 20;
  static const double minTapTarget = 44;
}
