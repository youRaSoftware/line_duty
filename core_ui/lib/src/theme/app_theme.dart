import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// Единственная тема приложения — тёмная (спека, тема A).
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: AppFonts.family,
  scaffoldBackgroundColor: AppColors.bgField,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.laneBlue,
    brightness: Brightness.dark,
    surface: AppColors.bgField,
  ),
  splashFactory: NoSplash.splashFactory,
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),
);
