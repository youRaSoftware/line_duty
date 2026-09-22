import 'dart:math' as math;

import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import '../../game/engine/skins/field_skin.dart';

/// Лента тем в меню (спека § 6): карточка на тему — фон палитры, фигура и
/// ворота её скином, подпись; выбранная обведена акцентом. Ключ карточки —
/// `Key('theme_<id>')`. Помещается в ширину контента, при большем числе тем
/// прокручивается.
class MenuThemeStrip extends StatelessWidget {
  static const double cardWidth = 96;
  static const double cardHeight = 68;
  static const double gap = 10;

  final String selectedId;
  final ValueChanged<String> onSelect;

  const MenuThemeStrip({
    required this.selectedId,
    required this.onSelect,
    super.key,
  });

  static Key keyFor(String id) => Key('theme_$id');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (final AppPalette palette in AppPalettes.all) ...<Widget>[
                  if (palette.id != AppPalettes.all.first.id)
                    const SizedBox(width: gap),
                  _ThemeCard(
                    key: keyFor(palette.id),
                    palette: palette,
                    selected: palette.id == selectedId,
                    onPressed: () => onSelect(palette.id),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppPalette palette;
  final bool selected;
  final VoidCallback onPressed;

  const _ThemeCard({
    required this.palette,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  String _label(BuildContext context) {
    switch (palette.id) {
      case 'city':
        return context.tr(LocaleKeys.themes_city);
      case 'aquarium':
        return context.tr(LocaleKeys.themes_aquarium);
      case 'anthill':
        return context.tr(LocaleKeys.themes_anthill);
      case 'garden':
        return context.tr(LocaleKeys.themes_garden);
      case 'metro':
      default:
        return context.tr(LocaleKeys.themes_metro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: _label(context),
      child: AppPressable(
        onPressed: onPressed,
        builder: (BuildContext context, double pressed, Widget? _) {
          return Transform.scale(
            scale: 1 - 0.05 * pressed,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: MenuThemeStrip.cardWidth,
                  height: MenuThemeStrip.cardHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: palette.background.copyWith(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.accent : AppColors.stroke,
                      width: selected ? 2.5 : AppDimens.strokeWidth,
                    ),
                  ),
                  child: CustomPaint(painter: _PreviewPainter(palette)),
                ),
                const SizedBox(height: 6),
                Text(
                  _label(context),
                  style: AppFonts.best.copyWith(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Мини-поле темы: сетка, фигура в движении и её ворота, нарисованные
/// скином темы. Скин читает [AppColors], поэтому на время отрисовки
/// палитра карточки ставится текущей и затем возвращается.
class _PreviewPainter extends CustomPainter {
  final AppPalette palette;

  const _PreviewPainter(this.palette);

  @override
  void paint(Canvas canvas, Size size) {
    final AppPalette previous = AppColors.current;
    AppColors.apply(palette);
    try {
      final FieldSkin skin = FieldSkins.byId(palette.id);
      final Paint dots = Paint()..color = palette.gridDot;
      for (double y = 6; y < size.height; y += 12) {
        for (double x = 6; x < size.width; x += 12) {
          canvas.drawCircle(Offset(x, y), 1, dots);
        }
      }
      canvas.save();
      canvas.scale(0.55);
      skin.paintDecor(canvas, size / 0.55);
      canvas.restore();
      // Маршрут от фигуры к воротам.
      const LaneColor lane = LaneColor.blue;
      final Offset unit = Offset(size.width * 0.3, size.height * 0.34);
      final Offset gateCenter = Offset(size.width * 0.7, size.height * 0.78);
      const double gateScale = 0.5;
      final Offset entry = gateCenter.translate(
        0,
        -AppDimens.gateHeight * gateScale / 2,
      );
      canvas.drawPath(
        Path()
          ..moveTo(unit.dx, unit.dy)
          ..lineTo(unit.dx, entry.dy - 10)
          ..lineTo(entry.dx, entry.dy),
        Paint()
          ..color = palette.lane(lane)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.save();
      canvas.translate(
        gateCenter.dx - AppDimens.gateWidth * gateScale / 2,
        gateCenter.dy - AppDimens.gateHeight * gateScale / 2,
      );
      canvas.scale(gateScale);
      skin.paintGate(
        canvas,
        size: const Size(AppDimens.gateWidth, AppDimens.gateHeight),
        color: lane,
        fill: 0.34,
      );
      canvas.restore();
      canvas.save();
      canvas.translate(unit.dx, unit.dy);
      canvas.scale(0.6);
      skin.paintUnit(
        canvas,
        center: Offset.zero,
        angle: math.pi / 2,
        color: lane,
      );
      canvas.restore();
    } finally {
      AppColors.apply(previous);
    }
  }

  @override
  bool shouldRepaint(_PreviewPainter old) => old.palette.id != palette.id;
}
