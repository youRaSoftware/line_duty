import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

/// Палитра темы A «Диспетчер метро» (спека, «Палитра»). Тёмная, одна.
class AppColors {
  const AppColors._();

  /// Фон поля и всех экранов.
  static const Color bgField = Color(0xFF0D131E);

  /// Точки сетки фона.
  static const Color gridDot = Color(0xFF1B2635);

  /// Панели и обводки UI.
  static const Color panel = Color(0xFF131C2B);
  static const Color stroke = Color(0xFF243349);
  static const Color strokeSecondary = Color(0xFF33455F);

  static const Color textPrimary = Color(0xFFE8EDF4);
  static const Color textSecondary = Color(0xFF7E93B0);

  /// Заливка светлых кнопок («Играть», «Заново»); текст на них — [bgField].
  static const Color buttonLight = Color(0xFFE8EDF4);

  /// Опасность: кольцо сближения, вспышка столкновения.
  static const Color danger = Color(0xFFFF4757);

  /// Затемнение экрана проигрыша (82 %).
  static const Color scrim = Color(0xD1090D14);

  /// Бейдж «Новый рекорд» — янтарный.
  static const Color record = Color(0xFFF2B233);

  static const Color white = Color(0xFFFFFFFF);

  static const Color laneRed = Color(0xFFE8503A);
  static const Color laneAmber = Color(0xFFF2B233);
  static const Color laneGreen = Color(0xFF2EB872);
  static const Color laneBlue = Color(0xFF3E8BE8);

  /// Цвет потока: фигура, её линия и ворота.
  static Color lane(LaneColor color) {
    switch (color) {
      case LaneColor.red:
        return laneRed;
      case LaneColor.amber:
        return laneAmber;
      case LaneColor.green:
        return laneGreen;
      case LaneColor.blue:
        return laneBlue;
    }
  }
}
