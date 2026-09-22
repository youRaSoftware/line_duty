import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../engine/line_duty_game.dart';

part 'game_state.dart';

/// Состояние забега: счёт, рекорд, пауза / проигрыш, продолжения. Движок
/// ([LineDutyGame]) сообщает о доставках и столкновениях через
/// [GameListener]; форма по статусу ставит движок на паузу и показывает
/// оверлеи. Рекорд «живой»: сохраняется, как только счёт его превысил.
class GameCubit extends Cubit<GameState> implements GameListener {
  final StatsRepository statsRepository;
  final AudioService audio;

  GameStatsModel _stats = const GameStatsModel.empty();
  int _startBest = 0;

  /// Забег уже посчитан в статистике (после продолжения не считать снова).
  bool _counted = false;
  int _savedDelivered = 0;

  GameCubit({required this.statsRepository, required this.audio})
      : super(const GameState()) {
    _init();
  }

  Future<void> _init() async {
    _stats = await statsRepository.getStats();
    _startBest = _stats.bestScore;
    _safeEmit(state.copyWith(bestScore: _stats.bestScore));
  }

  void _safeEmit(GameState next) {
    if (isClosed) return;
    emit(next);
  }

  // --- GameListener --------------------------------------------------------

  @override
  void onDelivered() {
    if (state.status != GameStatus.playing) return;
    final int score = state.score + GameRules.scorePerDelivery;
    final int best = score > state.bestScore ? score : state.bestScore;
    _safeEmit(state.copyWith(
      score: score,
      delivered: state.delivered + 1,
      bestScore: best,
    ));
    if (best > _stats.bestScore) {
      _stats = _stats.copyWith(bestScore: best);
      statsRepository.saveStats(_stats);
    }
    audio.deliver();
  }

  @override
  void onWarning() => audio.warn();

  @override
  void onRouteStarted() => audio.drawStart();

  @override
  void onCrash({required bool wrongGate}) {
    if (state.status == GameStatus.gameOver) return;
    final bool record = state.score > 0 && state.score > _startBest;
    _safeEmit(state.copyWith(
      status: GameStatus.gameOver,
      isNewRecord: record,
      wrongGate: wrongGate,
    ));
    _saveRun();
    audio.crash(isRecord: record);
  }

  // --- Управление ---------------------------------------------------------

  void pause() {
    if (state.status != GameStatus.playing) return;
    _safeEmit(state.copyWith(status: GameStatus.paused));
  }

  void resume() {
    if (state.status != GameStatus.paused) return;
    _safeEmit(state.copyWith(status: GameStatus.playing));
  }

  /// Новый забег (движок сбрасывает форма).
  void restart() {
    _saveRun();
    _startBest = _stats.bestScore;
    _counted = false;
    _savedDelivered = 0;
    _safeEmit(GameState(bestScore: _stats.bestScore));
  }

  /// Продолжить после столкновения (одно на забег). true — можно ехать.
  bool continueRun() {
    if (state.status != GameStatus.gameOver || !state.canContinue) {
      return false;
    }
    _safeEmit(state.copyWith(
      status: GameStatus.playing,
      continues: state.continues - 1,
      isNewRecord: false,
    ));
    return true;
  }

  void _saveRun() {
    if (state.score == 0 && state.delivered == 0 && _counted) return;
    _stats = _stats.copyWith(
      bestScore: state.bestScore > _stats.bestScore
          ? state.bestScore
          : _stats.bestScore,
      gamesPlayed: _counted ? _stats.gamesPlayed : _stats.gamesPlayed + 1,
      totalDelivered:
          _stats.totalDelivered + (state.delivered - _savedDelivered),
    );
    _counted = true;
    _savedDelivered = state.delivered;
    statsRepository.saveStats(_stats);
  }

  @override
  Future<void> close() {
    if (state.status != GameStatus.gameOver) _saveRun();
    return super.close();
  }
}
