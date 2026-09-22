import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// Оверлей паузы: Продолжить / Заново / В меню и тумблеры «Звук»,
/// «Вибрация», привязанные к [SettingsService.settings].
class PauseOverlay extends StatelessWidget {
  static const Key resumeKey = Key('pause_resume');

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const PauseOverlay({
    required this.onResume,
    required this.onRestart,
    required this.onMenu,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final SettingsService settings = appLocator<SettingsService>();

    return AppOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Text(context.tr(LocaleKeys.pause_title),
                style: AppFonts.caption),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            key: resumeKey,
            label: context.tr(LocaleKeys.pause_resume),
            onPressed: onResume,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: context.tr(LocaleKeys.pause_restart),
            onPressed: onRestart,
          ),
          const SizedBox(height: 4),
          AppTextButton(
            label: context.tr(LocaleKeys.pause_menu),
            onPressed: onMenu,
          ),
          Divider(color: AppColors.stroke),
          ValueListenableBuilder<SettingsModel>(
            valueListenable: settings.settings,
            builder: (BuildContext context, SettingsModel value, Widget? _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppToggleRow(
                    label: context.tr(LocaleKeys.pause_sound),
                    value: value.soundOn,
                    onChanged: settings.setSoundOn,
                  ),
                  AppToggleRow(
                    label: context.tr(LocaleKeys.pause_vibration),
                    value: value.hapticsOn,
                    onChanged: settings.setHapticsOn,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
