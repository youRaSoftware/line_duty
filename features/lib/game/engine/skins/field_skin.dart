import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';

import 'city_skin.dart';
import 'metro_skin.dart';

/// Графика темы на поле: фигура, ворота, спавн, декор фона. Геометрия
/// (хитбокс Ø32 ед., ворота 66.7×43.3, спавн 53.3×29.3) и правила у всех
/// тем общие; скин только рисует — цвета берёт из текущей палитры
/// ([AppColors]). Все размеры в единицах поля (1 ед. = 3 px холста спеки).
abstract class FieldSkin {
  const FieldSkin();

  /// Совпадает с `AppPalette.id`.
  String get id;

  /// Фигура с центром [center]; [angle] — направление движения в радианах
  /// (вниз = π/2). Значок потока не вращается.
  void paintUnit(
    Canvas canvas, {
    required Offset center,
    required double angle,
    required LaneColor color,
  });

  /// Ворота в локальных координатах (0,0)–[size]; [fill] — прозрачность
  /// заливки: 0.16 покой, 0.34 взведены, до 0.66 во вспышке доставки.
  void paintGate(
    Canvas canvas, {
    required Size size,
    required LaneColor color,
    required double fill,
  });

  /// Спавн (спека: 160×88 r20, заливка `panel`, обводка `stroke`) с
  /// шевроном вниз — общий для тем.
  void paintSpawner(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(AppDimens.spawnRadius),
    );
    canvas.drawRRect(rrect, Paint()..color = AppColors.panel);
    final Paint stroke = Paint()
      ..color = AppColors.stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawRRect(rrect, stroke);
    final double cx = rect.center.dx;
    final double y = rect.bottom + 8;
    canvas.drawPath(
      Path()
        ..moveTo(cx - 6, y)
        ..lineTo(cx, y + 5)
        ..lineTo(cx + 6, y),
      stroke..strokeWidth = 2,
    );
  }

  /// Декор фона под маршрутами на всё поле [field]; по умолчанию пусто.
  void paintDecor(Canvas canvas, Size field) {}
}

/// Все скины; порядок [all] — порядок ленты тем в меню.
abstract final class FieldSkins {
  static const MetroSkin metro = MetroSkin();
  static const CitySkin city = CitySkin();

  static const List<FieldSkin> all = <FieldSkin>[metro, city];

  /// По id палитры; неизвестный — [metro].
  static FieldSkin byId(String? id) {
    for (final FieldSkin skin in all) {
      if (skin.id == id) return skin;
    }
    return metro;
  }
}
