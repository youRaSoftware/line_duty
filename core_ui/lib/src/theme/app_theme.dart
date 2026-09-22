import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_fonts.dart';
import 'app_palette.dart';

/// Material-тема под палитру: яркость, фон, seed — для встроенных экранов
/// (лицензии) и виджетов Material. Собственные виджеты берут цвета из
/// [AppColors], тема нужна только чтобы Material не спорил с палитрой.
ThemeData appTheme(AppPalette palette) {
  return ThemeData(
    useMaterial3: true,
    brightness: palette.brightness,
    fontFamily: AppFonts.family,
    scaffoldBackgroundColor: palette.bgField,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: palette.brightness,
      surface: palette.bgField,
    ),
    splashFactory: NoSplash.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}

/// Стиль системных панелей под палитру: тёмные иконки на светлом фоне.
SystemUiOverlayStyle systemUiStyle(AppPalette palette) {
  final Brightness icons = palette.isDark ? Brightness.light : Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: const Color(0x00000000),
    statusBarIconBrightness: icons,
    statusBarBrightness: palette.brightness,
    systemNavigationBarColor: const Color(0x00000000),
    systemNavigationBarIconBrightness: icons,
  );
}
