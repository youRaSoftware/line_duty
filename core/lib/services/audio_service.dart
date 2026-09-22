import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'settings_service.dart';

/// Звук и хаптика приложения.
///
/// Читает тумблеры из [SettingsService] (звуки / вибрация). SFX из
/// `core/resources/audio/` (синтезированы `script/gen_placeholder_audio.py`).
/// Кнопки дизайн-системы дёргают [tap] через `ButtonFeedback`
/// (назначается в `lib/main_common.dart`). Ошибки аудио не роняют игру.
class AudioService {
  static const String assetPrefix = 'core/resources/audio/';

  static const String _tap = 'sfx_tap.wav';
  static const String _draw = 'sfx_draw.wav';
  static const String _deliver = 'sfx_deliver.wav';
  static const String _warn = 'sfx_warn.wav';
  static const String _crash = 'sfx_crash.wav';
  static const String _record = 'sfx_record.wav';

  final SettingsService _settings;

  bool _ready = false;
  SettingsModel _last = const SettingsModel.empty();

  AudioService(this._settings);

  bool get soundOn => _settings.value.soundOn;

  bool get hapticsOn => _settings.value.hapticsOn;

  Future<void> init() async {
    _last = _settings.value;
    try {
      FlameAudio.updatePrefix(assetPrefix);
      await FlameAudio.audioCache.loadAll(<String>[
        _tap,
        _draw,
        _deliver,
        _warn,
        _crash,
        _record,
      ]);
      _ready = true;
    } catch (error) {
      debugPrint('AudioService: init failed, running silent: $error');
    }
    _settings.settings.addListener(_onSettingsChanged);
  }

  void _onSettingsChanged() {
    final SettingsModel next = _settings.value;
    // Включили вибрацию — сразу дать её почувствовать.
    if (next.hapticsOn && !_last.hapticsOn) {
      unawaited(HapticFeedback.lightImpact());
    }
    _last = next;
  }

  /// Тесты: отписаться от настроек.
  void dispose() {
    _settings.settings.removeListener(_onSettingsChanged);
    _ready = false;
  }

  // --- События игры / UI --------------------------------------------------

  /// Нажатие любой кнопки дизайн-системы.
  void tap() {
    _sfx(_tap, 0.5);
    _haptic(HapticFeedback.selectionClick);
  }

  /// Палец лёг на фигуру — начали рисовать маршрут.
  void drawStart() {
    _sfx(_draw, 0.4);
    _haptic(HapticFeedback.selectionClick);
  }

  /// Фигура въехала в свои ворота.
  void deliver() {
    _sfx(_deliver, 0.7);
    _haptic(HapticFeedback.lightImpact);
  }

  /// Две фигуры опасно сблизились (кольцо «!»).
  void warn() {
    _sfx(_warn, 0.6);
    _haptic(HapticFeedback.mediumImpact);
  }

  /// Столкновение — конец забега (или новый рекорд).
  void crash({required bool isRecord}) {
    _sfx(isRecord ? _record : _crash, 0.9);
    _haptic(HapticFeedback.heavyImpact);
  }

  void _sfx(String file, double volume) {
    if (!_ready || !soundOn) return;
    unawaited(
      FlameAudio.play(file, volume: volume).then<void>(
        (AudioPlayer _) {},
        onError: (Object error) =>
            debugPrint('AudioService: $file failed: $error'),
      ),
    );
  }

  void _haptic(Future<void> Function() feedback) {
    if (!hapticsOn) return;
    unawaited(feedback());
  }
}
