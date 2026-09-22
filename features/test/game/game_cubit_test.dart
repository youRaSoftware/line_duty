import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:features/game/cubit/game_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _Stats implements StatsRepository {
  GameStatsModel stats;

  _Stats(this.stats);

  @override
  Future<GameStatsModel> getStats() async => stats;

  @override
  Future<void> saveStats(GameStatsModel next) async => stats = next;
}

class _Settings implements SettingsRepository {
  @override
  Future<SettingsModel> getSettings() async => const SettingsModel.empty();

  @override
  Future<void> saveSettings(SettingsModel settings) async {}
}

class _SilentAudio extends AudioService {
  _SilentAudio() : super(SettingsService(_Settings()));
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Stats stats;
  late GameCubit cubit;

  setUp(() async {
    stats = _Stats(const GameStatsModel(bestScore: 30, gamesPlayed: 2));
    cubit = GameCubit(statsRepository: stats, audio: _SilentAudio());
    await _settle();
  });

  tearDown(() => cubit.close());

  test('loads the best score', () {
    expect(cubit.state.bestScore, 30);
    expect(cubit.state.status, GameStatus.playing);
  });

  test('delivery scores and the record updates live', () async {
    for (int i = 0; i < 4; i++) {
      cubit.onDelivered();
    }
    expect(cubit.state.score, 4 * GameRules.scorePerDelivery);
    expect(cubit.state.bestScore, 40);
    expect(cubit.state.delivered, 4);
    await _settle();
    expect(stats.stats.bestScore, 40);
  });

  test('crash ends the run, counts it once and flags a record', () async {
    for (int i = 0; i < 4; i++) {
      cubit.onDelivered();
    }
    cubit.onCrash(wrongGate: false);
    expect(cubit.state.status, GameStatus.gameOver);
    expect(cubit.state.isNewRecord, isTrue);
    expect(cubit.state.wrongGate, isFalse);
    await _settle();
    expect(stats.stats.gamesPlayed, 3);
    expect(stats.stats.totalDelivered, 4);

    // Продолжение — одно на забег; повторный проигрыш забег не удваивает.
    expect(cubit.continueRun(), isTrue);
    expect(cubit.state.status, GameStatus.playing);
    expect(cubit.state.canContinue, isFalse);
    cubit.onDelivered();
    cubit.onCrash(wrongGate: true);
    expect(cubit.continueRun(), isFalse);
    expect(cubit.state.wrongGate, isTrue);
    await _settle();
    expect(stats.stats.gamesPlayed, 3);
    expect(stats.stats.totalDelivered, 5);
  });

  test('restart starts a fresh run with the saved record', () async {
    cubit.onDelivered();
    cubit.restart();
    expect(cubit.state.score, 0);
    expect(cubit.state.bestScore, 30);
    expect(cubit.state.continues, GameRules.continuesPerRun);
    await _settle();
    expect(stats.stats.gamesPlayed, 3);
  });

  test('pause and resume only from the matching status', () {
    cubit.pause();
    expect(cubit.state.status, GameStatus.paused);
    cubit.onDelivered();
    expect(cubit.state.score, 0, reason: 'no scoring while paused');
    cubit.resume();
    expect(cubit.state.status, GameStatus.playing);
    debugPrint('ok');
  });
}
