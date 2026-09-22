import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Цвета текущей темы — статические геттеры над [current] ([AppPalette]).
/// Тему ставит `App` через [apply] по `SettingsModel.themeId` до
/// построения дерева; движок и painter'ы читают геттеры на каждом кадре и
/// подхватывают смену темы сами.
///
/// **Нельзя** использовать `AppColors.x` в `const`-выражениях и в
/// дефолтах параметров `const`-конструкторов — значение меняется в рантайме.
/// Painter'ы, читающие цвета, должны возвращать `shouldRepaint => true`.
abstract final class AppColors {
  static AppPalette _current = AppPalettes.metro;

  static AppPalette get current => _current;

  static void apply(AppPalette palette) => _current = palette;

  static Color get bgField => _current.bgField;
  static Color get gridDot => _current.gridDot;
  static Color get decor => _current.decor;
  static Color get decor2 => _current.decor2;
  static Color get structure => _current.structure;
  static Color get panel => _current.panel;
  static Color get stroke => _current.stroke;
  static Color get strokeSecondary => _current.strokeSecondary;
  static Color get textPrimary => _current.textPrimary;
  static Color get textSecondary => _current.textSecondary;

  /// «Играть» / «Заново»; текст на них — [buttonText].
  static Color get buttonLight => _current.buttonLight;
  static Color get buttonText => _current.buttonText;
  static Color get danger => _current.danger;
  static Color get pickup => _current.pickup;
  static Color get accent => _current.accent;
  static Color get scrim => _current.scrim;
  static Color get record => _current.record;

  /// Значок в фигуре.
  static Color get glyph => _current.glyph;

  /// Точка и кольцо пальца.
  static Color get finger => _current.finger;

  /// Ореол под линией у пальца (с прозрачностью).
  static Color get fingerHalo => _current.fingerHalo;
  static Color get laneRed => _current.laneRed;
  static Color get laneAmber => _current.laneAmber;
  static Color get laneGreen => _current.laneGreen;
  static Color get laneBlue => _current.laneBlue;

  /// Цвет потока: фигура, её линия и ворота.
  static Color lane(LaneColor color) => _current.lane(color);
}
