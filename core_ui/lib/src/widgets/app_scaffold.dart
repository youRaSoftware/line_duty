import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'grid_background.dart';

/// Экран приложения: фон палитры (сплошной или градиент) с точечной сеткой
/// ([GridBackground]) под содержимым. Без app bar — экраны рисуют свой HUD.
class AppScaffold extends StatelessWidget {
  final Widget body;

  /// Сетка под содержимым.
  final bool grid;

  const AppScaffold({required this.body, this.grid = true, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgField,
      body: DecoratedBox(
        decoration: AppColors.current.background,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // Не const: цвет сетки читается при build и должен обновляться.
            if (grid) GridBackground(),
            body,
          ],
        ),
      ),
    );
  }
}
