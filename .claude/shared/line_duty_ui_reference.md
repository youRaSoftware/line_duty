# Line Duty — UI / Architecture Reference

Single source of truth for design tokens, widget inventory, composition rules and code style. Read in full by the `create-feature-ui`, `create-feature-full`, `create-widget`, `analyze-feature` and `audit-section` skills before generating or reviewing code.

Product spec (mechanics, palette, sizes, frames 1a / 2a / 2b / 2c): `.claude/my_docs/SPEC.md`; PNG mockups in `.claude/my_docs/refs/`. The architecture is copied from the WasDrop project (`../wasdrop`): core / core_ui / domain / data / features / navigation, Cubit + get_it + go_router + Hive + easy_localization.

---

## § 1 — Design System

Tokens are plain `static const` classes in `core_ui/lib/src/theme/`, re-exported by `package:core_ui/core_ui.dart`. No token generator, no theme provider, no `flutter_screenutil`. **One theme, dark** (`darkTheme`, `ThemeMode.dark` forced in `lib/app.dart`).

Spec sizes are in px of a 1080×2340 canvas; logical px = spec / 3 (`AppDimens.fieldWidth` = 360).

### 1.1 Colors — `AppColors`

| Group | Constants |
|---|---|
| Surfaces | `bgField` `#0D131E` (every screen), `panel` `#131C2B` (spawners, overlay panels, settings cards), `gridDot` `#1B2635` |
| Lines | `stroke` `#243349` (icon buttons, panels, spawners), `strokeSecondary` `#33455F` (secondary / dashed buttons) |
| Text | `textPrimary` `#E8EDF4`, `textSecondary` `#7E93B0`, `buttonLight` `#E8EDF4` (light button fill; its label is `bgField`) |
| Semantic | `danger` `#FF4757` (warning ring, crash flash, DEV banner), `record` `#F2B233` (record badge), `scrim` `#D1090D14` (82 % game-over dim), `white` |
| Lanes | `laneRed` `#E8503A`, `laneAmber` `#F2B233`, `laneGreen` `#2EB872`, `laneBlue` `#3E8BE8`; `AppColors.lane(LaneColor)` |

**Rule:** never write `Color(0xFF…)` / `Colors.x` in `features/` — add a constant to `AppColors`.

### 1.2 Typography — `AppFonts`

Two families: **Golos Text** for all UI (`AppFonts.family`, also `ThemeData.fontFamily`) and **Unbounded** for display text only (`AppFonts.displayFamily`: the menu title and the game-over score). Both variable TTFs, weights 500 / 700, Cyrillic + Latin, OFL in `core/resources/fonts/`; the OFL texts are assets registered in `LicenseRegistry`. Digits are always tabular. Never use `displayFamily` for buttons or body text.

| Style | Spec | Where |
|---|---|---|
| `score` | 22 / w700, tabular | HUD score (`padLeft(4, '0')`) |
| `best` | 11 / w500, ls 1, `textSecondary` | «РЕКОРД …», section captions, «СЧЁТ» |
| `button` | 18 / w700, ls 1.5, `bgField` | light buttons; secondary / text buttons `copyWith(color:)` |
| `title` | 44 / w700, ls 4.5 | menu logo |
| `caption` | 14 / w500, ls 3, `textSecondary` | menu subtitle, overlay titles («ПАУЗА», «СТОЛКНОВЕНИЕ») |
| `bigScore` | 68 / w700, tabular | game-over score |
| `body` | 15 / w500 | settings rows |

### 1.3 Dimensions — `AppDimens`

Field: `fieldWidth` 360, `unitSize` 32 / `unitRadius` 9.3, `gateWidth/Height` 66.7×43.3 r8, `spawnWidth/Height` 53.3×29.3 r6.7, `routeWidth` 4.7 + `routeHalo` 10, `fingerDot` 6.7 / `fingerRing` 30.7, `gridStep` 24 / `gridDot` 2.3, `warnRing` 73. UI: `playButtonHeight` 63 r15, `buttonHeight` 50 r12, `iconButtonSize` 50, `strokeWidth` 1.7, `panelRadius` 16, `panelPadding` 20, `minTapTarget` 44.

Gameplay numbers (speeds, spawn intervals, distances) live in `features/lib/game/engine/game_tuning.dart` (`GameTuning`), never in widgets.

### 1.4 Icons

Material rounded icons (`Icons.play_arrow_rounded`, `volume_up_rounded`, `settings_outlined`, `pause_rounded`, `star_outline_rounded`, `arrow_back_rounded`, `chevron_right_rounded`, `check_rounded`, `play_circle_outline_rounded`) tinted `textSecondary` on dark surfaces. No emoji. Lane glyphs (circle / square / triangle / diamond) are drawn by `LaneGlyphPainter.draw` — shared by the `LaneGlyphIcon` widget and the engine.

### 1.5 Widget inventory — `core_ui/lib/src/widgets/` (barrel `widgets.dart`)

| Widget | API |
|---|---|
| `AppPressable` | `builder(context, pressed, child)`, `onPressed`, `child` — base of every button; animates press 0…1, fires `ButtonFeedback.trigger()` |
| `AppScaffold` | `body`, `grid = true` — `bgField` + `GridBackground` dots; the game screen keeps the grid (engine background is transparent) |
| `GridBackground` / `GridPainter` | dot grid from the screen centre |
| `PrimaryButton` | `label`, `onPressed`, `height`, `radius`, `glow`, `icon` — light fill, dark label («Играть» with `glow: true`, «Заново») |
| `SecondaryButton` | `label`, `onPressed`, `icon` — outlined `strokeSecondary` («В меню») |
| `DashedButton` | `label`, `onPressed`, `icon` — dashed frame («Продолжить · реклама») |
| `AppTextButton` | `label`, `onPressed`, `icon` — text action ≥ 44 px («Отмена») |
| `IconSquareButton` | `icon`, `onPressed`, `size`, `iconSize` — rounded square outline (sound, settings, pause, back) |
| `AppToggleRow` | `label`, `value`, `onChanged` — settings row with a `laneBlue` pill |
| `AppOverlay` | `child`, `width`, `panel = true` — scrim + panel (pause, confirmations) or bare content on the scrim (`panel: false`, game over) |
| `RecordBadge` | `label` — «★ НОВЫЙ РЕКОРД» amber pill |
| `LaneGlyphIcon` | `glyph`, `size`, `filled`, `color` — lane glyph as a widget |
| `ButtonLabel` | `label`, `style`, `icon` — icon + text inside buttons |

**Feedback hook.** `ButtonFeedback.onPressed` is wired to `AudioService.tap` in `lib/main_common.dart`; never call `HapticFeedback` or play audio from `core_ui`.

Feature-local widgets: `features/lib/game/widgets/` → `GameHud`, `PauseOverlay`, `GameOverOverlay`; `features/lib/menu/widgets/` → `MenuDemoField`; `features/lib/settings/widgets/` → `SettingsSection`, `SettingsValueRow`, `SettingsLinkRow`, `ResetStatsOverlay`, `LanguageOverlay`.

---

## § 2 — Composition Rules

### 2.1 Screen → Form split
A feature screen is two files: the **Screen** is a thin `BlocProvider` shell, the **Form** owns layout (`GameScreen` / `GameForm`, `MenuScreen` / `MenuForm`, `SettingsScreen` / `SettingsForm`). Every screen has a cubit.

### 2.2 One public widget per file
File name = snake_case of the widget; small private helpers may live below the public one. Needed from a second file → promote to its own file (feature `widgets/` or `core_ui`).

### 2.3 No widget-returning methods
Inline the subtree in `build()` or extract a widget class.

### 2.4 Cubit access
Children under the same `BlocProvider` read the cubit themselves (`context.read` for callbacks, `context.watch().state` / `BlocBuilder` for rebuilds). Presentational widgets take plain values + callbacks (`GameOverOverlay(score:, onRestart:, …)`).

### 2.5 Feature folder layout
```
features/lib/{feature}/
├── cubit/{feature}_cubit.dart + {feature}_state.dart (part of)
├── screen/{feature}_screen.dart + {feature}_form.dart
├── widgets/            # optional, flat
└── engine/             # game only: Flame components
```

### 2.6 Localization
`context.tr(LocaleKeys.x)` in widgets; new text = key in `core/resources/translations/en-US.json` **and** `ru-RU.json` + regenerate `LocaleKeys` (`script/prebuild_script.sh`). No string literals in widgets, caps in the translation.

---

## § 3 — Data & State

```
Hive Box<dynamic> → {Name}HiveProvider (data/lib/providers/local/) → {Name}RepositoryImpl (data/lib/repositories/)
→ {Name}Repository (domain/lib/repositories/) → Cubit (constructor-injected) → Equatable State → Screen → Form
```
Pairs today: `StatsHiveProvider` / `StatsRepositoryImpl` (`statsBox`: bestScore, gamesPlayed, totalDelivered), `SettingsHiveProvider` / `SettingsRepositoryImpl` (`settingsBox`: soundOn, hapticsOn, locale). Box names are duplicated in `StorageConstants` (core) and `DataDI.init()` (data). Services in `appLocator`: `AppConfig`, `SettingsService` (ValueNotifier of `SettingsModel`), `AudioService`, `AppRouter`.

State: `Equatable`, manual `copyWith`, `_safeEmit` (guards `isClosed`) in cubits with async init.

---

## § 4 — Engine (`features/lib/game/engine/`)

`LineDutyGame extends FlameGame with DragCallbacks` — camera anchored top-left, zoom = widget width / 360, so components live in field units. `GameListener` (implemented by `GameCubit`) receives `onDelivered / onWarning / onRouteStarted / onCrash(wrongGate:)`. Components: `UnitComponent` (route following, trace, bounds), `GateComponent`, `SpawnerComponent`, `RouteLayer` (routes, traces, finger halo, priority −10), `OverlayLayer` (finger ring, warning rings, crash flash, priority 10). Numbers in `GameTuning`. `demo: true` = menu background (auto routes, no crashes, no input).
