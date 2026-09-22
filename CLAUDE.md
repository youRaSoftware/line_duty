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
│   ├── SPEC.md                 # Спека концепта: механика, палитра, размеры, шрифт, экраны
│   └── refs/                   # PNG-мокапы: 1a поле, 2a проигрыш, 2b меню, 2c иконка
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
- **core_ui/** — `AppColors`, `AppFonts`, `AppDimens`, `darkTheme`, виджеты (`AppScaffold`, `GridBackground`, `PrimaryButton`, `SecondaryButton`, `DashedButton`, `AppTextButton`, `IconSquareButton`, `AppToggleRow`, `AppOverlay`, `RecordBadge`, `LaneGlyphIcon`/`LaneGlyphPainter`)
- **domain/** — `LaneColor` (red/amber/green/blue + `LaneGlyph`), `GameRules` (очки за доставку, продолжения), `GameStatsModel` (рекорд, забеги, доведено), `SettingsModel` (звук, вибрация, язык), интерфейсы `StatsRepository` / `SettingsRepository`
- **data/** — Hive-провайдеры (`providers/local/`), реализации репозиториев, `DataDI.init()`
- **features/** — `menu/` (MenuCubit, MenuForm, `MenuDemoField` — движок в демо-режиме под UI), `game/` (cubit, screen, widgets — HUD, оверлеи паузы и проигрыша; `engine/` — Flame: `line_duty_game.dart`, `unit_component.dart`, `field_components.dart` (ворота, спавны), `field_layers.dart` (маршруты/следы, палец/кольца/вспышка), `game_tuning.dart`), `settings/` (cubit, screen, widgets)
- **navigation/** — `AppRouter` (go_router, стартовый `/menu`, `/game`, `/settings`, fade-переход)

Паттерны и стиль — `.claude/shared/line_duty_ui_reference.md`.

## Дизайн (тема A «Диспетчер метро»)
- Палитра — `AppColors` (спека): фон `0D131E`, сетка `1B2635`, панели `131C2B`, обводки `243349` / `33455F`, текст `E8EDF4` / `7E93B0`, опасность `FF4757`, рекорд `F2B233`, потоки red `E8503A` / amber `F2B233` / green `2EB872` / blue `3E8BE8`. Второй канал различения — значки круг / квадрат / треугольник / ромб (`LaneGlyph`).
- Шрифты — **Golos Text** (интерфейс, `AppFonts.family` и `ThemeData.fontFamily`) + **Unbounded** (`AppFonts.displayFamily`: название в меню, большой счёт проигрыша). Оба переменные, 500/700, кириллица + латиница, OFL в `core/resources/fonts/`, лицензии в `LicenseRegistry` (`lib/main_common.dart`). Space Grotesk из спеки заменён — без кириллицы. Размеры спеки (холст 1080 px) делены на 3.
- Иконки — Material rounded (`textSecondary`), без SVG и эмодзи.
- Нативный экран запуска: фон `0D131E` и иконка со скруглением по центру (iOS storyboard + `LaunchImage.imageset`, Android `launch_background` + системный splash 12+). Картинки — `script/gen_launch_images.sh` из `store/appstore_icon_1024.png`.
- Иконки приложения: исходник — `store/icon_rounded_1024.png` (апскейл референса 2c 512 px, **заменить на настоящий 1024**), `appstore_icon_1024.png` (сплющен на фон, без альфы), `android_adaptive_foreground_1024.png`, `playstore_icon_512.png`; наборы iOS `AppIcon` / `AppIcon-Dev`, Android mipmap + adaptive (фон — сплошной `0D131E`), dev-вариант с плашкой в `android/app/src/dev/res`.

## Движок (`features/lib/game/engine/`)
- `LineDutyGame extends FlameGame with DragCallbacks`. Координаты поля — логические единицы: ширина `AppDimens.fieldWidth` = 360 (1 ед. = 3 px холста спеки), высота от пропорции виджета; камера в левом верхнем углу с зумом `ширина виджета / 360`, входные точки делятся на зум. Фон движка прозрачный — сетку рисует `AppScaffold`.
- **Все числа геймплея — в `game_tuning.dart`** (`GameTuning`): скорость 38 → 74 ед/с и интервал спавна 3.2 → 1.25 с растут с числом доведённых фигур (потолок на 45), не больше 8 фигур, захват пальцем 26 ед., столкновение при расстоянии центров < 0.92 стороны, кольцо «!» < 54, вспышка 0.7 с, «Продолжить» чистит радиус 90.
- Отступы: форма отдаёт `setInsets(top: safeArea + HUD 64, bottom: safeArea + 8)` в логических px; в единицы поля переводятся в `_layout()` при первом размере (до него `size` у игры нет — ловушка Flame). Спавны (3, доли 0.2/0.5/0.8) на `spawnRowOffset` ниже верхнего отступа, ворота (4, в порядке `LaneColor.values`) на `gateRowOffset` выше нижнего.
- Фигура (`UnitComponent`): едет по `heading` (по умолчанию вниз); маршрут — список точек, съедается по мере движения, съеденные точки идут в `trace` (пунктир 30 %, гаснет за `traceSeconds`); за концом маршрута едет в направлении последнего отрезка; боковой/верхний край разворачивает вниз и стирает маршрут. Новый жест по фигуре стирает старый маршрут (`beginRoute`) и ведёт её живьём, пока палец идёт. Логика жеста — `routeStart / routeMove / routeEnd` (drag-колбэки только переводят координаты — из `canvasStartPosition`, потому что `canvasEndPosition` у Flame = позиция + дельта, на шаг впереди пальца; тесты зовут методы напрямую). **Стыковка:** палец над своими воротами (или выше кромки на `gateDockMargin`) зовёт `UnitComponent.dockTo` — маршрут заканчивается входом в ворота (X пальца, зажатый внутрь ворот на радиус фигуры; Y — верхняя кромка), `docked` = ворота, жест закрывается сам; ворота с живым пристыкованным маршрутом подсвечены (`GateComponent.armed`, ставит `_armGates()` каждый кадр). Чужие ворота не стыкуют. Демо стыкует через тот же `dockTo`.
- Линия ворот (верх ворот): фигура попадает в **ближайшие по X ворота, которые задевает краем** (центр не дальше полуширины ворот + `gateCatchSlack` = радиус фигуры; зазор между воротами уже фигуры, так что «мимо» не бывает). Свои — доставка (+`GameRules.scorePerDelivery`, вспышка ворот), чужие — конец забега как «Не те ворота». Столкновение двух фигур — конец забега «Столкновение». В обоих случаях поле замирает (`frozen`), играет вспышка, через `crashFreeze` движок зовёт `GameListener.onCrash`. `clearCrash()` (продолжение) убирает разбитые и всё в радиусе; `reset()` — новый забег.
- `GameListener` — интерфейс для кубита (`onDelivered / onWarning / onRouteStarted / onCrash`); `demo: true` — меню: две фигуры по случайным маршрутам к своим воротам, столкновений и ввода нет, рисуется на 50 % через `Opacity`.
- Тесты: `features/test/game/line_duty_game_test.dart` (разметка, следование маршруту, ворота, столкновение/продолжение, спавн, демо), `game_cubit_test.dart`.

## Геймплей и экраны
- Кубит (`GameCubit`): счёт, «живой» рекорд (сохраняется сразу, как счёт его превысил), статус playing/paused/gameOver, `continues` (`GameRules.continuesPerRun` = 1, пока без рекламы — бесплатно; `AppConfig.monetizationEnabled` только меняет подпись кнопки), статистика пишется при проигрыше/рестарте/закрытии, после продолжения забег второй раз не считается.
- Форма ставит `game.paused` по статусу, уход приложения в фон — пауза. HUD: счёт `0000`, «РЕКОРД N», пауза. Оверлеи: пауза (панель: продолжить / заново / в меню, звук, вибрация), проигрыш (без панели: заголовок, СЧЁТ, бейдж рекорда, заново / в меню, пунктирная «Продолжить»).
- Меню: `LINE DUTY` + подзаголовок, «Играть» со свечением, «★ РЕКОРД N», звук и настройки; переход в игру и обратно — `goNamed` (свежее меню перечитывает рекорд).
- Настройки: звуки, вибрация, язык (системный / English / Русский), статистика (рекорд, забеги, доведено; сброс с подтверждением), версия, лицензии.

## Звук, хаптика, кнопки
- `SettingsService` (`ValueNotifier<SettingsModel>`: `soundOn`, `hapticsOn`, `localeCode`), `AudioService` (SFX через `FlameAudio.play`: `tap`, `drawStart`, `deliver`, `warn`, `crash(isRecord:)`; музыки нет). Ассеты в `core/resources/audio/` синтезированы `script/gen_placeholder_audio.py` — свои, без лицензий; при замене сохранять имена.
- Кнопки построены на `AppPressable` и дёргают `ButtonFeedback.trigger()`; хук назначается в `lib/main_common.dart` на `AudioService.tap`. В core_ui нет прямых вызовов `HapticFeedback`.

## Локализация
- `easy_localization`. Языки: en (основной и fallback), ru. Переводы — `core/resources/translations/<lang>-<REGION>.json`, одинаковые ключи в обоих файлах. `LocaleKeys` генерируется (`script/prebuild_script.sh` или в `core/`: `dart run easy_localization:generate -f keys -o locale_keys.g.dart -O lib/localization -S resources/translations`), в git не попадает (`*.g.dart` в `.gitignore`, как в WasDrop) — после свежего клона запустить `script/prebuild_script.sh`. В виджетах — `context.tr(LocaleKeys.x)`, плейсхолдеры через `namedArgs:`. **Литералов в виджетах нет.** Капс — в переводе. Выбранный язык — `SettingsModel.localeCode` (null = системный), пикер зовёт `SettingsService.setLocale` и `context.setLocale` / `resetLocale`. iOS: `CFBundleLocalizations` (en, ru).

## Монетизация
Первый релиз без рекламы и покупок. Кнопка «Продолжить · реклама» из спеки показывается как «Продолжить» (раз за забег). Когда появится SDK: `AppConfig.monetizationEnabled` (`--dart-define=monetization=on`), сервис рекламы по образцу `AdsService` в WasDrop.
