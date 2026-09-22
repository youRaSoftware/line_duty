import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_fonts.dart';
import 'app_pressable.dart';

/// Строка настройки с тумблером («Звук», «Вибрация»): подпись слева,
/// анимированная пилюля 48×28 справа. Вся строка — тап-цель.
class AppToggleRow extends StatelessWidget {
  static const double _pillWidth = 48;
  static const double _pillHeight = 28;
  static const double _knob = 22;

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ValueChanged<bool>? onChanged = this.onChanged;

    return AppPressable(
      onPressed: onChanged == null ? null : () => onChanged(!value),
      builder: (BuildContext context, double pressed, Widget? _) {
        return Container(
          constraints: const BoxConstraints(minHeight: AppDimens.minTapTarget),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label, style: AppFonts.body)),
              Transform.scale(
                scale: 1 - 0.06 * pressed,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: _pillWidth,
                  height: _pillHeight,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_pillHeight / 2),
                    color: value ? AppColors.accent : AppColors.stroke,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    alignment:
                        value ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: _knob,
                      height: _knob,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
