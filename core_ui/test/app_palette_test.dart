import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppColors.apply(AppPalettes.metro));

  test('byId falls back to metro for unknown ids', () {
    expect(AppPalettes.byId('city').id, 'city');
    expect(AppPalettes.byId('nope').id, 'metro');
    expect(AppPalettes.byId(null).id, 'metro');
    expect(AppPalettes.defaultId, SettingsModel.defaultThemeId);
  });

  test('apply switches every getter and the font colours', () {
    expect(AppColors.current.id, 'metro');
    expect(AppColors.bgField, AppPalettes.metro.bgField);
    AppColors.apply(AppPalettes.city);
    expect(AppColors.current.id, 'city');
    expect(AppColors.bgField, AppPalettes.city.bgField);
    expect(AppColors.lane(LaneColor.blue), AppPalettes.city.laneBlue);
    expect(AppColors.accent, AppPalettes.city.accent);
    expect(AppFonts.body.color, AppPalettes.city.textPrimary);
    expect(AppFonts.button.color, AppPalettes.city.bgField);
    expect(appTheme(AppPalettes.city).brightness, Brightness.light);
    expect(appTheme(AppPalettes.metro).brightness, Brightness.dark);
  });

  test('light palettes get dark status bar icons', () {
    expect(
      systemUiStyle(AppPalettes.city).statusBarIconBrightness,
      Brightness.dark,
    );
    expect(
      systemUiStyle(AppPalettes.metro).statusBarIconBrightness,
      Brightness.light,
    );
  });
}
