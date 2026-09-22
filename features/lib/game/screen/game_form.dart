import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../cubit/game_cubit.dart';
import '../engine/line_duty_game.dart';
import '../widgets/game_hud.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/tutorial_overlay.dart';

/// Игровая форма: поле ([LineDutyGame]) на весь экран, HUD поверх в safe
/// area, оверлеи паузы, проигрыша и онбординга. Движок стоит, пока статус
/// не `playing` или открыт онбординг; уход приложения в фон ставит паузу.
class GameForm extends StatefulWidget {
  /// Высота HUD — на столько спавны ниже safe area.
  static const double hudHeight = 64;

  const GameForm({super.key});

  @override
  State<GameForm> createState() => _GameFormState();
}

class _GameFormState extends State<GameForm> with WidgetsBindingObserver {
  late final GameCubit _cubit = context.read<GameCubit>();
  late final LineDutyGame _game = LineDutyGame(listener: _cubit);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // BlocListener не видит начальное состояние, а ставить паузу до
    // подключения виджета нельзя — Flame тогда не отрисует первый кадр.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncPause(_cubit.state);
    });
  }

  void _syncPause(GameState state) {
    _game.paused = state.status != GameStatus.playing || state.tutorialOpen;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _cubit.pause();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    _game.setInsets(
      top: padding.top + GameForm.hudHeight,
      bottom: padding.bottom + 8,
    );
  }

  void _restart() {
    _game.reset();
    _cubit.restart();
  }

  void _continue() {
    if (_cubit.continueRun()) _game.clearCrash();
  }

  void _menu() => context.goNamed('menu');

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameCubit, GameState>(
      listenWhen: (GameState a, GameState b) =>
          a.status != b.status || a.tutorialOpen != b.tutorialOpen,
      listener: (BuildContext context, GameState state) => _syncPause(state),
      child: AppScaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            GameWidget<LineDutyGame>(game: _game),
            const SafeArea(child: GameHud()),
            BlocBuilder<GameCubit, GameState>(
              buildWhen: (GameState a, GameState b) =>
                  a.status != b.status || a.continues != b.continues,
              builder: (BuildContext context, GameState state) {
                switch (state.status) {
                  case GameStatus.playing:
                    return const SizedBox.shrink();
                  case GameStatus.paused:
                    return PauseOverlay(
                      onResume: _cubit.resume,
                      onRestart: _restart,
                      onMenu: _menu,
                    );
                  case GameStatus.gameOver:
                    return GameOverOverlay(
                      score: state.score,
                      isNewRecord: state.isNewRecord,
                      wrongGate: state.wrongGate,
                      canContinue: state.canContinue,
                      onRestart: _restart,
                      onMenu: _menu,
                      onContinue: _continue,
                    );
                }
              },
            ),
            BlocBuilder<GameCubit, GameState>(
              buildWhen: (GameState a, GameState b) =>
                  a.tutorialOpen != b.tutorialOpen,
              builder: (BuildContext context, GameState state) {
                if (!state.tutorialOpen) return const SizedBox.shrink();
                return TutorialOverlay(onDone: _cubit.finishTutorial);
              },
            ),
          ],
        ),
      ),
    );
  }
}
