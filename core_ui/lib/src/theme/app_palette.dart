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

  /// Цвета декора фона (схемы, лучи, пятна / песок, камешки, травинки) —
  /// рисует скин темы.
  final Color decor;
  final Color decor2;

  /// Материал построек темы: грот, холмик, лист под воротами.
  final Color structure;
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
    required this.decor2,
    required this.structure,
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
    decor2: Color(0xFF1B2635),
    structure: Color(0xFF131C2B),
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
    decor2: Color(0xFFE4E0D6),
    structure: Color(0xFFFFFFFF),
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

  /// «Аквариум» — рыбки (спека § 4.2): тёмная, градиент.
  static const AppPalette aquarium = AppPalette(
    id: 'aquarium',
    brightness: Brightness.dark,
    bgField: Color(0xFF0F3B4C),
    bgFieldEnd: Color(0xFF0A222E),
    gridDot: Color(0xFF1A4D5E),
    decor: Color(0xFFBFE8F0),
    decor2: Color(0xFF1D3D47),
    structure: Color(0xFF071820),
    panel: Color(0xFF0C2F3D),
    stroke: Color(0xFF2A5B69),
    strokeSecondary: Color(0xFF3A6F7E),
    textPrimary: Color(0xFFDFF0F2),
    textSecondary: Color(0xFF8FB6BF),
    danger: Color(0xFFFF6B6B),
    pickup: Color(0xFFF4FBFC),
    accent: Color(0xFF5EA9F0),
    record: Color(0xFF5EA9F0),
    glyph: Color(0xFFFFFFFF),
    finger: Color(0xFFDFF0F2),
    fingerHalo: Color(0x1AFFFFFF),
    scrim: Color(0xD1090D14),
    laneRed: Color(0xFF4FD1A5),
    laneAmber: Color(0xFF5EA9F0),
    // Спека давала лавандовый #A08CF0 — путался с синим, заменён на маджента.
    laneGreen: Color(0xFFDC7BD6),
    laneBlue: Color(0xFFE9C25C),
  );

  /// «Муравейник» — муравьи (спека § 4.3): светлая, тёплая.
  static const AppPalette anthill = AppPalette(
    id: 'anthill',
    brightness: Brightness.light,
    bgField: Color(0xFFF0E0C2),
    gridDot: Color(0xFFE0CCA6),
    decor: Color(0xFFE7D3AE),
    decor2: Color(0xFFD9C29A),
    structure: Color(0xFF7C5636),
    panel: Color(0xFFE7D3AE),
    stroke: Color(0xFFB89B72),
    strokeSecondary: Color(0xFFA88A62),
    textPrimary: Color(0xFF3A2417),
    textSecondary: Color(0xFF7A5A38),
    danger: Color(0xFF2A1A10),
    pickup: Color(0xFF2F8F9D),
    accent: Color(0xFF2F8F9D),
    record: Color(0xFFD89E27),
    glyph: Color(0xFFF6EEDC),
    finger: Color(0xFF3A2417),
    fingerHalo: Color(0x1A3A2417),
    scrim: Color(0xB31A2230),
    laneRed: Color(0xFFC0492B),
    laneAmber: Color(0xFFD89E27),
    laneGreen: Color(0xFF6F8A2B),
    laneBlue: Color(0xFF96487E),
  );

  /// «Сад» — божьи коровки (спека § 4.4): светлая, зелёная.
  static const AppPalette garden = AppPalette(
    id: 'garden',
    brightness: Brightness.light,
    bgField: Color(0xFFE9EFD8),
    gridDot: Color(0xFFD3DDBA),
    decor: Color(0xFFD3DDBA),
    decor2: Color(0xFFC4D0A6),
    structure: Color(0xFF6F8A2B),
    panel: Color(0xFFF4F7EA),
    stroke: Color(0xFFB9C69A),
    strokeSecondary: Color(0xFFA3B283),
    textPrimary: Color(0xFF2A1A10),
    textSecondary: Color(0xFF5C6B3E),
    danger: Color(0xFF2A1A10),
    pickup: Color(0xFF2F8F9D),
    accent: Color(0xFF2F8F9D),
    record: Color(0xFFE0A11B),
    glyph: Color(0xFFFFFFFF),
    finger: Color(0xFF2A1A10),
    fingerHalo: Color(0x1A2A1A10),
    scrim: Color(0xB31A2230),
    laneRed: Color(0xFFD8432E),
    laneAmber: Color(0xFFE0A11B),
    laneGreen: Color(0xFF3E8BE8),
    laneBlue: Color(0xFF96487E),
  );

  static const List<AppPalette> all = <AppPalette>[
    metro,
    city,
    aquarium,
    anthill,
    garden,
  ];

  /// По идентификатору; неизвестный — [metro] (миграция настроек).
  static AppPalette byId(String? id) {
    for (final AppPalette palette in all) {
      if (palette.id == id) return palette;
    }
    return metro;
  }
}
