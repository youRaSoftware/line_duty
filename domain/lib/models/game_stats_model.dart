import 'package:equatable/equatable.dart';

/// Статистика игрока за всё время (Hive-бокс `statsBox`).
class GameStatsModel extends Equatable {
  final int bestScore;
  final int gamesPlayed;

  /// Всего фигур доведено до ворот.
  final int totalDelivered;

  const GameStatsModel({
    required this.bestScore,
    required this.gamesPlayed,
    this.totalDelivered = 0,
  });

  const GameStatsModel.empty() : this(bestScore: 0, gamesPlayed: 0);

  GameStatsModel copyWith({
    int? bestScore,
    int? gamesPlayed,
    int? totalDelivered,
  }) {
    return GameStatsModel(
      bestScore: bestScore ?? this.bestScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      totalDelivered: totalDelivered ?? this.totalDelivered,
    );
  }

  @override
  List<Object?> get props => <Object?>[bestScore, gamesPlayed, totalDelivered];
}
