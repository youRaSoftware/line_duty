import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import 'tutorial_art.dart';

/// «Как играть»: пять шагов (фигуры и ворота → маршрут → опасности →
/// счёт → бонусы) с иллюстрациями из примитивов игры, точки, «Дальше» / «Играть!» и
/// «Пропустить». Показывается поверх поля на первом запуске и из настроек.
class TutorialOverlay extends StatefulWidget {
  static const Key nextKey = Key('tutorial_next');
  static const Key skipKey = Key('tutorial_skip');

  final VoidCallback onDone;

  const TutorialOverlay({required this.onDone, super.key});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  static const List<(TutorialStep, String, String)> _steps =
      <(TutorialStep, String, String)>[
    (
      TutorialStep.units,
      LocaleKeys.tutorial_step1Title,
      LocaleKeys.tutorial_step1,
    ),
    (
      TutorialStep.route,
      LocaleKeys.tutorial_step2Title,
      LocaleKeys.tutorial_step2,
    ),
    (
      TutorialStep.danger,
      LocaleKeys.tutorial_step3Title,
      LocaleKeys.tutorial_step3,
    ),
    (
      TutorialStep.score,
      LocaleKeys.tutorial_step4Title,
      LocaleKeys.tutorial_step4,
    ),
    (
      TutorialStep.bonus,
      LocaleKeys.tutorial_step5Title,
      LocaleKeys.tutorial_step5,
    ),
  ];

  final PageController _pages = PageController();
  int _step = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_step >= _steps.length - 1) {
      widget.onDone();
      return;
    }
    _pages.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool last = _step == _steps.length - 1;
    return AppOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 270,
            child: PageView(
              controller: _pages,
              onPageChanged: (int i) => setState(() => _step = i),
              children: <Widget>[
                for (final (TutorialStep step, String title, String text)
                    in _steps)
                  _Step(step: step, titleKey: title, textKey: text),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < _steps.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _step ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == _step ? AppColors.accent : AppColors.stroke,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            key: TutorialOverlay.nextKey,
            label: context.tr(
              last ? LocaleKeys.tutorial_start : LocaleKeys.tutorial_next,
            ),
            onPressed: _next,
          ),
          if (!last) ...<Widget>[
            const SizedBox(height: 4),
            AppTextButton(
              key: TutorialOverlay.skipKey,
              label: context.tr(LocaleKeys.tutorial_skip),
              onPressed: widget.onDone,
            ),
          ],
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final TutorialStep step;
  final String titleKey;
  final String textKey;

  const _Step({
    required this.step,
    required this.titleKey,
    required this.textKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: TutorialArt.height,
          child: TutorialArt(step: step),
        ),
        const SizedBox(height: 14),
        Text(
          context.tr(titleKey),
          textAlign: TextAlign.center,
          style: AppFonts.caption,
        ),
        const SizedBox(height: 8),
        Text(
          context.tr(textKey),
          textAlign: TextAlign.center,
          style: AppFonts.body.copyWith(
            fontSize: 13,
            height: 1.35,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
