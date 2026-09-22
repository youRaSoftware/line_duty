/// Правила забега, не зависящие от движка (лимиты и очки). Скорости,
/// интервалы спавна и размеры — в `features/lib/game/engine/game_tuning.dart`.
abstract final class GameRules {
  /// Очков за фигуру, доведённую до своих ворот.
  static const int scorePerDelivery = 10;

  /// Продолжений после столкновения за один забег.
  static const int continuesPerRun = 1;
}
