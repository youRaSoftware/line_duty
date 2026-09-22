import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../engine/pickup_component.dart';

/// Бейдж подобранного бонуса под HUD (спека § 5: «вспышка + бейдж с
/// названием рядом с HUD, 1.2 с»): пилюля с пиктограммой и названием,
/// появляется и исчезает через [AnimatedSwitcher]. Тапы не перехватывает.
class BonusToast extends StatelessWidget {
  static const Key toastKey = Key('bonus_toast');

  final BonusKind? kind;

  const BonusToast({required this.kind, super.key});

  static String labelKey(BonusKind kind) {
    switch (kind) {
      case BonusKind.freeze:
        return LocaleKeys.bonus_freeze;
      case BonusKind.shield:
        return LocaleKeys.bonus_shield;
      case BonusKind.multiplier:
        return LocaleKeys.bonus_multiplier;
      case BonusKind.autopilot:
        return LocaleKeys.bonus_autopilot;
    }
  }

  @override
  Widget build(BuildContext context) {
    final BonusKind? kind = this.kind;
    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutBack,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: kind == null
            ? const SizedBox.shrink()
            : Container(
                key: ValueKey<BonusKind>(kind),
                padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.pickup,
                    width: AppDimens.strokeWidth,
                  ),
                ),
                child: Row(
                  key: toastKey,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomPaint(
                      size: const Size.square(22),
                      painter: _IconPainter(kind),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.tr(labelKey(kind)),
                      style: AppFonts.button.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _IconPainter extends CustomPainter {
  final BonusKind kind;

  const _IconPainter(this.kind);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = Offset(size.width / 2, size.height / 2);
    BonusPainter.hexagon(
      canvas,
      center: c,
      radius: size.shortestSide / 2,
      color: AppColors.pickup,
    );
    BonusPainter.icon(
      canvas,
      kind,
      center: c,
      radius: size.shortestSide * 0.26,
      color: AppColors.pickup,
    );
  }

  @override
  bool shouldRepaint(_IconPainter old) => true;
}
