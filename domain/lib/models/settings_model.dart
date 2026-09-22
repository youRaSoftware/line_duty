import 'package:equatable/equatable.dart';

/// Пользовательские настройки (Hive-бокс `settingsBox`).
class SettingsModel extends Equatable {
  final bool soundOn;
  final bool hapticsOn;

  /// Код языка интерфейса (`en`, `ru`); null — системный язык.
  final String? localeCode;

  /// Онбординг «Как играть» показан (первый запуск пройден).
  final bool tutorialSeen;

  const SettingsModel({
    required this.soundOn,
    required this.hapticsOn,
    this.localeCode,
    this.tutorialSeen = false,
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
  }) {
    return SettingsModel(
      soundOn: soundOn ?? this.soundOn,
      hapticsOn: hapticsOn ?? this.hapticsOn,
      localeCode: resetLocale ? null : (localeCode ?? this.localeCode),
      tutorialSeen: tutorialSeen ?? this.tutorialSeen,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[soundOn, hapticsOn, localeCode, tutorialSeen];
}
