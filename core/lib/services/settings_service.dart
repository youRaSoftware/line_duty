import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';

/// Настройки приложения. Текущее значение лежит в [settings]
/// (`ValueListenableBuilder` в меню, паузе и на экране настроек),
/// изменения сохраняются через [SettingsRepository]. `AudioService`
/// подписан на нотифаер.
class SettingsService {
  final SettingsRepository _repository;

  final ValueNotifier<SettingsModel> settings =
      ValueNotifier<SettingsModel>(const SettingsModel.empty());

  SettingsService(this._repository);

  SettingsModel get value => settings.value;

  Future<void> init() async {
    settings.value = await _repository.getSettings();
  }

  Future<void> setSoundOn(bool value) =>
      _update(settings.value.copyWith(soundOn: value));

  Future<void> setHapticsOn(bool value) =>
      _update(settings.value.copyWith(hapticsOn: value));

  /// Язык интерфейса; null — системный. Сам переключатель EasyLocalization
  /// дёргает виджет (`context.setLocale` / `context.resetLocale`).
  Future<void> setLocale(String? code) => _update(
        code == null
            ? settings.value.copyWith(resetLocale: true)
            : settings.value.copyWith(localeCode: code),
      );

  /// Онбординг показан — больше не открывать на старте игры.
  Future<void> setTutorialSeen(bool value) =>
      _update(settings.value.copyWith(tutorialSeen: value));

  Future<void> _update(SettingsModel next) async {
    if (next == settings.value) return;
    settings.value = next;
    await _repository.saveSettings(next);
  }
}
