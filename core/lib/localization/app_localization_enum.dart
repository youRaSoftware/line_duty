import 'package:flutter/material.dart';

/// Поддерживаемые языки интерфейса. Файлы переводов —
/// `core/resources/translations/<lang>-<REGION>.json`, ключи —
/// `locale_keys.g.dart` (генерация: `script/prebuild_script.sh`).
/// Имя языка показывается на нём самом и не переводится. Порядок — порядок
/// строк в пикере: английский первым, дальше по алфавиту родного названия.
/// Устройство с другим регионом того же языка (es-MX, pt-PT, de-AT…) получает
/// файл языка — EasyLocalization подбирает по `languageCode`. Японский
/// рисуется системным CJK-шрифтом (у Golos Text / Unbounded нет иероглифов).
enum AppLocalizationEnum {
  en(locale: Locale('en', 'US'), languageDisplayName: 'English'),
  de(locale: Locale('de', 'DE'), languageDisplayName: 'Deutsch'),
  es(locale: Locale('es', 'ES'), languageDisplayName: 'Español'),
  fr(locale: Locale('fr', 'FR'), languageDisplayName: 'Français'),
  pt(locale: Locale('pt', 'BR'), languageDisplayName: 'Português (Brasil)'),
  ru(locale: Locale('ru', 'RU'), languageDisplayName: 'Русский'),
  ja(locale: Locale('ja', 'JP'), languageDisplayName: '日本語');

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
