// Временный тест для съёмки скриншотов сторов (STORE_LISTINGS.md § 6),
// запускается через script/store_shots.sh:
//   flutter test integration_test/store_shots_test.dart -d <udid> --flavor prod \
//     --dart-define=environment=prod --dart-define=shotLocale=en
import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:features/game/cubit/game_cubit.dart';
import 'package:features/game/engine/field_components.dart';
import 'package:features/game/engine/line_duty_game.dart';
import 'package:features/game/engine/unit_component.dart';
import 'package:features/game/widgets/game_hud.dart';
import 'package:features/game/widgets/tutorial_overlay.dart';
import 'package:features/menu/screen/menu_form.dart';
import 'package:features/menu/widgets/menu_theme_strip.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:line_duty/main_common.dart';

const String shotLocale =
    String.fromEnvironment('shotLocale', defaultValue: 'en');

void main() {
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  testWidgets('store shots', (WidgetTester tester) async {
    await mainCommon(Flavor.prod);
    final SettingsService settings = appLocator<SettingsService>();
    await appLocator<RunRepository>().clear();
    await settings.setTutorialSeen(true);
    await settings.setThemeId('metro');
    await settings.setLocale(shotLocale);
    await tester.pump(const Duration(milliseconds: 800));
    await tester
        .element(find.byKey(MenuForm.playButtonKey))
        .setLocale(AppLocalizationEnum.byCode(shotLocale)!.locale);
    await tester.pump(const Duration(milliseconds: 800));

    Future<void> shot(String n) async {
      await tester.pump(const Duration(milliseconds: 300));
      debugPrint('SHOT $n');
      await tester.pump(const Duration(seconds: 4));
    }

    LineDutyGame game() => tester
        .widget<GameWidget<LineDutyGame>>(find.byType(GameWidget<LineDutyGame>))
        .game!;

    GameCubit cubit() => BlocProvider.of<GameCubit>(
          tester.element(find.byType(GameWidget<LineDutyGame>)),
        );

    RunSnapshot quiet(List<UnitSnapshot> units) => RunSnapshot(
          score: 0,
          delivered: 0,
          continues: 0,
          counted: false,
          savedDelivered: 0,
          freezeLeft: 0,
          multiplierLeft: 0,
          spawnIn: 1e6,
          pickupIn: 1e6,
          pickup: null,
          units: units,
          savedAt: DateTime.now(),
        );

    UnitSnapshot unitAt(LaneColor c, double x, double y) =>
        UnitSnapshot(color: c, x: x, y: y, headingX: 0, headingY: 1);

    Future<void> play() async {
      await tester.tap(find.byKey(MenuForm.playButtonKey));
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.byKey(GameHud.pauseButtonKey), findsOneWidget);
      // Silence the auto-spawner and pickups while we stage the scene.
      game().restore(quiet(const <UnitSnapshot>[]));
      await tester.pump(const Duration(milliseconds: 300));
    }

    Future<void> backToMenu() async {
      await tester.tap(find.byKey(GameHud.pauseButtonKey));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text(LocaleKeys.pause_restart.tr()));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byKey(GameHud.pauseButtonKey));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text(LocaleKeys.pause_menu.tr()));
      await tester.pump(const Duration(milliseconds: 900));
      expect(find.byKey(MenuForm.playButtonKey), findsOneWidget);
    }

    // Route a unit to its gate with a bend so the line reads as hand-drawn.
    void routeHome(LineDutyGame g, UnitComponent u, {double bend = 60}) {
      final GateComponent gate = g.gateFor(u.color);
      final Vector2 a = u.position.clone();
      final Vector2 c = Vector2(gate.position.x, gate.top - 4);
      final Vector2 b = Vector2((a.x + c.x) / 2 + bend, (a.y + c.y) / 2);
      g.routeStart(a);
      const int n = 40;
      for (int i = 1; i <= n; i++) {
        final double t = i / n;
        final Vector2 p =
            a * (1 - t) * (1 - t) + b * 2 * (1 - t) * t + c * t * t;
        g.routeMove(p);
        if (g.drawing == null) break; // docked
      }
      g.routeEnd();
    }

    // Deterministic scene: red on the left, blue on the right (routes never
    // cross), amber idling down the middle; a score in the HUD.
    Future<void> stageTwoRoutes({int score = 3}) async {
      final LineDutyGame g = game();
      for (int i = 0; i < score; i++) {
        cubit().onDelivered();
      }
      final double w = g.fieldWidth; // 360 on phones, wider on tablets
      g.restore(quiet(<UnitSnapshot>[
        unitAt(LaneColor.red, w * 138 / 360, 165),
        unitAt(LaneColor.blue, w * 224 / 360, 225),
        unitAt(LaneColor.amber, w * 302 / 360, 110),
      ]));
      await tester.pump(const Duration(milliseconds: 200));
      routeHome(g, g.units[0], bend: 58);
      routeHome(g, g.units[1], bend: -58);
      await tester.pump(const Duration(milliseconds: 1500));
    }

    // 05 — menu.
    await shot('05');

    // 01 — Metro field with two routes, 04 — warning.
    await play();
    await stageTwoRoutes();
    await shot('01');
    final LineDutyGame g = game();
    final double mid = g.fieldWidth / 2;
    g.restore(quiet(<UnitSnapshot>[
      unitAt(LaneColor.blue, mid - 30, 380),
      unitAt(LaneColor.red, mid + 16, 388),
      unitAt(LaneColor.green, g.fieldWidth * 300 / 360, 160),
    ]));
    await tester.pump(const Duration(milliseconds: 120));
    expect(g.warnings, isNotEmpty, reason: 'warning ring is up');
    await shot('04');
    await backToMenu();

    // 02 — City, 03 — Aquarium.
    for (final (String theme, String n, int score) in <(String, String, int)>[
      ('city', '02', 5),
      ('aquarium', '03', 7),
    ]) {
      await tester.tap(find.byKey(MenuThemeStrip.keyFor(theme)));
      await tester.pump(const Duration(milliseconds: 800));
      await play();
      await stageTwoRoutes(score: score);
      await shot(n);
      await backToMenu();
    }

    // 06 — tutorial, bonuses step, in Metro.
    await tester.tap(find.byKey(MenuThemeStrip.keyFor('metro')));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(find.byKey(MenuForm.settingsButtonKey));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(find.byKey(const Key('settings_how_to_play')));
    await tester.pump(const Duration(milliseconds: 600));
    for (int i = 0; i < 4; i++) {
      await tester.tap(find.byKey(TutorialOverlay.nextKey));
      await tester.pump(const Duration(milliseconds: 400));
    }
    await shot('06');
    await tester.tap(find.byKey(TutorialOverlay.nextKey));
    await tester.pump(const Duration(milliseconds: 400));

    await settings.setLocale(null);
    await tester.element(find.byType(Scaffold).first).resetLocale();
    await tester.pump(const Duration(milliseconds: 500));
    debugPrint('SHOTS DONE');
  });
}
