// Временный рендер хитбоксов в build/hitboxes/<skin>.png. Не коммитить.
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:features/game/engine/hit_capsule.dart';
import 'package:features/game/engine/skins/field_skin.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppColors.apply(AppPalettes.metro));

  test('render hitboxes', () async {
    final Directory dir = Directory('../build/hitboxes')
      ..createSync(recursive: true);
    for (final FieldSkin skin in FieldSkins.all) {
      AppColors.apply(AppPalettes.byId(skin.id));
      const double scale = 3;
      const double w = 360;
      const double h = 250;
      final ui.PictureRecorder rec = ui.PictureRecorder();
      final Canvas canvas = Canvas(rec);
      canvas.scale(scale);
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, w, h),
        Paint()..color = AppColors.bgField,
      );
      final Paint hit = Paint()
        ..color = const Color(0xFFFF3B30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      final Paint base = Paint()
        ..color = const Color(0xFF34C759)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Ряд 1: персонаж вправо, вниз, по диагонали.
      final List<(Offset, double)> poses = <(Offset, double)>[
        (const Offset(60, 60), 0),
        (const Offset(180, 60), math.pi / 2),
        (const Offset(300, 60), math.pi / 4),
      ];
      for (final (Offset c, double angle) in poses) {
        skin.paintUnit(
          canvas,
          center: c,
          angle: angle,
          color: LaneColor.red,
          time: 0.4,
        );
        // Базовый круг 32 (захват пальцем, край, ворота).
        FieldSkin.dashed(
          canvas,
          Path()
            ..addOval(
                Rect.fromCircle(center: c, radius: AppDimens.unitSize / 2)),
          base,
          dash: 3,
          gap: 3,
        );
        // Капсула столкновения.
        final HitCapsule cap = skin.hitbox;
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(angle);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cap.offset, 0),
              width: 2 * cap.halfLength + 2 * cap.radius,
              height: 2 * cap.radius,
            ),
            Radius.circular(cap.radius),
          ),
          hit,
        );
        canvas.restore();
      }

      // Ряд 2: две соседние базы (красная и янтарная) как в разметке.
      const double gateY = 200;
      final Vector2 heading = Vector2(0, 1);
      for (final (double cx, LaneColor color) in <(double, LaneColor)>[
        (0.14 * 360 + 60, LaneColor.red),
        (0.38 * 360 + 60, LaneColor.amber),
      ]) {
        final Rect zone = Rect.fromCenter(
          center: Offset(cx, gateY),
          width: AppDimens.gateWidth,
          height: AppDimens.gateHeight,
        );
        canvas.save();
        canvas.translate(zone.left, zone.top);
        skin.paintGate(
          canvas,
          size: zone.size,
          color: color,
          fill: 0.16,
        );
        canvas.restore();
        // Форма базы под капотом (фиолетовый).
        canvas.save();
        canvas.translate(zone.left, zone.top);
        canvas.drawPath(
          skin.gateShape.outline(zone.size),
          Paint()
            ..color = const Color(0xFFAF52DE)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
        canvas.restore();
        // Зона ворот (оранжевый) и зона захвата с запасом (пунктир).
        canvas.drawRect(
          zone,
          Paint()
            ..color = const Color(0xFFFF9500)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
      }
      // Линия судейства — верх зоны ворот.
      canvas.drawLine(
        Offset(0, gateY - AppDimens.gateHeight / 2),
        Offset(w, gateY - AppDimens.gateHeight / 2),
        hit..strokeWidth = 0.8,
      );
      // Фигура в зазоре между базами на уровне линии.
      final Offset judged =
          Offset(0.14 * 360 + 60 + 44, gateY - AppDimens.gateHeight / 2);
      skin.paintUnit(canvas,
          center: judged, angle: math.pi / 2, color: LaneColor.red);
      FieldSkin.dashed(
        canvas,
        Path()
          ..addOval(
              Rect.fromCircle(center: judged, radius: AppDimens.unitSize / 2)),
        base,
        dash: 3,
        gap: 3,
      );
      heading.setValues(0, 1);

      final ui.Image img = await rec
          .endRecording()
          .toImage((w * scale).toInt(), (h * scale).toInt());
      final ByteData? bytes =
          await img.toByteData(format: ui.ImageByteFormat.png);
      File('${dir.path}/${skin.id}.png')
          .writeAsBytesSync(bytes!.buffer.asUint8List());
    }
    expect(dir.listSync().length, FieldSkins.all.length);
  });
}
