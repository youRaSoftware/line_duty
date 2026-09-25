# Changelog

Все значимые user-facing изменения в Line Duty. / All notable user-facing changes to Line Duty.

Формат / Format: [Keep a Changelog](https://keepachangelog.com/1.1.0/) · Versioning: [SemVer](https://semver.org/).

При выпуске новой версии в стор переименовать `[Unreleased]` в `[X.Y.Z] — YYYY-MM-DD` (версия = `version:` в `pubspec.yaml`) и завести новый пустой `[Unreleased]` сверху. Тексты для сторов складывать в `.claude/my_docs/release_notes_X.Y.Z.txt`.
On release, rename `[Unreleased]` to `[X.Y.Z] — YYYY-MM-DD` and start a fresh empty `[Unreleased]` on top.

## [Unreleased]

### RU

**Что нового:**

- Изменено: на iPad фигуры и ворота стали телефонного размера, поле по-прежнему во всю ширину — ворота и спавны стоят шире, места для маршрутов больше
- Новое: пять языков интерфейса — Deutsch, Español, Français, Português (Brasil), 日本語; выбор в настройках, по умолчанию язык устройства
- Новое: игра «Диспетчер» — фигуры четырёх цветов выезжают сверху, рисуй им пальцем маршруты до ворот своего цвета; маршрут стирается за фигурой, красное кольцо предупреждает о сближении, касание двух фигур или чужие ворота — конец забега
- Новое: меню с живым демо-полем, счёт и рекорд в игре, пауза (звук, вибрация), экран проигрыша с бейджем «Новый рекорд» и одним бесплатным продолжением
- Новое: настройки — звуки, вибрация, язык (English / Русский), статистика (рекорд, забеги, доведённые фигуры) со сбросом, версия и лицензии
- Новое: тёмная тема «Диспетчер метро», шрифты Unbounded и Golos Text (с кириллицей), иконка приложения и экран запуска
- Исправлено: фигура, задевшая свои ворота краем, больше не разбивается «не о те ворота» из-за зазора между воротами или потому что соседние ворота оказались чуть ближе
- Новое: в настройках появилась ссылка на политику конфиденциальности
- Новое: забег сохраняется — сверни или закрой приложение, выйди в меню, и в следующий раз кнопка «Продолжить» вернёт поле, счёт, бонусы и фигуры на свои места; «Новый забег» начинает с чистого листа
- Изменено: базы ловят по своей форме — арка, холмик, кольцо или прямоугольник, как нарисовано: свои ворота принимают фигуру, едва она их задела, чужие разбивают только при заезде внутрь, проезд вдоль ряда безопасен, а фигура, ушедшая ниже ряда мимо всех баз, разбивается
- Изменено: когда нарисованный маршрут кончается, фигура едет строго вниз, а над своими воротами сама доворачивает ко входу
- Исправлено: фигура, едущая по маршруту вдоль ворот к своим, больше не разбивается «не о те ворота» напротив чужих — ворота судятся по центру фигуры и только когда она доехала до входа
- Исправлено: столкновения считаются по форме фигуры темы — вытянутые автобусы, муравьи и рыбки сталкиваются бортами и носами как нарисованы, а не по невидимому кругу
- Исправлено: в «Аквариуме» третий цвет рыбок стал маджента вместо лавандового, который путался с синим
- Новое: темы оформления — к тёмному «Метро» добавились «Город» с автобусами и парковками, «Аквариум» с рыбками и гротами, «Муравейник» с муравьями и холмиками и «Сад» с божьими коровками и листьями; выбор темы в меню, тема запоминается
- Новое: бонусы — на поле появляются шестиугольники, проведи через них фигуру: заморозка на 3 с, щит от одного столкновения, очки ×2 на 10 с, автопилот до своих ворот; индикаторы эффектов у счёта и бейдж подбора
- Новое: обучение «Как играть» при первом запуске — четыре шага с картинками про фигуры и ворота, маршруты, опасности и счёт; открывается снова из настроек
- Новое: маршрут стыкуется с воротами — доведи линию до своих ворот, и она закончится входом в них, ворота подсветятся, а палец можно отпустить

### EN

**What's new:**

- Changed: on iPad units and gates are now phone-sized while the field still spans the whole screen — gates and spawners sit wider apart, with more room for routes
- New: five more interface languages — Deutsch, Español, Français, Português (Brasil), 日本語; pick one in Settings, the device language is used by default
- New: the dispatcher game — units of four colours roll in from the top, draw their routes with a finger to the gate of their colour; the route erases behind the unit, a red ring warns of a near miss, two units touching or a wrong gate ends the run
- New: menu with a live demo field, score and best in game, pause (sound, vibration), game-over screen with a "New record" badge and one free continue
- New: settings — sounds, vibration, language (English / Русский), statistics (best, runs, delivered) with reset, version and licenses
- New: dark "Metro dispatcher" theme, Unbounded and Golos Text fonts (Cyrillic included), app icon and launch screen
- Fixed: a unit that touches its own gate with its edge no longer crashes as "wrong gate" because of the gap between gates or because the neighbouring gate happened to be slightly closer
- New: a privacy policy link in Settings
- New: runs are saved — background or close the app or go back to the menu, and next time "Resume" brings back the field, score, bonuses and units where they were; "New run" starts fresh
- Changed: bases catch by their drawn shape — arch, mound, ring or rectangle: your own gate takes a unit as soon as it touches, a foreign gate only kills when the unit drives inside, riding along the row is safe, and a unit that drops below the row past every base crashes
- Changed: when a drawn route ends the unit heads straight down, and above its own gate it steers itself into the entrance
- Fixed: a unit riding its route along the gate row towards its own gate no longer crashes as "wrong gate" in front of a foreign one — gates are judged by the unit's centre and only once it has arrived at the entrance
- Fixed: collisions follow the shape of the theme's unit — elongated buses, ants and fish collide the way they are drawn instead of by an invisible circle
- Fixed: the third fish colour in "Aquarium" is now magenta instead of a lavender that looked too close to blue
- New: visual themes — "City" with buses and parking bays, "Aquarium" with fish and grottos, "Anthill" with ants and mounds and "Garden" with ladybugs and leaves join the dark "Metro"; pick a theme in the menu, the choice is remembered
- New: bonuses — hexagons appear on the field, drive a unit through one: freeze for 3 s, a shield against one collision, points ×2 for 10 s, autopilot to its own gate; effect indicators next to the score and a pickup badge
- New: a "How to play" tutorial on first launch — four illustrated steps about units and gates, routes, dangers and scoring; reopen it any time from settings
- New: routes dock to gates — draw the line into a gate of the unit's colour and it ends right at the gate entrance, the gate lights up and you can lift your finger
