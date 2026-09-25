# Line Duty — заметки для Claude Code

Аркада на разведении потоков (тема A «Диспетчер метро», спека `.claude/my_docs/SPEC.md`): фигуры выезжают из спавнов сверху и едут вниз, игрок пальцем рисует им маршруты, ворота своего цвета внизу принимают фигуру, касание двух фигур (или чужие ворота) — конец забега. Витринное название **Line Duty** (под иконкой — **Line Duty**, dev — **Line Dev**: `APP_DISPLAY_NAME` в pbxproj, `resValue app_name` в gradle, `AppConfig.appName`). Внутреннее имя проекта и пакетов — `line_duty`, bundle id `com.lineduty` (prod) / `com.lineduty.dev` (dev). Flutter + Flame (без физики), портрет, без сети.

Архитектура скопирована с проекта WasDrop (`../wasdrop`): пакеты core / core_ui / domain / data / features / navigation, BLoC (Cubit), get_it (`appLocator`), go_router, Hive, easy_localization. Отличия: нет forge2d, нет рекламы/покупок/Game Center (пока), одна тёмная тема, два языка.

## Рабочая папка Claude (`.claude/`)

**ВАЖНО:** все документы Claude живут в `.claude/`. Не создавать `.md` в корне проекта — там только `CLAUDE.md` и `README.md`.

```
.claude/
├── SKILLS_GUIDE.md             # Как пользоваться скиллами
├── settings.json               # Общие настройки Claude Code (в git); settings.local.json — локальные (не в git)
├── plans/plan.md               # Основной план: статус, фазы, бэклог
├── changelog/CHANGELOG.md      # User-facing changelog (Keep a Changelog + SemVer, RU/EN)
├── my_docs/
│   ├── SPEC.md                 # Спека v2: механика, темы (палитры, спрайты), бонусы, экраны; v1 — SPEC_v1_metro.md
│   └── refs/                   # PNG-референсы: 1a/2a/2b/2c (метро), 4d иконка, 5a бонусы, 6b/6d/6e поля тем, 7b/7e/7f/7g спрайты
├── shared/line_duty_ui_reference.md  # UI/архитектурный референс для create-* скиллов
└── skills/                     # create-feature-ui, create-feature-full, create-widget, analyze-feature, audit-section, llm-council
```

### Куда что класть
- **Планы** → `.claude/plans/` (основной — `plan.md`; большие отдельные задачи — свой файл)
- **Changelog** → `.claude/changelog/CHANGELOG.md`
- **ТЗ, релизы, аудиты, анализы, описания сторов** → `.claude/my_docs/`

### Планирование и логирование изменений
1. Нетривиальная задача → `EnterPlanMode`, изучить код, записать план в `.claude/plans/plan.md`
2. Согласовать → реализовать
3. Готово → добавить user-facing пункт в `CHANGELOG.md` под `[Unreleased]`, отметить в `plan.md`

## Flavors: dev / prod

Нативные флейворы + dart-define — передавать **оба**:

```bash
script/run.sh dev                 # = flutter run --flavor dev --dart-define=environment=dev
script/run.sh prod --release
```

| | dev | prod |
|---|---|---|
| Android applicationId | `com.lineduty.dev` | `com.lineduty` |
| iOS bundle id / scheme | `com.lineduty.dev` / `dev` | `com.lineduty` / `prod` |
| Имя | Line Dev | Line Duty |
| Плашка «DEV» в углу | да | нет |

- Dart: `Flavor` + `AppConfig` в `core/lib/config/app_config.dart`; `lib/main.dart` читает `--dart-define=environment` (fallback — нативный `appFlavor`), `setupAppScope(flavor)` кладёт `AppConfig` в `appLocator`. Ветвиться по окружению только через `appLocator<AppConfig>()`, не через `kDebugMode`.
- Android: `productFlavors` в `android/app/build.gradle.kts` (+ `buildFeatures.resValues` для `app_name`), подпись release из `android/key.properties` (шаблон `key.properties.example`). `VIBRATE` в манифесте — для хаптики.
- iOS: минимальная версия 15.0, `ITSAppUsesNonExemptEncryption = false`; конфигурации `Debug|Release|Profile-dev|prod`, схемы `dev` / `prod`, `APP_DISPLAY_NAME` → `CFBundleDisplayName`. Подпись: команда Pavel Hrytsenka, `DEVELOPMENT_TEAM = 4YLBF6N3R4` (как у WasDrop; `IOS_TEAM_ID` в `script/build.sh`). CocoaPods не используется (все плагины — Swift Packages). Проект `ios/` скопирован из WasDrop и переименован; рекламные/Game Center настройки (`GAD_APPLICATION_ID`, entitlements, `-ObjC`, StoreKit-конфиг) вырезаны.
- Ориентация — только портрет на трёх уровнях: `SystemChrome` в `lib/main_common.dart`, `UISupportedInterfaceOrientations` + `UIRequiresFullScreen` в Info.plist, `android:screenOrientation="portrait"`.
- Android Studio: конфигурации запуска `.run/Dev.run.xml`, `.run/Prod.run.xml`.

## Скрипты (`script/`)

```bash
script/run.sh <dev|prod> [args]            # запуск
script/build.sh <dev|prod> <apk|aab|ipa> [--upload]   # релизная сборка (ipa --upload → App Store Connect)
script/build_app_builds.sh                 # то же интерактивно
script/prebuild_script.sh [--clean]        # pub get во всех пакетах + LocaleKeys
script/run_test_script.sh                  # тесты по пакетам + общий coverage/lcov.info
script/gen_placeholder_audio.py            # SFX в core/resources/audio/ (синтез, без лицензий)
script/gen_dev_icons.sh                    # dev-иконки с плашкой DEV из store/ (iOS + Android)
script/gen_launch_images.sh                # картинки нативного экрана запуска из store/
script/make_flat_icon.swift                # скруглённая иконка → непрозрачный квадрат (App Store)
script/make_adaptive_foreground.swift      # иконка → передний слой adaptive icon (70 %)
```

Проверка перед коммитом: `flutter analyze` и `dart format core core_ui data domain features lib navigation integration_test`.

Смоук-тест на симуляторе/устройстве (меню → игра → маршрут до ворот → пауза → настройки), `integration_test/game_smoke_test.dart`:

```bash
flutter test integration_test -d <deviceId> --flavor dev --dart-define=environment=dev
```

Правила таких тестов (как в WasDrop): `binding.framePolicy = fullyLive` (иначе движок тикает только на `pump()`), никакого `pumpAndSettle` (Flame рисует непрерывно, он не вернётся), только `pump(Duration)`.

## Структура пакетов
- **core/** — `AppConfig`/`Flavor`, `AppConstants` (ссылки, пока пустые), DI (`app_di.dart`), сервисы `SettingsService` / `AudioService`, локализация (`AppLocalizationEnum`, `LocaleKeys`; переводы в `resources/translations/`), константы роутов и Hive-боксов; реэкспортирует bloc/get_it/go_router/navigation/easy_localization
- **core_ui/** — `AppPalette`/`AppPalettes` (темы), `AppColors` (геттеры над текущей палитрой), `AppFonts`, `AppDimens`, `appTheme(palette)` / `systemUiStyle`, виджеты (`AppScaffold`, `GridBackground`, `PrimaryButton`, `SecondaryButton`, `DashedButton`, `AppTextButton`, `IconSquareButton`, `AppToggleRow`, `AppOverlay`, `RecordBadge`, `LaneGlyphIcon`/`LaneGlyphPainter`)
- **domain/** — `LaneColor` (red/amber/green/blue + `LaneGlyph`), `GameRules` (очки за доставку, продолжения), `GameStatsModel` (рекорд, забеги, доведено), `SettingsModel` (звук, вибрация, язык, тема, обучение), `RunSnapshot` (снимок незавершённого забега: счёт/продолжения/учёт, таймеры, пикап, фигуры с маршрутами), интерфейсы `StatsRepository` / `SettingsRepository` / `RunRepository`
- **data/** — Hive-провайдеры (`providers/local/`: stats, settings, `RunHiveProvider` — снимок забега одной Map под ключом `snapshot` в боксе `runBox`), реализации репозиториев, `DataDI.init()`
- **features/** — `menu/` (MenuCubit, MenuForm, `MenuDemoField` — движок в демо-режиме под UI), `game/` (cubit, screen, widgets — HUD, оверлеи паузы, проигрыша и онбординга `TutorialOverlay` + иллюстрации `TutorialArt`; `engine/` — Flame: `line_duty_game.dart`, `unit_component.dart`, `field_components.dart` (ворота, спавны), `field_layers.dart` (маршруты/следы, палец/кольца/вспышка), `game_tuning.dart`), `settings/` (cubit, screen, widgets)
- **navigation/** — `AppRouter` (go_router, стартовый `/menu`, `/game`, `/settings`, fade-переход)

Паттерны и стиль — `.claude/shared/line_duty_ui_reference.md`.

## Дизайн и темы
- **Темы** (спека v2 § 4): Метро (тёмная, дефолт), Город (автобусы), Аквариум (рыбки, градиент, пузырьки), Муравейник (муравьи), Сад (божьи коровки) — все сделаны, все открыты. Тема = `AppPalette` (core_ui, цвета; `AppPalettes.all/byId`, порядок = лента в меню) + `FieldSkin` (features, `game/engine/skins/`: `paintUnit(time:)/paintGate/paintSpawner/paintDecor(time:)` — `time` для анимации (хвост, лапки, пузырьки), фигура передаёт `game.time + phase`; `FieldSkins.byId`). Выбор — `SettingsModel.themeId` (Hive `themeId`, `SettingsService.setThemeId`), лента `MenuThemeStrip` в меню (`Key('theme_<id>')`).
- **Механизм палитры:** `AppColors` — статические геттеры над `AppColors.current`; `App` (`lib/app.dart`) слушает `SettingsService.settings`, зовёт `AppColors.apply(palette)` до построения дерева, строит `appTheme(palette)`, `AnnotatedRegion<SystemUiOverlayStyle>` и **перемонтирует контент по `KeyedSubtree(key: palette.id)`**, иначе `const`-виджеты не перерисуются. Движок и painter'ы читают геттеры на каждом кадре. **Ловушки:** никаких `AppColors.x` в `const`-выражениях и дефолтах `const`-конструкторов; painter'ы с цветами — `shouldRepaint => true`; `AppFonts` — геттеры; `GridBackground` в `AppScaffold` без `const`. Токены: `bgField`/`bgFieldEnd` (градиент), `gridDot`, `decor`/`decor2`, `structure` (грот/холмик/лист), `panel`, `stroke`/`strokeSecondary`, `textPrimary`/`textSecondary`, `buttonLight`/`buttonText`, `danger`, `pickup`, `accent`, `record`, `glyph`, `finger`, `fingerHalo`, `scrim`, `lane(LaneColor)`. Второй канал различения — значки круг / квадрат / треугольник / ромб (`LaneGlyph`).
- Метро: фон `0D131E`, сетка `1B2635`, панели `131C2B`, обводки `243349` / `33455F`, текст `E8EDF4` / `7E93B0`, опасность `FF4757`, потоки `E8503A` / `F2B233` / `2EB872` / `3E8BE8`. Город — см. таблицу в спеке.
- Шрифты — **Golos Text** (интерфейс, `AppFonts.family` и `ThemeData.fontFamily`) + **Unbounded** (`AppFonts.displayFamily`: название в меню, большой счёт проигрыша). Оба переменные, 500/700, кириллица + латиница, OFL в `core/resources/fonts/`, лицензии в `LicenseRegistry` (`lib/main_common.dart`). Space Grotesk из спеки заменён — без кириллицы. Размеры спеки (холст 1080 px) делены на 3.
- Иконки — Material rounded (`textSecondary`), без SVG и эмодзи.
- Нативный экран запуска: фон `0D131E` и иконка со скруглением по центру (iOS storyboard + `LaunchImage.imageset`, Android `launch_background` + системный splash 12+). Картинки — `script/gen_launch_images.sh` из `store/appstore_icon_1024.png`.
- Иконки приложения: исходник — `store/icon_rounded_1024.png` (настоящая иконка от дизайнера, 2026-09-22; скруглённая, прозрачные углы, фон `0D131E`), из него `appstore_icon_1024.png` (`script/make_flat_icon.swift … 0D131E`, без альфы), `android_adaptive_foreground_1024.png` (`script/make_adaptive_foreground.swift`), `playstore_icon_512.png`; наборы iOS `AppIcon` / `AppIcon-Dev` (`sips -z` из плоской 1024), Android mipmap (`ic_launcher` из скруглённой, `ic_launcher_foreground` из adaptive-переднего слоя) + `mipmap-anydpi-v26/ic_launcher.xml` (фон — сплошной `0D131E`), dev-вариант с плашкой в `android/app/src/dev/res` (`script/gen_dev_icons.sh`), экран запуска — `script/gen_launch_images.sh`. **Ловушка:** цвета PNG проверять по байтам (например, `python3` с `zlib`), а не через `NSImage`/`sips`/`colorAt` — они сдвигают значения через цветовой профиль.

## Движок (`features/lib/game/engine/`)
- `LineDutyGame extends FlameGame with DragCallbacks`. Координаты поля — логические единицы: ширина `AppDimens.fieldWidth` = 360 (1 ед. = 3 px холста спеки), высота от пропорции виджета; камера в левом верхнем углу с зумом `ширина виджета / 360`, входные точки делятся на зум. Фон движка прозрачный — фон и сетку рисует `AppScaffold`; декор темы — `DecorLayer` (priority −20) через `game.skin.paintDecor`. `game.skin` — скин текущей палитры (мемоизация по `AppColors.current.id`); `UnitComponent`/`GateComponent`/`SpawnerComponent` в `render` зовут скин (фигура: `headingAngle` = atan2 heading, сам компонент не вращается, хитбокс 32 остаётся).
- **Все числа геймплея — в `game_tuning.dart`** (`GameTuning`): скорость 38 → 74 ед/с и интервал спавна 3.2 → 1.25 с растут с числом доведённых фигур (потолок на 45), не больше 8 фигур, захват пальцем 26 ед., столкновение — по **капсульным хитбоксам скина** (`FieldSkin.hitbox`, `HitCapsule` в `hit_capsule.dart`: отрезок вдоль `heading` + радиус; Метро — круг Ø `crashDistance` = 0.92 стороны, автобус/муравей/рыбка — вытянутые), зазор < 0 = столкновение, < `warnGap` (24.6) = кольцо «!» между ближайшими точками осей; подбор пикапа — по зазору капсулы до точки; захват пальцем/края/ворота — по базовому кругу 32, вспышка 0.7 с, «Продолжить» чистит радиус 90.
- Отступы: форма отдаёт `setInsets(top: safeArea + HUD 64, bottom: safeArea + 8)` в логических px; в единицы поля переводятся в `_layout()` при первом размере (до него `size` у игры нет — ловушка Flame). Спавны (3, доли 0.2/0.5/0.8) на `spawnRowOffset` ниже верхнего отступа, ворота (4, в порядке `LaneColor.values`) на `gateRowOffset` выше нижнего.
- Фигура (`UnitComponent`): едет по `heading` (по умолчанию вниз); маршрут — список точек, съедается по мере движения, съеденные точки идут в `trace` (пунктир 30 %, гаснет за `traceSeconds`); **за концом маршрута поворачивает вниз** (маршрут — временное отклонение), без маршрута над своими воротами `_magnet` доворачивает к центру входа (`gateMagnetSlack/Speed`); боковой/верхний край разворачивает вниз и стирает маршрут. Новый жест по фигуре стирает старый маршрут (`beginRoute`) и ведёт её живьём, пока палец идёт. Логика жеста — `routeStart / routeMove / routeEnd` (drag-колбэки только переводят координаты — из `canvasStartPosition`, потому что `canvasEndPosition` у Flame = позиция + дельта, на шаг впереди пальца; тесты зовут методы напрямую). **Стыковка:** палец над своими воротами (или выше кромки на `gateDockMargin`) зовёт `UnitComponent.dockTo` — маршрут заканчивается входом в ворота (X пальца, зажатый внутрь ворот на радиус фигуры; Y — верхняя кромка), `docked` = ворота, жест закрывается сам; ворота с живым пристыкованным маршрутом подсвечены (`GateComponent.armed`, ставит `_armGates()` каждый кадр). Чужие ворота не стыкуют. Демо стыкует через тот же `dockTo`. Отладка хитбоксов и форм баз: `cd features && flutter test test/tools/render_hitboxes_test.dart` → `build/hitboxes/<skin>.png`.
- **Бонусы-пикапы** (спека § 5, `BonusKind` в domain, числа в `GameTuning`): `PickupComponent` (шестиугольник + пульсирующее кольцо, живёт `pickupLife`, `BonusPainter` — общие пиктограммы для поля, тоста и обучения), не больше одного на поле, спавн по таймеру в свободную точку (`_spawnPickup`, keep-out от ворот/спавнов/фигур), подбор — фигура пересекла радиус (`_collect`). Эффекты живут в движке: `freezeLeft` (фигуры стоят, спавн ждёт, рисовать можно), `multiplierLeft` (`onDelivered(doubled:)` → кубит ×`GameRules.bonusMultiplier`), щит на фигуре (`UnitComponent.shielded`; при столкновении снимается и даёт `ghostLeft` — сквозь других, полупрозрачная), автопилот — `_autoRoute` подобравшей. `OverlayLayer` рисует ореол щита, кольца заморозки, вспышку `burstAt` и пилюли активных эффектов по центру HUD (`topInset`). Кубит: `onBonusPicked` → `GameState.bonusToast` на `toastDuration`, виджет `BonusToast` под HUD. В демо пикапов нет; `reset/clearCrash` сбрасывают эффекты. Тесты — `spawnPickupNow`.
- Ворота судятся по **форме базы скина** (`FieldSkin.gateShape` → `GateShape` в `gate_shape.dart`: `RectGateShape` Метро/Город, `DomeGateShape` арка Аквариума и купол Муравейника, `RingGateShape` Сад; `GateComponent.distanceTo/holds`): **свои ловят** — `UnitComponent.gapToGate(own) < 0` (капсула задела форму с любой стороны) → доставка (+`GameRules.scorePerDelivery`, вспышка ворот); **чужие убивают при заезде** — центр внутри чужой формы; **мимо** — центр ниже низа ряда ворот; проезд вдоль ряда и касание чужих краем безопасны. Линии судейства и запаса `gateCatchSlack` больше нет. Чужие и «мимо» — конец забега как «Не те ворота».
- `GameListener` — интерфейс для кубита (`onDelivered(doubled:) / onWarning / onRouteStarted / onCrash / onBonusPicked`); `demo: true` — меню: две фигуры по случайным маршрутам к своим воротам, столкновений и ввода нет, рисуется на 50 % через `Opacity`.
- Тесты: `features/test/game/line_duty_game_test.dart` (разметка, следование маршруту, ворота, столкновение/продолжение, спавн, демо), `game_cubit_test.dart`.

## Геймплей и экраны
- Кубит (`GameCubit`): счёт, «живой» рекорд (сохраняется сразу, как счёт его превысил), статус playing/paused/gameOver, `continues` (`GameRules.continuesPerRun` = 1, пока без рекламы — бесплатно; `AppConfig.monetizationEnabled` только меняет подпись кнопки), статистика пишется при проигрыше/рестарте/закрытии, после продолжения забег второй раз не считается.
- **Онбординг «Как играть»**: `SettingsModel.tutorialSeen` (Hive `settingsBox`, `SettingsService.setTutorialSeen`); `GameCubit` стартует с `tutorialOpen = !tutorialSeen`, форма показывает `TutorialOverlay` (5 шагов: фигуры и ворота → маршрут → опасности → счёт → бонусы; «Дальше / Пропустить / Играть!») поверх поля и держит движок на паузе, `finishTutorial()` закрывает и пишет флаг. Повторно — настройки → «Как играть» (`SettingsCubit.showHelp/closeHelp`, без записи флага). Тексты — группа `tutorial` в переводах; описывать только действующие правила.
- **Сохранение забега** (2026-09-25): при уходе приложения в фон и при выходе в меню форма зовёт `GameCubit.saveSnapshot(_game.capture(...))` → `RunRepository` (`runBox`); забег с нулевым счётом не сохраняется, проигрыш и «Заново» стирают снимок (`runRepository.clear()`). Меню (`MenuCubit`) читает снимок: «Играть» становится «ПРОДОЛЖИТЬ · счёт» (`goNamed('game', extra: snapshot)`), под ней `AppTextButton` «Новый забег» (`MenuForm.newRunKey`, стирает снимок). `GameScreen(resumeFrom:)` → кубит стартует со счётом/продолжениями/учётом из снимка (без онбординга), форма кладёт снимок в `LineDutyGame.pendingSnapshot`, движок восстанавливает поле в `onLoad` (`restore`: фигуры, маршруты, стыковка, щит, пикап, таймеры эффектов и спавна).
- Форма ставит `game.paused` по статусу и по `tutorialOpen` (начальное состояние применяется в `addPostFrameCallback` — BlocListener его не видит, а пауза до attach оставит поле без первого кадра), уход приложения в фон — пауза. HUD: счёт `0000`, «РЕКОРД N», пауза. Оверлеи: пауза (панель: продолжить / заново / в меню, звук, вибрация), проигрыш (без панели: заголовок, СЧЁТ, бейдж рекорда, заново / в меню, пунктирная «Продолжить»).
- Меню: `LINE DUTY` + подзаголовок, «Играть» со свечением, «★ РЕКОРД N», лента тем (`MenuThemeStrip`, превью рисует скин; `MenuDemoField.bottomReserve` учитывает её высоту), звук и настройки; переход в игру и обратно — `goNamed` (свежее меню перечитывает рекорд).
- Настройки: звуки, вибрация, язык (системный / English / Русский), «Как играть», статистика (рекорд, забеги, доведено; сброс с подтверждением), версия, лицензии.

## Звук, хаптика, кнопки
- `SettingsService` (`ValueNotifier<SettingsModel>`: `soundOn`, `hapticsOn`, `localeCode`), `AudioService` (SFX через `FlameAudio.play`: `tap`, `drawStart`, `deliver`, `warn`, `crash(isRecord:)`; музыки нет). Ассеты в `core/resources/audio/` синтезированы `script/gen_placeholder_audio.py` — свои, без лицензий; при замене сохранять имена.
- Кнопки построены на `AppPressable` и дёргают `ButtonFeedback.trigger()`; хук назначается в `lib/main_common.dart` на `AudioService.tap`. В core_ui нет прямых вызовов `HapticFeedback`.

## Локализация
- `easy_localization`. Языки: en (основной и fallback), ru. Переводы — `core/resources/translations/<lang>-<REGION>.json`, одинаковые ключи в обоих файлах. `LocaleKeys` генерируется (`script/prebuild_script.sh` или в `core/`: `dart run easy_localization:generate -f keys -o locale_keys.g.dart -O lib/localization -S resources/translations`), в git не попадает (`*.g.dart` в `.gitignore`, как в WasDrop) — после свежего клона запустить `script/prebuild_script.sh`. В виджетах — `context.tr(LocaleKeys.x)`, плейсхолдеры через `namedArgs:`. **Литералов в виджетах нет.** Капс — в переводе. Выбранный язык — `SettingsModel.localeCode` (null = системный), пикер зовёт `SettingsService.setLocale` и `context.setLocale` / `resetLocale`. iOS: `CFBundleLocalizations` (en, ru).

## Монетизация
Первый релиз без рекламы и покупок. Кнопка «Продолжить · реклама» из спеки показывается как «Продолжить» (раз за забег). Когда появится SDK: `AppConfig.monetizationEnabled` (`--dart-define=monetization=on`), сервис рекламы по образцу `AdsService` в WasDrop.
