import 'dart:math' as math;
import 'dart:ui';

import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:features/game/engine/line_duty_game.dart';
import 'package:features/game/engine/skins/field_skin.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => AppColors.apply(AppPalettes.metro));

  test('every skin has a gate shape that contains the zone centre', () {
    for (final FieldSkin skin in FieldSkins.all) {
      const Size zone = Size(AppDimens.gateWidth, AppDimens.gateHeight);
      expect(skin.gateShape.contains(const Offset(33.35, 30), zone), isTrue,
          reason: skin.id);
      expect(skin.gateShape.contains(const Offset(-20, -20), zone), isFalse,
          reason: skin.id);
    }
  });

  test('every palette has a skin and byId falls back to metro', () {
    for (final AppPalette palette in AppPalettes.all) {
      expect(FieldSkins.byId(palette.id).id, palette.id);
    }
    expect(FieldSkins.byId('nope').id, 'metro');
    expect(FieldSkins.all.map((FieldSkin s) => s.id),
        AppPalettes.all.map((AppPalette p) => p.id));
  });

  test('skins paint units, gates, spawners and decor without throwing', () {
    for (final FieldSkin skin in FieldSkins.all) {
      AppColors.apply(AppPalettes.byId(skin.id));
      final PictureRecorder recorder = PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      for (final LaneColor color in LaneColor.values) {
        for (final double angle in <double>[0, math.pi / 2, -2.3]) {
          for (final double time in <double>[0, 0.1, 1.7]) {
            skin.paintUnit(
              canvas,
              center: const Offset(50, 50),
              angle: angle,
              color: color,
              time: time,
            );
          }
        }
        for (final double fill in <double>[0.16, 0.34, 0.66]) {
          skin.paintGate(
            canvas,
            size: const Size(AppDimens.gateWidth, AppDimens.gateHeight),
            color: color,
            fill: fill,
          );
        }
      }
      skin.paintSpawner(
          canvas, const Size(AppDimens.spawnWidth, AppDimens.spawnHeight));
      skin.paintDecor(canvas, const Size(360, 780), time: 3.2);
      expect(recorder.endRecording(), isNotNull, reason: skin.id);
    }
  });

  test('the game picks the skin of the current palette', () async {
    final LineDutyGame game = LineDutyGame(random: math.Random(1));
    game.onGameResize(Vector2(360, 780));
    await game.onLoad();
    expect(game.skin.id, 'metro');
    AppColors.apply(AppPalettes.city);
    expect(game.skin.id, 'city');
    AppColors.apply(AppPalettes.metro);
    expect(game.skin.id, 'metro');
  });
}
