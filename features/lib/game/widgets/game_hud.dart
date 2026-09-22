import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../cubit/game_cubit.dart';

/// HUD (спека 1a): счёт 64 px и «РЕКОРД …» слева, пауза справа.
class GameHud extends StatelessWidget {
  static const Key pauseButtonKey = Key('hud_pause');

  const GameHud({super.key});

  @override
  Widget build(BuildContext context) {
    final GameCubit cubit = context.read<GameCubit>();
    final GameState state = context.watch<GameCubit>().state;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  state.score.toString().padLeft(4, '0'),
                  style: AppFonts.score,
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                    LocaleKeys.hud_best,
                    namedArgs: <String, String>{'score': '${state.bestScore}'},
                  ),
                  style: AppFonts.best,
                ),
              ],
            ),
          ),
          IconSquareButton(
            key: pauseButtonKey,
            icon: Icons.pause_rounded,
            size: AppDimens.minTapTarget,
            onPressed: cubit.pause,
          ),
        ],
      ),
    );
  }
}
