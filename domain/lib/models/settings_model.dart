import 'package:equatable/equatable.dart';

/// Пользовательские настройки (Hive-бокс `settingsBox`).
class SettingsModel extends Equatable {
  final bool soundOn;
  final bool hapticsOn;

  /// Код языка интерфейса (`en`, `ru`); null — системный язык.
  final String? localeCode;

  /// Онбординг «Как играть» показан (первый запуск пройден).
  final bool tutorialSeen;

  /// Тема оформления (`AppPalettes` в core_ui); домен хранит только id.
  final String themeId;

  static const String defaultThemeId = 'metro';

  const SettingsModel({
    required this.soundOn,
    required this.hapticsOn,
    this.localeCode,
    this.tutorialSeen = false,
    this.themeId = defaultThemeId,
  });

  const SettingsModel.empty() : this(soundOn: true, hapticsOn: true);

  /// [localeCode] сбрасывается в null (системный язык) только через
  /// `resetLocale: true` — `localeCode: null` означает «оставить».
  SettingsModel copyWith({
    bool? soundOn,
    bool? hapticsOn,
    String? localeCode,
    bool resetLocale = false,
    bool? tutorialSeen,
    String? themeId,
  }) {
    return SettingsModel(
      soundOn: soundOn ?? this.soundOn,
      hapticsOn: hapticsOn ?? this.hapticsOn,
      localeCode: resetLocale ? null : (localeCode ?? this.localeCode),
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
      themeId: themeId ?? this.themeId,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[soundOn, hapticsOn, localeCode, tutorialSeen, themeId];
}
