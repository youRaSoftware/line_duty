# Line Duty (проект line_duty)

Аркада на разведении потоков: фигуры едут сверху вниз, рисуешь им маршруты пальцем, доводишь до ворот своего цвета, не сталкиваешь. Мультипакетный проект (core / core_ui / domain / data / features / navigation), Cubit + get_it + go_router + Hive, движок — Flame. Сети нет.

## Первый запуск
1. `script/prebuild_script.sh` — `flutter pub get` во всех пакетах и генерация `LocaleKeys`
2. `script/run.sh dev` — запуск dev-флейвора (или конфигурация **Dev** в Android Studio)

## Flavors
`dev` (`com.lineduty.dev`, «Line Dev», плашка DEV) и `prod` (`com.lineduty`, «Line Duty»). Передаются и нативно, и через dart-define:

```bash
flutter run --flavor dev --dart-define=environment=dev
flutter run --flavor prod --dart-define=environment=prod
```

## Скрипты
| Скрипт | Что делает |
|---|---|
| `script/run.sh <dev\|prod> [args]` | `flutter run` с нужным флейвором |
| `script/build.sh <dev\|prod> <apk\|aab\|ipa> [--upload]` | релизная сборка; `ipa --upload` отправляет в App Store Connect |
| `script/build_app_builds.sh` | то же, интерактивно |
| `script/prebuild_script.sh [--clean]` | pub get во всех пакетах + `LocaleKeys` |
| `script/run_test_script.sh` | unit-тесты по пакетам, общий `coverage/lcov.info` |
| `script/gen_placeholder_audio.py` | перегенерировать звуки в `core/resources/audio/` |
| `script/gen_dev_icons.sh` | dev-иконки с плашкой DEV из `store/` (iOS + Android) |
| `script/gen_launch_images.sh` | картинки нативного экрана запуска из `store/` |
| `flutter test integration_test -d <deviceId> --flavor dev --dart-define=environment=dev` | смоук-тест на симуляторе/устройстве |

Подпись Android — `android/key.properties` (шаблон `android/key.properties.example`).

## Документация
Всё — в `.claude/`: спека `my_docs/SPEC.md` (+ мокапы в `my_docs/refs/`), план `plans/plan.md`, changelog `changelog/CHANGELOG.md`, UI-референс `shared/line_duty_ui_reference.md`, скиллы Claude Code — `SKILLS_GUIDE.md`. Заметки для Claude Code — `CLAUDE.md`.
