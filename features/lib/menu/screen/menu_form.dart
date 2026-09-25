import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../cubit/menu_cubit.dart';
import '../widgets/menu_demo_field.dart';
import '../widgets/menu_theme_strip.dart';

/// Главное меню (спека 2b): живое демо-поле на 50 % яркости под
/// интерфейсом, название, подзаголовок, «Играть» со свечением, рекорд со
/// звездой, снизу лента тем ([MenuThemeStrip]), звук и настройки. Колонка
/// не шире [contentMaxWidth].
class MenuForm extends StatelessWidget {
  static const double contentMaxWidth = 400;
  static const Key playButtonKey = Key('menu_play');
  static const Key settingsButtonKey = Key('menu_settings');
  static const Key soundButtonKey = Key('menu_sound');
  static const Key newRunKey = Key('menu_new_run');

  const MenuForm({super.key});

  @override
  Widget build(BuildContext context) {
    final MenuCubit cubit = context.read<MenuCubit>();
    final MenuState state = context.watch<MenuCubit>().state;
    final SettingsService settings = appLocator<SettingsService>();
    final RunSnapshot? saved = state.saved;

    return AppScaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const MenuDemoField(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: MenuForm.contentMaxWidth),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Spacer(flex: 3),
                      Text(
                        context.tr(LocaleKeys.app_title),
                        textAlign: TextAlign.center,
                        style: AppFonts.title,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        context.tr(LocaleKeys.app_subtitle),
                        textAlign: TextAlign.center,
                        style: AppFonts.caption.copyWith(fontSize: 12),
                      ),
                      const Spacer(flex: 2),
                      PrimaryButton(
                        key: playButtonKey,
                        label: context.tr(
                          saved == null
                              ? LocaleKeys.menu_play
                              : LocaleKeys.menu_resume,
                        ),
                        height: AppDimens.playButtonHeight,
                        radius: AppDimens.playButtonRadius,
                        glow: true,
                        icon: Icon(
                          Icons.play_arrow_rounded,
                          size: 26,
                          color: AppColors.buttonText,
                        ),
                        onPressed: () => context.goNamed('game', extra: saved),
                      ),
                      if (saved != null) ...<Widget>[
                        const SizedBox(height: 4),
                        AppTextButton(
                          key: newRunKey,
                          label: context.tr(
                            LocaleKeys.menu_newRun,
                            namedArgs: <String, String>{
                              'score': '${saved.score}',
                            },
                          ),
                          onPressed: () async {
                            await cubit.discardSaved();
                            if (context.mounted) context.goNamed('game');
                          },
                        ),
                        const SizedBox(height: 8),
                      ] else
                        const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.star_outline_rounded,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.tr(
                              LocaleKeys.menu_best,
                              namedArgs: <String, String>{
                                'score': '${state.bestScore}',
                              },
                            ),
                            style: AppFonts.best.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                      const Spacer(flex: 4),
                      ValueListenableBuilder<SettingsModel>(
                        valueListenable: settings.settings,
                        builder: (BuildContext context, SettingsModel value,
                            Widget? _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              MenuThemeStrip(
                                selectedId: value.themeId,
                                onSelect: settings.setThemeId,
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  IconSquareButton(
                                    key: soundButtonKey,
                                    icon: value.soundOn
                                        ? Icons.volume_up_rounded
                                        : Icons.volume_off_rounded,
                                    onPressed: () =>
                                        settings.setSoundOn(!value.soundOn),
                                  ),
                                  const SizedBox(width: 12),
                                  IconSquareButton(
                                    key: settingsButtonKey,
                                    icon: Icons.settings_outlined,
                                    onPressed: () =>
                                        context.pushNamed('settings'),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
