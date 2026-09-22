import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// Палитра одной темы (спека § 4 «Темы»): цвета поля, интерфейса и четырёх
/// потоков. Геометрия, шрифты и значки у всех тем общие ([AppDimens],
/// [AppFonts], [LaneGlyph]). Текущая палитра — [AppColors.current].
class AppPalette {
  /// Идентификатор темы — хранится в `SettingsModel.themeId`.
  final String id;
  final Brightness brightness;

  /// Фон поля и экранов; [bgFieldEnd] — низ градиента (null — сплошной).
  final Color bgField;
  final Color? bgFieldEnd;
  final Color gridDot;

  /// Цвет декора фона (схемы, лучи, пятна) — рисует скин темы.
  final Color decor;
  final Color panel;
  final Color stroke;
  final Color strokeSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color danger;

  /// Пикапы-бонусы.
  final Color pickup;

  /// Акцент интерфейса: тумблер «вкл», точки шагов, галочка выбора.
  final Color accent;

  /// Бейдж рекорда (спека: цвет фигуры 2).
  final Color record;

  /// Значок внутри фигуры.
  final Color glyph;

  /// Точка и кольцо пальца (на светлых темах — тёмные).
  final Color finger;

  /// Ореол под линией у пальца — уже с прозрачностью.
  final Color fingerHalo;

  /// Затемнение под оверлеями — уже с прозрачностью.
  final Color scrim;
  final Color laneRed;
  final Color laneAmber;
  final Color laneGreen;
  final Color laneBlue;

  const AppPalette({
    required this.id,
    required this.brightness,
    required this.bgField,
    this.bgFieldEnd,
    required this.gridDot,
    required this.decor,
    required this.panel,
    required this.stroke,
    required this.strokeSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.danger,
    required this.pickup,
    required this.accent,
    required this.record,
    required this.glyph,
    required this.finger,
    required this.fingerHalo,
    required this.scrim,
    required this.laneRed,
    required this.laneAmber,
    required this.laneGreen,
    required this.laneBlue,
  });

  bool get isDark => brightness == Brightness.dark;

  /// «Играть» / «Заново»: заливка — основной текст, надпись — фон.
  Color get buttonLight => textPrimary;
  Color get buttonText => bgField;

  /// Фон экрана: сплошной или градиент сверху вниз.
  BoxDecoration get background => BoxDecoration(
        color: bgFieldEnd == null ? bgField : null,
        gradient: bgFieldEnd == null
            ? null
            : LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[bgField, bgFieldEnd!],
              ),
      );

  /// Цвет потока: фигура, её линия и ворота.
  Color lane(LaneColor color) {
    switch (color) {
      case LaneColor.red:
        return laneRed;
      case LaneColor.amber:
        return laneAmber;
      case LaneColor.green:
        return laneGreen;
      case LaneColor.blue:
        return laneBlue;
    }
  }
}

/// Все темы. Порядок [all] — порядок ленты в меню. Тема без скина в
/// движке сюда не попадает.
abstract final class AppPalettes {
  static const String defaultId = 'metro';

  /// «Метро · ночь» (тема A, спека v1): тёмная, дефолт.
  static const AppPalette metro = AppPalette(
    id: 'metro',
    brightness: Brightness.dark,
    bgField: Color(0xFF0D131E),
    gridDot: Color(0xFF1B2635),
    decor: Color(0xFF1B2635),
    panel: Color(0xFF131C2B),
    stroke: Color(0xFF243349),
    strokeSecondary: Color(0xFF33455F),
    textPrimary: Color(0xFFE8EDF4),
    textSecondary: Color(0xFF7E93B0),
    danger: Color(0xFFFF4757),
    pickup: Color(0xFF2FCFC2),
    accent: Color(0xFF3E8BE8),
    record: Color(0xFFF2B233),
    glyph: Color(0xFFFFFFFF),
    finger: Color(0xFFFFFFFF),
    fingerHalo: Color(0x1FFFFFFF),
    scrim: Color(0xD1090D14),
    laneRed: Color(0xFFE8503A),
    laneAmber: Color(0xFFF2B233),
    laneGreen: Color(0xFF2EB872),
    laneBlue: Color(0xFF3E8BE8),
  );

  /// «Город» — автобусы (спека § 4.1): светлая.
  static const AppPalette city = AppPalette(
    id: 'city',
    brightness: Brightness.light,
    bgField: Color(0xFFF3F1EC),
    gridDot: Color(0xFFDAD6CC),
    decor: Color(0xFFE4E0D6),
    panel: Color(0xFFFFFFFF),
    stroke: Color(0xFFC9C3B6),
    strokeSecondary: Color(0xFFB3AC9E),
    textPrimary: Color(0xFF1A2230),
    textSecondary: Color(0xFF5E6776),
    danger: Color(0xFFE0243A),
    pickup: Color(0xFF12A5A0),
    accent: Color(0xFF2F6FD0),
    record: Color(0xFFE0A11B),
    glyph: Color(0xFFFFFFFF),
    finger: Color(0xFF1A2230),
    fingerHalo: Color(0x141A2230),
    scrim: Color(0xB31A2230),
    laneRed: Color(0xFFD8432E),
    laneAmber: Color(0xFFE0A11B),
    laneGreen: Color(0xFF1F9A5E),
    laneBlue: Color(0xFF2F6FD0),
  );

  static const List<AppPalette> all = <AppPalette>[metro, city];

  /// По идентификатору; неизвестный — [metro] (миграция настроек).
  static AppPalette byId(String? id) {
    for (final AppPalette palette in all) {
      if (palette.id == id) return palette;
    }
    return metro;
  }
}
