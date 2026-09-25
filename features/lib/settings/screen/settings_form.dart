import 'dart:async';

import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../game/widgets/tutorial_overlay.dart';
import '../cubit/settings_cubit.dart';
import '../widgets/language_overlay.dart';
import '../widgets/reset_stats_overlay.dart';
import '../widgets/settings_link_row.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_value_row.dart';

/// Экран настроек: секции «Звук» (звуки, вибрация), «Игра» (язык, «Как
/// играть»),
/// «Статистика» (рекорд, забеги, доведено; сброс), «О приложении» (версия,
/// лицензии). Тумблеры привязаны к [SettingsService.settings], статистика,
/// версия и оверлеи — в [SettingsCubit].
class SettingsForm extends StatelessWidget {
  static const Key backKey = Key('settings_back');
  static const Key languageRowKey = Key('settings_language');
  static const Key howToPlayKey = Key('settings_how_to_play');
  static const Key privacyRowKey = Key('settings_privacy');

  const SettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsCubit cubit = context.read<SettingsCubit>();
    final SettingsState state = context.watch<SettingsCubit>().state;
    final SettingsService settings = appLocator<SettingsService>();
    final GameStatsModel stats = state.stats;
    final String languageName =
        AppLocalizationEnum.byCode(settings.value.localeCode)
                ?.languageDisplayName ??
            context.tr(LocaleKeys.settings_languageSystem);

    return AppScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Row(
                    children: <Widget>[
                      IconSquareButton(
                        key: backKey,
                        icon: Icons.arrow_back_rounded,
                        size: AppDimens.minTapTarget,
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          context.tr(LocaleKeys.settings_title),
                          textAlign: TextAlign.center,
                          style: AppFonts.caption,
                        ),
                      ),
                      const SizedBox(width: AppDimens.minTapTarget),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: <Widget>[
                      ValueListenableBuilder<SettingsModel>(
                        valueListenable: settings.settings,
                        builder: (BuildContext context, SettingsModel value,
                            Widget? _) {
                          return SettingsSection(
                            title: context.tr(LocaleKeys.settings_sound),
                            children: <Widget>[
                              AppToggleRow(
                                label: context.tr(LocaleKeys.settings_sounds),
                                value: value.soundOn,
                                onChanged: settings.setSoundOn,
                              ),
                              AppToggleRow(
                                label:
                                    context.tr(LocaleKeys.settings_vibration),
                                value: value.hapticsOn,
                                onChanged: settings.setHapticsOn,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      SettingsSection(
                        title: context.tr(LocaleKeys.settings_game),
                        children: <Widget>[
                          SettingsLinkRow(
                            key: languageRowKey,
                            label: context.tr(LocaleKeys.settings_language),
                            value: languageName,
                            onPressed: cubit.askLanguage,
                          ),
                          SettingsLinkRow(
                            key: howToPlayKey,
                            label: context.tr(LocaleKeys.settings_howToPlay),
                            onPressed: cubit.showHelp,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SettingsSection(
                        title: context.tr(LocaleKeys.settings_stats),
                        children: <Widget>[
                          SettingsValueRow(
                            label: context.tr(LocaleKeys.settings_best),
                            value: '${stats.bestScore}',
                          ),
                          SettingsValueRow(
                            label: context.tr(LocaleKeys.settings_gamesPlayed),
                            value: '${stats.gamesPlayed}',
                          ),
                          SettingsValueRow(
                            label: context.tr(LocaleKeys.settings_delivered),
                            value: '${stats.totalDelivered}',
                          ),
                          SettingsLinkRow(
                            label: context.tr(LocaleKeys.settings_reset),
                            onPressed: cubit.askReset,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SettingsSection(
                        title: context.tr(LocaleKeys.settings_about),
                        children: <Widget>[
                          SettingsValueRow(
                            label: context.tr(LocaleKeys.settings_version),
                            value: state.version,
                          ),
                          SettingsLinkRow(
                            key: privacyRowKey,
                            label: context.tr(LocaleKeys.settings_privacy),
                            onPressed: () => unawaited(
                              launchUrl(
                                Uri.parse(AppConstants.privacyPolicyUrl),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ),
                          SettingsLinkRow(
                            label: context.tr(LocaleKeys.settings_licenses),
                            onPressed: () => showLicensePage(
                              context: context,
                              applicationName: appLocator<AppConfig>().appName,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state.confirmingReset)
            ResetStatsOverlay(
              onConfirm: cubit.confirmReset,
              onCancel: cubit.cancelReset,
            ),
          if (state.choosingLanguage)
            LanguageOverlay(
              selectedCode: settings.value.localeCode,
              onSelect: (String? code) async {
                cubit.closeLanguage();
                await settings.setLocale(code);
                if (!context.mounted) return;
                final AppLocalizationEnum? lang =
                    AppLocalizationEnum.byCode(code);
                if (lang == null) {
                  await context.resetLocale();
                } else {
                  await context.setLocale(lang.locale);
                }
              },
              onCancel: cubit.closeLanguage,
            ),
          if (state.showingHelp) TutorialOverlay(onDone: cubit.closeHelp),
        ],
      ),
    );
  }
}
