import 'package:hive/hive.dart';

class SettingsHiveProvider {
  final Box<dynamic> _box;

  SettingsHiveProvider(this._box);

  bool get soundOn => (_box.get('soundOn') as bool?) ?? true;
  bool get hapticsOn => (_box.get('hapticsOn') as bool?) ?? true;

  /// Код языка; null — системный.
  String? get localeCode => _box.get('locale') as String?;

  bool get tutorialSeen => (_box.get('tutorialSeen') as bool?) ?? false;

  Future<void> save({
    required bool soundOn,
    required bool hapticsOn,
    required String? localeCode,
    required bool tutorialSeen,
  }) async {
    await _box.putAll(<String, Object>{
      'soundOn': soundOn,
      'hapticsOn': hapticsOn,
      'tutorialSeen': tutorialSeen,
    });
    if (localeCode == null) {
      await _box.delete('locale');
    } else {
      await _box.put('locale', localeCode);
    }
  }
}
