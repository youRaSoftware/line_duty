import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../game/engine/line_duty_game.dart';

/// Демо-поле под меню (спека 2b): две фигуры ездят по случайным маршрутам
/// на 50 % яркости, тапы не перехватывает.
class MenuDemoField extends StatefulWidget {
  /// Высота нижней полосы меню (кнопки 50 + отступы), свободной от ворот.
  static const double bottomReserve = 110;

  const MenuDemoField({super.key});

  @override
  State<MenuDemoField> createState() => _MenuDemoFieldState();
}

class _MenuDemoFieldState extends State<MenuDemoField> {
  late final LineDutyGame _game = LineDutyGame(demo: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    // Снизу — место под кнопки звука/настроек меню, чтобы ворота демо не
    // прятались под ними.
    _game.setInsets(
      top: padding.top + 40,
      bottom: padding.bottom + MenuDemoField.bottomReserve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.5,
        child: GameWidget<LineDutyGame>(game: _game),
      ),
    );
  }
}
