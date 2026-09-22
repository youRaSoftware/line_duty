import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Типографика: **Golos Text** для интерфейса и **Unbounded** для
/// заголовка и большого счёта (переменные шрифты, веса 500 / 700, кириллица
/// и латиница, OFL, `core/resources/fonts/`). Цифры — табличные. Размеры из
/// спеки (холст 1080 px) делены на 3 — логические пиксели.
class AppFonts {
  const AppFonts._();

  /// Основной шрифт интерфейса (и `ThemeData.fontFamily`).
  static const String family = 'GolosText';

  /// Акцидентный: название в меню, счёт на экране проигрыша.
  static const String displayFamily = 'Unbounded';

  static const List<FontFeature> _tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  /// Счёт в HUD (64 px холста).
  static const TextStyle score = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w700,
    fontSize: 22,
    height: 1,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  /// «РЕКОРД 1104» под счётом (32 px холста).
  static const TextStyle best = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    letterSpacing: 1,
    color: AppColors.textSecondary,
    fontFeatures: _tabular,
  );

  /// Подписи кнопок (52–64 px холста).
  static const TextStyle button = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w700,
    fontSize: 18,
    letterSpacing: 1.5,
    color: AppColors.bgField,
  );

  /// Название в меню (130 px / letter-spacing 14).
  static const TextStyle title = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 44,
    height: 1.05,
    letterSpacing: 4.5,
    color: AppColors.textPrimary,
  );

  /// Подзаголовок меню и заголовок проигрыша («СТОЛКНОВЕНИЕ», 44 px / 10).
  static const TextStyle caption = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w500,
    fontSize: 14,
    letterSpacing: 3,
    color: AppColors.textSecondary,
  );

  /// Счёт на экране проигрыша (200 px холста).
  static const TextStyle bigScore = TextStyle(
    fontFamily: displayFamily,
    fontWeight: FontWeight.w700,
    fontSize: 68,
    height: 1,
    color: AppColors.textPrimary,
    fontFeatures: _tabular,
  );

  /// Обычный текст настроек.
  static const TextStyle body = TextStyle(
    fontFamily: family,
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: AppColors.textPrimary,
  );
}
