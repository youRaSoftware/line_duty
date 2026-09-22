# Changelog

Все значимые user-facing изменения в Line Duty. / All notable user-facing changes to Line Duty.

Формат / Format: [Keep a Changelog](https://keepachangelog.com/1.1.0/) · Versioning: [SemVer](https://semver.org/).

При выпуске новой версии в стор переименовать `[Unreleased]` в `[X.Y.Z] — YYYY-MM-DD` (версия = `version:` в `pubspec.yaml`) и завести новый пустой `[Unreleased]` сверху. Тексты для сторов складывать в `.claude/my_docs/release_notes_X.Y.Z.txt`.
On release, rename `[Unreleased]` to `[X.Y.Z] — YYYY-MM-DD` and start a fresh empty `[Unreleased]` on top.

## [Unreleased]

### RU

**Что нового:**

- Новое: игра «Диспетчер» — фигуры четырёх цветов выезжают сверху, рисуй им пальцем маршруты до ворот своего цвета; маршрут стирается за фигурой, красное кольцо предупреждает о сближении, касание двух фигур или чужие ворота — конец забега
- Новое: меню с живым демо-полем, счёт и рекорд в игре, пауза (звук, вибрация), экран проигрыша с бейджем «Новый рекорд» и одним бесплатным продолжением
- Новое: настройки — звуки, вибрация, язык (English / Русский), статистика (рекорд, забеги, доведённые фигуры) со сбросом, версия и лицензии
- Новое: тёмная тема «Диспетчер метро», шрифты Unbounded и Golos Text (с кириллицей), иконка приложения и экран запуска
- Исправлено: фигура, задевшая свои ворота краем, больше не разбивается «не о те ворота» из-за зазора между воротами
- Новое: обучение «Как играть» при первом запуске — четыре шага с картинками про фигуры и ворота, маршруты, опасности и счёт; открывается снова из настроек
- Новое: маршрут стыкуется с воротами — доведи линию до своих ворот, и она закончится входом в них, ворота подсветятся, а палец можно отпустить

### EN

**What's new:**

- New: the dispatcher game — units of four colours roll in from the top, draw their routes with a finger to the gate of their colour; the route erases behind the unit, a red ring warns of a near miss, two units touching or a wrong gate ends the run
- New: menu with a live demo field, score and best in game, pause (sound, vibration), game-over screen with a "New record" badge and one free continue
- New: settings — sounds, vibration, language (English / Русский), statistics (best, runs, delivered) with reset, version and licenses
- New: dark "Metro dispatcher" theme, Unbounded and Golos Text fonts (Cyrillic included), app icon and launch screen
- Fixed: a unit that touches its own gate with its edge no longer crashes as "wrong gate" because of the gap between gates
- New: a "How to play" tutorial on first launch — four illustrated steps about units and gates, routes, dangers and scoring; reopen it any time from settings
- New: routes dock to gates — draw the line into a gate of the unit's colour and it ends right at the gate entrance, the gate lights up and you can lift your finger
