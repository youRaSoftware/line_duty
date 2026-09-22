import 'package:flutter/material.dart';

/// Поддерживаемые языки интерфейса. Файлы переводов —
/// `core/resources/translations/<lang>-<REGION>.json`, ключи —
/// `locale_keys.g.dart` (генерация: `script/prebuild_script.sh`).
/// Имя языка показывается на нём самом и не переводится.
enum AppLocalizationEnum {
  en(locale: Locale('en', 'US'), languageDisplayName: 'English'),
  ru(locale: Locale('ru', 'RU'), languageDisplayName: 'Русский');

  final Locale locale;
  final String languageDisplayName;

  const AppLocalizationEnum({
    required this.locale,
    required this.languageDisplayName,
  });

  /// Код языка, который хранится в `SettingsModel.localeCode`.
  String get code => locale.languageCode;

  static const String langFolderPath = 'packages/core/resources/translations';

  /// Английский — основной: показывается на устройствах с языком вне списка
  /// и подставляется вместо ключей, пропущенных в другом файле.
  static Locale get fallbackLocale => en.locale;

  static List<Locale> get supportedLocales =>
      values.map((AppLocalizationEnum e) => e.locale).toList();

  /// Язык по коду; null для null и неизвестных кодов (системный язык).
  static AppLocalizationEnum? byCode(String? code) {
    for (final AppLocalizationEnum e in values) {
      if (e.code == code) return e;
    }
    return null;
  }
}
