import 'dart:async';

import 'package:core/core.dart';
import 'package:domain/domain.dart';

import '../engine/line_duty_game.dart';

part 'game_state.dart';

/// Состояние забега: счёт, рекорд, пауза / проигрыш, продолжения. Движок
/// ([LineDutyGame]) сообщает о доставках и столкновениях через
/// [GameListener]; форма по статусу ставит движок на паузу и показывает
/// оверлеи. Рекорд «живой»: сохраняется, как только счёт его превысил.
/// На первом запуске (`SettingsModel.tutorialSeen == false`) забег
/// начинается с открытым онбордингом — [finishTutorial] закрывает его и
/// запоминает флаг.
class GameCubit extends Cubit<GameState> implements GameListener {
  final StatsRepository statsRepository;
  final RunRepository runRepository;
  final SettingsService settings;
  final AudioService audio;

  GameStatsModel _stats = const GameStatsModel.empty();
  int _startBest = 0;

  /// Забег уже посчитан в статистике (после продолжения не считать снова).
  bool _counted;
  int _savedDelivered;

  /// Бейдж бонуса держится столько и гаснет.
  static const Duration toastDuration = Duration(milliseconds: 1200);
  Timer? _toastTimer;

  /// [resumeFrom] — снимок незавершённого забега: счёт, продолжения и учёт
  /// в статистике берутся из него, поле восстанавливает форма.
  GameCubit({
    required this.statsRepository,
    required this.runRepository,
    required this.settings,
    required this.audio,
    RunSnapshot? resumeFrom,
  })  : _counted = resumeFrom?.counted ?? false,
        _savedDelivered = resumeFrom?.savedDelivered ?? 0,
        super(
          resumeFrom == null
              ? GameState(tutorialOpen: !settings.value.tutorialSeen)
              : GameState(
                  score: resumeFrom.score,
                  delivered: resumeFrom.delivered,
                  continues: resumeFrom.continues,
                ),
        ) {
    _init();
  }

  /// Сохранить забег для продолжения после выхода: [field] — снимок поля от
  /// движка (`LineDutyGame.capture`), счёт и продолжения — отсюда. Только
  /// пока забег идёт; забег без очков не сохраняется (терять нечего), а
  /// старый снимок при этом стирается.
  Future<void> saveSnapshot(RunSnapshot field) async {
    if (state.status == GameStatus.gameOver) return;
    if (state.score == 0) {
      await runRepository.clear();
      return;
    }
    await runRepository.save(field);
  }

  /// Счёт и учёт для `LineDutyGame.capture`.
  ({int score, int delivered, int continues, bool counted, int savedDelivered})
      get snapshotFields => (
            score: state.score,
            delivered: state.delivered,
            continues: state.continues,
            counted: _counted,
            savedDelivered: _savedDelivered,
          );

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
  void onDelivered({bool doubled = false}) {
    if (state.status != GameStatus.playing) return;
    final int score = state.score +
        GameRules.scorePerDelivery * (doubled ? GameRules.bonusMultiplier : 1);
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
  void onBonusPicked(BonusKind kind) {
    if (state.status != GameStatus.playing) return;
    _safeEmit(state.copyWith(bonusToast: kind));
    audio.deliver();
    _toastTimer?.cancel();
    _toastTimer = Timer(toastDuration, () {
      if (state.bonusToast == kind) _safeEmit(state.copyWith(clearToast: true));
    });
  }

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
    runRepository.clear();
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

  /// Онбординг закрыт («Играть!» или «Пропустить») — больше не показываем.
  Future<void> finishTutorial() async {
    if (!state.tutorialOpen) return;
    _safeEmit(state.copyWith(tutorialOpen: false));
    await settings.setTutorialSeen(true);
  }

  /// Новый забег (движок сбрасывает форма).
  void restart() {
    _saveRun();
    runRepository.clear();
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
    _toastTimer?.cancel();
    if (state.status != GameStatus.gameOver) _saveRun();
    return super.close();
  }
}
