part of 'game_cubit.dart';

enum GameStatus { playing, paused, gameOver }

class GameState extends Equatable {
  final int score;
  final int bestScore;
  final GameStatus status;

  /// Фигур доведено за забег.
  final int delivered;

  /// Забег закончился рекордом (счёт выше рекорда на его начало).
  final bool isNewRecord;

  /// Последний конец забега — чужие ворота (иначе столкновение).
  final bool wrongGate;

  /// Оставшиеся продолжения после столкновения.
  final int continues;

  const GameState({
    this.score = 0,
    this.bestScore = 0,
    this.status = GameStatus.playing,
    this.delivered = 0,
    this.isNewRecord = false,
    this.wrongGate = false,
    this.continues = GameRules.continuesPerRun,
  });

  bool get canContinue => continues > 0;

  GameState copyWith({
    int? score,
    int? bestScore,
    GameStatus? status,
    int? delivered,
    bool? isNewRecord,
    bool? wrongGate,
    int? continues,
  }) {
    return GameState(
      score: score ?? this.score,
      bestScore: bestScore ?? this.bestScore,
      status: status ?? this.status,
      delivered: delivered ?? this.delivered,
      isNewRecord: isNewRecord ?? this.isNewRecord,
      wrongGate: wrongGate ?? this.wrongGate,
      continues: continues ?? this.continues,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        score,
        bestScore,
        status,
        delivered,
        isNewRecord,
        wrongGate,
        continues,
      ];
}
