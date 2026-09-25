import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../cubit/game_cubit.dart';
import 'game_form.dart';

/// Экран игры; [resumeFrom] — снимок незавершённого забега (из меню по
/// «Продолжить»), null — новый забег.
class GameScreen extends StatelessWidget {
  final RunSnapshot? resumeFrom;

  const GameScreen({this.resumeFrom, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameCubit>(
      lazy: false,
      create: (BuildContext context) => GameCubit(
        statsRepository: appLocator<StatsRepository>(),
        runRepository: appLocator<RunRepository>(),
        settings: appLocator<SettingsService>(),
        audio: appLocator<AudioService>(),
        resumeFrom: resumeFrom,
      ),
      child: GameForm(resumeFrom: resumeFrom),
    );
  }
}
