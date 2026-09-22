import 'package:domain/domain.dart';

import '../providers/local/settings_hive_provider.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsHiveProvider _provider;

  SettingsRepositoryImpl(this._provider);

  @override
  Future<SettingsModel> getSettings() async {
    return SettingsModel(
      soundOn: _provider.soundOn,
      hapticsOn: _provider.hapticsOn,
      localeCode: _provider.localeCode,
      tutorialSeen: _provider.tutorialSeen,
    );
  }

  @override
  Future<void> saveSettings(SettingsModel settings) {
    return _provider.save(
      soundOn: settings.soundOn,
      hapticsOn: settings.hapticsOn,
      localeCode: settings.localeCode,
      tutorialSeen: settings.tutorialSeen,
    );
  }
}
