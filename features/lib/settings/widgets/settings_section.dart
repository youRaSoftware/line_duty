import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Секция настроек: заголовок капсом и панель [AppColors.panel] с обводкой
/// [AppColors.stroke], в которой лежат строки.
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSection({
    required this.title,
    required this.children,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(title, style: AppFonts.best),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(AppDimens.panelRadius),
            border: Border.all(
              color: AppColors.stroke,
              width: AppDimens.strokeWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}
