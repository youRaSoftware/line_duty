// Smoke test for the real app on a device / simulator:
//
//   flutter test integration_test -d <deviceId> --flavor dev --dart-define=environment=dev
//
// Covers: menu renders → PLAY opens the game → first-launch tutorial pauses
// the field and closes on the last step → units spawn → a finger route
// drawn from a unit to its own gate delivers it (score grows) → pause /
// resume → back to the menu → settings toggle persists → «How to play»
// reopens the tutorial from settings → picking a theme in the menu applies
// the palette and persists.

import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:features/game/cubit/game_cubit.dart';
import 'package:features/game/engine/field_components.dart';
import 'package:features/game/engine/game_tuning.dart';
import 'package:features/game/engine/line_duty_game.dart';
import 'package:features/game/engine/unit_component.dart';
import 'package:features/game/widgets/game_hud.dart';
import 'package:features/game/widgets/pause_overlay.dart';
import 'package:features/game/widgets/tutorial_overlay.dart';
import 'package:features/menu/screen/menu_form.dart';
import 'package:features/menu/widgets/menu_theme_strip.dart';
import 'package:features/settings/screen/settings_form.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:line_duty/main_common.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // Real-time frames: with the default policy the engine only ticks on
  // pump(), so pump(3 s) would step the game once with dt = 3 s.
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('menu → game → route to gate → pause → settings',
      (WidgetTester tester) async {
    await mainCommon(Flavor.dev);
    addTearDown(appLocator<AudioService>().dispose);
    final SettingsService settings = appLocator<SettingsService>();
    await settings.setLocale(null);
    // Первый запуск — независимо от того, что осталось в Hive симулятора.
    await settings.setTutorialSeen(false);
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.byKey(MenuForm.playButtonKey), findsOneWidget);
    await tester.tap(find.byKey(MenuForm.playButtonKey));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(GameHud.pauseButtonKey), findsOneWidget);

    final GameWidget<LineDutyGame> widget =
        tester.widget<GameWidget<LineDutyGame>>(
            find.byType(GameWidget<LineDutyGame>));
    final LineDutyGame game = widget.game!;
    final GameCubit cubit = BlocProvider.of<GameCubit>(
      tester.element(find.byType(GameWidget<LineDutyGame>)),
    );

    // First launch: the tutorial is up and the field stands still.
    expect(find.byKey(TutorialOverlay.nextKey), findsOneWidget);
    expect(game.paused, isTrue);
    expect(game.units, isEmpty);
    for (int i = 0; i < 4; i++) {
      await tester.tap(find.byKey(TutorialOverlay.nextKey));
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(find.byKey(TutorialOverlay.nextKey), findsNothing);
    expect(game.paused, isFalse);
    expect(settings.value.tutorialSeen, isTrue);
    debugPrint('SMOKE tutorial done');

    // Wait for the first unit.
    await tester.pump(const Duration(milliseconds: 1500));
    expect(game.units, isNotEmpty, reason: 'a unit spawned');
    final UnitComponent unit = game.units.first;
    final GateComponent gate =
        game.gates.firstWhere((GateComponent g) => g.color == unit.color);
    debugPrint(
        'SMOKE unit ${unit.color} at ${unit.position}, gate at ${gate.position}');

    // Drag from the unit straight to its gate (screen = field × zoom).
    final Rect canvas = tester.getRect(find.byType(GameWidget<LineDutyGame>));
    final double zoom = canvas.width / AppDimens.fieldWidth;
    Offset toScreen(Vector2 p) => canvas.topLeft + Offset(p.x, p.y) * zoom;
    final Vector2 target = gate.position - Vector2(0, gate.size.y);
    final TestGesture gesture =
        await tester.startGesture(toScreen(unit.position));
    await tester.pump(const Duration(milliseconds: 40));
    const int steps = 12;
    for (int i = 1; i <= steps; i++) {
      final Vector2 p = unit.position + (target - unit.position) * (i / steps);
      await gesture.moveTo(toScreen(p));
      await tester.pump(const Duration(milliseconds: 30));
    }
    expect(identical(game.drawing, unit), isTrue, reason: 'the unit is picked');
    expect(unit.route, isNotEmpty);
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));
    expect(game.drawing, isNull);

    // The unit rides the route into its gate.
    final double seconds =
        unit.position.distanceTo(target) / GameTuning.speedStart + 1.5;
    await tester.pump(Duration(milliseconds: (seconds * 1000).round()));
    expect(cubit.state.score, greaterThanOrEqualTo(GameRules.scorePerDelivery),
        reason: 'delivered → score');
    debugPrint('SMOKE delivered, score ${cubit.state.score}');

    // Pause → resume.
    await tester.tap(find.byKey(GameHud.pauseButtonKey));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(PauseOverlay.resumeKey), findsOneWidget);
    expect(game.paused, isTrue);
    await tester.tap(find.byKey(PauseOverlay.resumeKey));
    await tester.pump(const Duration(milliseconds: 400));
    expect(game.paused, isFalse);

    // Pause → menu.
    await tester.tap(find.byKey(GameHud.pauseButtonKey));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text(LocaleKeys.pause_menu.tr()));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byKey(MenuForm.playButtonKey), findsOneWidget);

    // Settings: sound toggle persists.
    await tester.tap(find.byKey(MenuForm.settingsButtonKey));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byKey(SettingsForm.backKey), findsOneWidget);
    final bool before = appLocator<SettingsService>().value.soundOn;
    await tester.tap(find.text(LocaleKeys.settings_sounds.tr()));
    await tester.pump(const Duration(milliseconds: 300));
    expect(appLocator<SettingsService>().value.soundOn, !before);
    expect((await appLocator<SettingsRepository>().getSettings()).soundOn,
        !before);
    await tester.tap(find.text(LocaleKeys.settings_sounds.tr()));
    await tester.pump(const Duration(milliseconds: 300));

    // «How to play» reopens the tutorial; skip closes it.
    await tester.tap(find.byKey(SettingsForm.howToPlayKey));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(TutorialOverlay.skipKey), findsOneWidget);
    await tester.tap(find.byKey(TutorialOverlay.skipKey));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(TutorialOverlay.skipKey), findsNothing);

    await tester.tap(find.byKey(SettingsForm.backKey));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byKey(MenuForm.playButtonKey), findsOneWidget);

    // Theme strip: «City» applies the palette live and persists.
    final String themeBefore = settings.value.themeId;
    await tester.tap(find.byKey(MenuThemeStrip.keyFor('city')));
    await tester.pump(const Duration(milliseconds: 600));
    expect(settings.value.themeId, 'city');
    expect(
        (await appLocator<SettingsRepository>().getSettings()).themeId, 'city');
    expect(AppColors.current.id, 'city');
    expect(find.byKey(MenuForm.playButtonKey), findsOneWidget,
        reason: 'menu survives the remount');
    final GridPainter grid = tester
        .widget<CustomPaint>(find
            .descendant(
              of: find.byType(GridBackground),
              matching: find.byType(CustomPaint),
            )
            .first)
        .painter! as GridPainter;
    expect(grid.color, AppPalettes.city.gridDot,
        reason: 'const widgets repaint after the theme remount');
    await tester.pump(const Duration(seconds: 2)); // screenshot window
    await settings.setThemeId(themeBefore);
    await tester.pump(const Duration(milliseconds: 600));
    expect(AppColors.current.id, themeBefore);
    debugPrint('SMOKE OK');
  });
}
