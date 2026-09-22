import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'grid_background.dart';

/// Экран приложения: фон [AppColors.bgField] с точечной сеткой
/// ([GridBackground]) под содержимым. Без app bar — экраны рисуют свой HUD.
class AppScaffold extends StatelessWidget {
  final Widget body;

  /// Сетка под содержимым (у игры её рисует движок — там выключить).
  final bool grid;

  const AppScaffold({required this.body, this.grid = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgField,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (grid) const GridBackground(),
          body,
        ],
      ),
    );
  }
}
