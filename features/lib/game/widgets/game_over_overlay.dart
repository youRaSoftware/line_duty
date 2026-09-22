import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Экран проигрыша (спека 2a): поле замирает под затемнением, вспышка
/// столкновения видна; «СТОЛКНОВЕНИЕ» → СЧЁТ → бейдж рекорда → Заново /
/// В меню, ниже пунктирная «Продолжить · реклама» (пока без рекламы —
/// «Продолжить», раз за забег).
class GameOverOverlay extends StatelessWidget {
  static const Key restartKey = Key('game_over_restart');
  static const Key continueKey = Key('game_over_continue');

  final int score;
  final bool isNewRecord;
  final bool wrongGate;
  final bool canContinue;
  final VoidCallback onRestart;
  final VoidCallback onMenu;
  final VoidCallback onContinue;

  const GameOverOverlay({
    required this.score,
    required this.isNewRecord,
    required this.wrongGate,
    required this.canContinue,
    required this.onRestart,
    required this.onMenu,
    required this.onContinue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppOverlay(
      panel: false,
      width: 260,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            context.tr(
              wrongGate
                  ? LocaleKeys.gameOver_wrongGate
                  : LocaleKeys.gameOver_title,
            ),
            textAlign: TextAlign.center,
            style: AppFonts.caption.copyWith(letterSpacing: 3.5),
          ),
          const SizedBox(height: 40),
          Text(
            context.tr(LocaleKeys.gameOver_score),
            textAlign: TextAlign.center,
            style: AppFonts.best,
          ),
          const SizedBox(height: 8),
          Text('$score', textAlign: TextAlign.center, style: AppFonts.bigScore),
          if (isNewRecord) ...<Widget>[
            const SizedBox(height: 16),
            Center(
              child:
                  RecordBadge(label: context.tr(LocaleKeys.gameOver_newRecord)),
            ),
          ],
          const SizedBox(height: 52),
          PrimaryButton(
            key: restartKey,
            label: context.tr(LocaleKeys.gameOver_restart),
            onPressed: onRestart,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: context.tr(LocaleKeys.gameOver_menu),
            onPressed: onMenu,
          ),
          if (canContinue) ...<Widget>[
            const SizedBox(height: 28),
            DashedButton(
              key: continueKey,
              label: context.tr(
                AppConfig.monetizationEnabled
                    ? LocaleKeys.gameOver_continueAd
                    : LocaleKeys.gameOver_continueFree,
              ),
              icon: const Icon(
                Icons.play_circle_outline_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
              onPressed: onContinue,
            ),
          ],
        ],
      ),
    );
  }
}
