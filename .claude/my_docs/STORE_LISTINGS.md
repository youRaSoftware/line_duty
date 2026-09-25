# Line Duty — листинги App Store и Google Play, версия 1.0.0

Дата: 2026-09-25. Готовые тексты для App Store Connect и Google Play Console на семи языках интерфейса (en-US, ru, de-DE, es-ES, fr-FR, pt-BR, ja). Всё, что здесь обещано, есть в сборке 1.0.0. Лимиты — § 2. Скриншоты — § 6, чеклист форм — § 7. Тексты «Что нового» — `release_notes_1.0.0.txt`.

**Название во всех локалях: `Line Duty: Route Arcade`** (23 символа, лимит 30). Под иконкой — Line Duty. Альтернативы, если захочется: «Line Duty: Draw & Dispatch» (26), «Line Duty: Traffic Lines» (24). Слова из названия и подзаголовка в keywords не повторяются — они и так индексируются.

---

## 1. Факты для форм

| Поле | Значение |
|---|---|
| Название в сторах | **Line Duty: Route Arcade** |
| Bundle ID / Application ID | `com.lineduty` |
| Версия / build | 1.0.0 (1) — `version:` в `pubspec.yaml` |
| Платформы | iOS 15.0+ (iPhone и iPad, `TARGETED_DEVICE_FAMILY = 1,2`), Android (minSdk по Flutter = 24) |
| Ориентация | только портрет |
| Цена | бесплатно |
| Встроенные покупки | нет |
| Реклама | нет (кнопка «Продолжить» после проигрыша бесплатна, раз за забег) |
| Сеть | не используется; единственная внешняя ссылка — политика конфиденциальности из настроек (открывается в браузере) |
| Аккаунты, вход | нет |
| Сбор данных | нет. App Privacy: **Data Not Collected**. Play Data safety: данные не собираются и не передаются |
| Политика конфиденциальности | https://www.pyf.app/en/apps/line-duty/privacy (в приложении: Настройки → О приложении) |
| Возрастной рейтинг | App Store 4+; Play (IARC) Everyone / PEGI 3 — нет насилия, страха, покупок, рекламы, пользовательского контента, общения |
| Категории | App Store: Games → **Casual** (вторая подкатегория: Puzzle) — подкатегории «Arcade» в ASC нет с 2019 года. Play: Arcade (теги: Casual, Puzzle, Single player, Offline) |
| Export compliance | шифрования нет, `ITSAppUsesNonExemptEncryption = false` в Info.plist |
| Языки интерфейса | English, Deutsch, Español, Français, Português (Brasil), Русский, 日本語 |
| Контакт / поддержка | fyodorov.software@gmail.com, https://pyf.app |
| Marketing URL | https://www.pyf.app/en/apps/line-duty |
| Copyright | 2026 PYF App |
| Иконки | `store/appstore_icon_1024.png` (App Store, без альфы), `store/playstore_icon_512.png` (Play) |
| Feature graphic для Play 1024×500 | `store/play_feature_graphic_1024x500.png` |

## 2. Лимиты полей

| Поле | App Store | Google Play |
|---|---|---|
| Name / Title | 30 | 30 |
| Subtitle / Short description | 30 | 80 |
| Promotional Text | 170 | — |
| Keywords | 100 (через запятую без пробелов) | — (индексируется описание) |
| Description | 4000 | 4000 |
| What's New / Release notes | 4000 | 500 |

Play: короткое описание — поле «Short description», полное — «Full description» (то же, что Description ниже, без строки EULA). Promotional Text в App Store можно менять без новой сборки.

---

## 3. Тексты по локалям

### en-US

**Subtitle** (≤30): Draw routes, keep them apart (28)

**Promotional Text** (≤170):
One finger, four colours, five themes. Draw routes, dock units into their gates and never let them touch. No ads, no account, works offline.

**Keywords** (≤100):
traffic,control,dispatch,path,puzzle,casual,offline,relaxing,bus,fish,ants,sort,colour,one finger

**Play short description** (≤80):
Draw routes with one finger, dock units into their gates, never let them touch.

**Description** (≤4000):
Line Duty is a one-finger arcade about dispatching traffic. Units of four colours roll in from the top and drive down on their own. Draw a route for each one and lead it into the gate of its colour at the bottom. The line erases behind the unit as it goes, so the field stays readable no matter how many routes are running. Two units touching, a wrong gate or a unit drifting past the bases ends the run. Every delivery makes the traffic a little faster and a little denser.

HOW IT PLAYS

• DRAW AND DOCK. Drag a unit, draw its path, bring the line to its gate — the route docks and you can let go. A new line on a unit replaces the old one.

• COLOUR AND GLYPH. Circle, square, triangle and diamond on every unit and gate, so colour-blind players are never guessing.

• WARNINGS THAT MEAN SOMETHING. A red ring with "!" appears when two units get too close. One free continue per run.

• FASTER WITH EVERY DELIVERY. +10 points per unit. The more you deliver, the faster they go and the more often they appear.

FIVE THEMES

Metro (dark), City with turning buses and parking bays, Aquarium with fish, grottos and rising bubbles, Anthill with ants and mounds, Garden with ladybugs and leaves. Switch from the menu — the whole app recolours, and every theme has its own gates and animation.

BONUSES

Hexagons appear on the field — drive a unit through one. Freeze stops everyone for three seconds, Shield forgives one collision, ×2 doubles your points for ten seconds, Autopilot drives the unit to its gate.

NO STRINGS ATTACHED

No ads, no purchases, no account, no internet needed, nothing collected. Your run is saved when you leave and resumed from the menu. A five-step "How to play" on first launch, statistics with a reset, seven languages, iPhone and iPad.

A game for a queue or a coffee break — close it mid-run and pick it up later.

Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Privacy Policy: https://www.pyf.app/en/apps/line-duty/privacy

---

### ru

**Subtitle**: Диспетчер на кончике пальца (27) — варианты: «Веди фигуры к своим воротам» (27), «Разведи потоки одним пальцем» (28)

**Promotional Text**:
Один палец, четыре цвета, пять тем. Рисуй маршруты, стыкуй фигуры с воротами и не давай им коснуться. Без рекламы и аккаунта, работает офлайн.

**Keywords**:
диспетчер,трафик,пути,головоломка,казуальная,офлайн,релакс,автобусы,рыбки,муравьи,цвета,линии

**Play short description**:
Рисуй маршруты одним пальцем, стыкуй фигуры с воротами, не давай им столкнуться.

**Description**:
Line Duty — аркада-диспетчер одним пальцем. Фигуры четырёх цветов выезжают сверху и едут сами. Нарисуй каждой маршрут и доведи её до ворот своего цвета внизу. Линия стирается за фигурой, поэтому поле остаётся читаемым, сколько бы маршрутов ни ехало одновременно. Касание двух фигур, чужие ворота или проезд мимо баз — конец забега. Каждая доставка делает поток чуть быстрее и плотнее.

КАК ИГРАЕТСЯ

• РИСУЙ И СТЫКУЙ. Потяни фигуру, нарисуй путь, доведи линию до её ворот — маршрут пристыкуется, и палец можно отпустить. Новая линия по фигуре заменяет старую.

• ЦВЕТ И ЗНАЧОК. Круг, квадрат, треугольник и ромб на каждой фигуре и воротах — тем, кто плохо различает цвета, не придётся гадать.

• ПРЕДУПРЕЖДЕНИЯ ПО ДЕЛУ. Красное кольцо с «!» появляется, когда две фигуры слишком близко. Одно бесплатное продолжение за забег.

• БЫСТРЕЕ С КАЖДОЙ ДОСТАВКОЙ. +10 очков за фигуру. Чем больше довёл, тем быстрее они едут и чаще появляются.

ПЯТЬ ТЕМ

Метро (тёмная), Город с поворачивающими автобусами и парковками, Аквариум с рыбками, гротами и пузырьками, Муравейник с муравьями и холмиками, Сад с божьими коровками и листьями. Переключаются из меню — перекрашивается всё приложение, у каждой темы свои ворота и анимация.

БОНУСЫ

На поле появляются шестиугольники — проведи через них фигуру. Заморозка останавливает всех на три секунды, Щит прощает одно столкновение, ×2 удваивает очки на десять секунд, Автопилот сам ведёт фигуру к воротам.

БЕЗ ЛИШНЕГО

Без рекламы, покупок, аккаунта и интернета, ничего не собирается. Забег сохраняется при выходе и продолжается из меню. Обучение «Как играть» из пяти шагов при первом запуске, статистика со сбросом, семь языков, iPhone и iPad.

Игра на очередь или кофе — закрой посреди забега и открой позже.

Условия использования (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Политика конфиденциальности: https://www.pyf.app/ru/apps/line-duty/privacy

---

### de-DE

**Subtitle**: Routen ziehen, Abstand halten (28)

**Promotional Text**:
Ein Finger, vier Farben, fünf Themen. Zeichne Routen, bring Figuren in ihre Tore und lass sie nie zusammenstoßen. Keine Werbung, kein Konto, offline spielbar.

**Keywords**:
verkehr,lenken,dispatcher,weg,puzzle,casual,offline,entspannend,bus,fische,ameisen,sortieren,farben

**Play short description**:
Routen mit einem Finger zeichnen, Figuren ins Tor bringen, nie zusammenstoßen.

**Description**:
Line Duty ist ein Ein-Finger-Arcadespiel über das Lenken von Verkehr. Figuren in vier Farben kommen oben herein und fahren von selbst nach unten. Zeichne jeder eine Route und führe sie in das Tor ihrer Farbe am unteren Rand. Die Linie löscht sich hinter der Figur, sodass das Feld übersichtlich bleibt, egal wie viele Routen gerade laufen. Berühren sich zwei Figuren, landet eine im falschen Tor oder fährt sie an den Toren vorbei, ist die Runde vorbei. Mit jeder Lieferung wird der Verkehr ein wenig schneller und dichter.

SO SPIELT ES SICH

• ZEICHNEN UND ANDOCKEN. Ziehe eine Figur, zeichne ihren Weg, führe die Linie in ihr Tor – die Route dockt an, und du kannst loslassen. Eine neue Linie auf einer Figur ersetzt die alte.

• FARBE UND SYMBOL. Kreis, Quadrat, Dreieck und Raute auf jeder Figur und jedem Tor – wer Farben schlecht unterscheidet, muss nie raten.

• WARNUNGEN, DIE ETWAS BEDEUTEN. Ein roter Ring mit „!“ erscheint, wenn zwei Figuren zu nah kommen. Einmal pro Runde kannst du kostenlos weitermachen.

• SCHNELLER MIT JEDER LIEFERUNG. +10 Punkte pro Figur. Je mehr du lieferst, desto schneller fahren sie und desto öfter erscheinen sie.

FÜNF THEMEN

Metro (dunkel), Stadt mit abbiegenden Bussen und Parkbuchten, Aquarium mit Fischen, Grotten und aufsteigenden Blasen, Ameisenhaufen mit Ameisen und Hügeln, Garten mit Marienkäfern und Blättern. Umschalten im Menü – die ganze App wird umgefärbt, jedes Thema hat eigene Tore und Animationen.

BONI

Auf dem Feld erscheinen Sechsecke – fahre mit einer Figur hindurch. Einfrieren stoppt alle für drei Sekunden, Schild verzeiht eine Kollision, ×2 verdoppelt die Punkte für zehn Sekunden, Autopilot fährt die Figur zu ihrem Tor.

OHNE HAKEN

Keine Werbung, keine Käufe, kein Konto, kein Internet nötig, nichts wird gesammelt. Deine Runde wird beim Verlassen gespeichert und aus dem Menü fortgesetzt. Eine Spielanleitung in fünf Schritten beim ersten Start, Statistik mit Zurücksetzen, sieben Sprachen, iPhone und iPad.

Ein Spiel für die Warteschlange oder die Kaffeepause – mitten in der Runde schließen und später weitermachen.

Nutzungsbedingungen (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Datenschutzerklärung: https://www.pyf.app/en/apps/line-duty/privacy

---

### es-ES

**Subtitle**: Traza rutas, evita choques (26)

**Promotional Text**:
Un dedo, cuatro colores, cinco temas. Traza rutas, lleva las figuras a sus puertas y no dejes que se toquen. Sin anuncios ni cuenta, funciona sin conexión.

**Keywords**:
tráfico,control,despacho,camino,puzle,casual,sin conexión,relajante,autobús,peces,hormigas,colores

**Play short description**:
Traza rutas con un dedo, lleva las figuras a su puerta, evita que se toquen.

**Description**:
Line Duty es un arcade de un solo dedo sobre dirigir el tráfico. Figuras de cuatro colores entran por arriba y bajan solas. Traza una ruta para cada una y llévala hasta la puerta de su color, abajo. La línea se borra detrás de la figura, así que el campo sigue legible por muchas rutas que haya en marcha. Si dos figuras se tocan, una entra en la puerta equivocada o pasa de largo las bases, la partida termina. Cada entrega hace el tráfico un poco más rápido y más denso.

CÓMO SE JUEGA

• TRAZA Y ACOPLA. Arrastra una figura, dibuja su camino, lleva la línea hasta su puerta: la ruta se acopla y puedes soltar. Una línea nueva sobre una figura sustituye a la anterior.

• COLOR Y SÍMBOLO. Círculo, cuadrado, triángulo y rombo en cada figura y cada puerta, para que nadie tenga que adivinar colores.

• AVISOS QUE IMPORTAN. Un anillo rojo con «!» aparece cuando dos figuras se acercan demasiado. Una continuación gratis por partida.

• MÁS RÁPIDO CON CADA ENTREGA. +10 puntos por figura. Cuantas más entregues, más rápido irán y más a menudo aparecerán.

CINCO TEMAS

Metro (oscuro), Ciudad con autobuses que giran y plazas de aparcamiento, Acuario con peces, grutas y burbujas, Hormiguero con hormigas y montículos, Jardín con mariquitas y hojas. Se cambian desde el menú: toda la app cambia de color y cada tema tiene sus propias puertas y animación.

BONIFICACIONES

En el campo aparecen hexágonos: pasa una figura por encima. Congelar detiene a todos durante tres segundos, Escudo perdona un choque, ×2 duplica los puntos durante diez segundos, Piloto automático lleva la figura a su puerta.

SIN TRUCOS

Sin anuncios, sin compras, sin cuenta, sin internet, sin recopilar nada. La partida se guarda al salir y se retoma desde el menú. Un tutorial de cinco pasos al primer inicio, estadísticas con reinicio, siete idiomas, iPhone y iPad.

Un juego para la cola o la pausa del café: ciérralo a mitad de partida y retómalo después.

Condiciones de uso (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Política de privacidad: https://www.pyf.app/en/apps/line-duty/privacy

---

### fr-FR

**Subtitle**: Trace des routes, sans chocs (26)

**Promotional Text**:
Un doigt, quatre couleurs, cinq thèmes. Trace des routes, amène les pièces à leur porte et ne les laisse jamais se toucher. Sans pub ni compte, hors ligne.

**Keywords**:
trafic,contrôle,aiguillage,chemin,puzzle,casual,hors ligne,relaxant,bus,poissons,fourmis,couleurs

**Play short description**:
Trace des routes d’un doigt, amène les pièces à leur porte, sans les cogner.

**Description**:
Line Duty est un jeu d’arcade à un doigt où tu diriges le trafic. Des pièces de quatre couleurs arrivent par le haut et descendent toutes seules. Trace une route pour chacune et amène-la jusqu’à la porte de sa couleur, en bas. La ligne s’efface derrière la pièce, alors le terrain reste lisible quel que soit le nombre de routes en cours. Deux pièces qui se touchent, une mauvaise porte ou une pièce qui dépasse les bases, et la partie est finie. Chaque livraison rend le trafic un peu plus rapide et plus dense.

COMMENT ON JOUE

• TRACE ET ACCROCHE. Fais glisser une pièce, dessine son chemin, amène la ligne jusqu’à sa porte : la route s’y accroche et tu peux lâcher. Une nouvelle ligne sur une pièce remplace l’ancienne.

• COULEUR ET SYMBOLE. Rond, carré, triangle et losange sur chaque pièce et chaque porte, pour que personne n’ait à deviner les couleurs.

• DES ALERTES UTILES. Un anneau rouge avec « ! » apparaît quand deux pièces sont trop proches. Une reprise gratuite par partie.

• PLUS VITE À CHAQUE LIVRAISON. +10 points par pièce. Plus tu en livres, plus elles vont vite et plus elles arrivent souvent.

CINQ THÈMES

Métro (sombre), Ville avec des bus qui tournent et des places de parking, Aquarium avec poissons, grottes et bulles, Fourmilière avec fourmis et monticules, Jardin avec coccinelles et feuilles. On change depuis le menu : toute l’app change de couleurs, et chaque thème a ses propres portes et animations.

BONUS

Des hexagones apparaissent sur le terrain : fais-y passer une pièce. Gel arrête tout le monde trois secondes, Bouclier pardonne une collision, ×2 double les points pendant dix secondes, Pilote automatique conduit la pièce à sa porte.

SANS PIÈGE

Pas de pub, pas d’achats, pas de compte, pas besoin d’Internet, rien n’est collecté. La partie est sauvegardée quand tu quittes et reprise depuis le menu. Un tutoriel en cinq étapes au premier lancement, des statistiques avec remise à zéro, sept langues, iPhone et iPad.

Un jeu pour la file d’attente ou la pause café : ferme-le en pleine partie et reprends plus tard.

Conditions d’utilisation (EULA) : https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Politique de confidentialité : https://www.pyf.app/en/apps/line-duty/privacy

---

### pt-BR

**Subtitle**: Trace rotas, evite colisões (27)

**Promotional Text**:
Um dedo, quatro cores, cinco temas. Trace rotas, leve as peças aos seus portões e nunca deixe que se toquem. Sem anúncios nem conta, funciona offline.

**Keywords**:
trânsito,controle,despacho,caminho,puzzle,casual,offline,relaxante,ônibus,peixes,formigas,cores

**Play short description**:
Trace rotas com um dedo, leve as peças ao seu portão, sem deixar que se toquem.

**Description**:
Line Duty é um arcade de um dedo só sobre controlar o trânsito. Peças de quatro cores entram por cima e descem sozinhas. Trace uma rota para cada uma e leve-a até o portão da sua cor, embaixo. A linha se apaga atrás da peça, então o campo continua legível por mais rotas que estejam em andamento. Duas peças se tocando, um portão errado ou uma peça passando direto pelas bases encerram a partida. Cada entrega deixa o trânsito um pouco mais rápido e mais denso.

COMO SE JOGA

• TRACE E ENCAIXE. Arraste uma peça, desenhe o caminho, leve a linha até o portão dela: a rota se encaixa e você pode soltar. Uma linha nova sobre a peça substitui a anterior.

• COR E SÍMBOLO. Círculo, quadrado, triângulo e losango em cada peça e cada portão, para ninguém precisar adivinhar cores.

• AVISOS QUE IMPORTAM. Um anel vermelho com “!” aparece quando duas peças ficam perto demais. Uma continuação grátis por partida.

• MAIS RÁPIDO A CADA ENTREGA. +10 pontos por peça. Quanto mais você entrega, mais rápido elas andam e mais vezes aparecem.

CINCO TEMAS

Metrô (escuro), Cidade com ônibus que fazem curvas e vagas de estacionamento, Aquário com peixes, grutas e bolhas, Formigueiro com formigas e montinhos, Jardim com joaninhas e folhas. Troque pelo menu: o app inteiro muda de cor, e cada tema tem seus próprios portões e animações.

BÔNUS

Hexágonos aparecem no campo: passe uma peça por cima. Congelar para todo mundo por três segundos, Escudo perdoa uma colisão, ×2 dobra os pontos por dez segundos, Piloto automático leva a peça até o portão.

SEM PEGADINHAS

Sem anúncios, sem compras, sem conta, sem internet, sem coletar nada. A partida é salva quando você sai e continua pelo menu. Um tutorial de cinco passos no primeiro uso, estatísticas com opção de zerar, sete idiomas, iPhone e iPad.

Um jogo para a fila ou a pausa do café: feche no meio da partida e retome depois.

Termos de uso (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Política de privacidade: https://www.pyf.app/en/apps/line-duty/privacy

---

### ja

**Subtitle**: ルートを描いて、ぶつけない (13)

**Promotional Text**:
指1本、4色、5つのテーマ。ルートを描いてユニットをゲートへ導き、絶対にぶつけないで。広告なし、アカウント不要、オフラインで遊べます。

**Keywords**:
交通,整理,誘導,パズル,カジュアル,オフライン,リラックス,バス,魚,アリ,色分け,一筆,暇つぶし

**Play short description**:
指1本でルートを描き、ユニットを同じ色のゲートへ。ぶつけたら終わり。

**Description**:
Line Dutyは、指1本で交通を整理するアーケードゲームです。4色のユニットが上から現れ、勝手に下へ進みます。それぞれにルートを描いて、下にある同じ色のゲートへ導きましょう。線はユニットが通ると消えるので、ルートが何本あっても画面は見やすいまま。ユニット同士がぶつかる、違うゲートに入る、ゲートを通り過ぎる——どれもゲームオーバーです。1体届けるたびに、流れは少しずつ速く、密になっていきます。

遊び方

• 描いてつなぐ。ユニットをドラッグして道を描き、線を自分のゲートまで引くとルートがつながり、指を離せます。新しい線を引くと前の線は消えます。

• 色とマーク。すべてのユニットとゲートに丸・四角・三角・ひし形のマーク。色の見分けが苦手でも迷いません。

• 意味のある警告。ユニットが近づきすぎると赤い「!」のリングが表示されます。1回のプレイにつき1度だけ無料でコンティニューできます。

• 届けるほど速くなる。1体につき+10点。到着が増えるほどユニットは速く、頻繁に現れます。

5つのテーマ

メトロ（ダーク）、曲がるバスと駐車スペースのシティ、魚と岩と泡の水族館、アリと巣の丘のアリの巣、テントウムシと葉っぱのガーデン。メニューから切り替えるとアプリ全体の色が変わり、テーマごとにゲートやアニメーションも違います。

ボーナス

フィールドに現れる六角形をユニットで通り抜けましょう。フリーズは全員を3秒止め、シールドは衝突を1回無効に、×2は10秒間スコア2倍、オートパイロットはユニットを自動でゲートへ運びます。

余計なものなし

広告なし、課金なし、アカウント不要、通信不要、データ収集なし。途中で閉じてもプレイは保存され、メニューから再開できます。初回起動時に5ステップの遊び方、リセットできる記録、7言語対応、iPhoneとiPadで遊べます。

行列やコーヒー休憩にぴったり。途中で閉じて、あとで続きから。

利用規約（EULA）: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
プライバシーポリシー: https://www.pyf.app/en/apps/line-duty/privacy

---

## 4. What's New 1.0.0

Во всех локалях — одна строка, см. `release_notes_1.0.0.txt`. Для Play — то же в «Release notes» (лимит 500).

## 5. Notes for Review (App Review Information → Notes, на английском)

Line Duty is a one-finger arcade game. Units of four colours enter from the top; the player draws a route for each with a finger and leads it into the gate of its colour at the bottom. Two units touching, a wrong gate or a unit passing the gates ends the run.

The app is fully offline: no account, no sign-in, no ads, no in-app purchases, no analytics and no data collection. The only external link is the privacy policy in Settings → About, which opens in the browser. Nothing is required to test — launch, tap PLAY, follow the five-step "How to play" on first launch (or skip it), then drag a unit and draw a line to the gate with the same glyph.

Test tips: units start slow, so the first minute is easy; the "Continue" button after a mistake is free once per run. Themes are switched from the strip in the main menu. Leaving the app mid-run saves it; the menu then offers "Resume". The language can be changed in Settings → Game → Language (seven languages).

Contact: fyodorov.software@gmail.com.

## 6. Скриншоты

### Что снимать (6 кадров, первые три видны в поиске)

| # | Кадр | Что в кадре | Как получить |
|---|---|---|---|
| 1 | Поле Метро с двумя маршрутами | две фигуры на линиях к своим воротам, одни ворота подсвечены (пристыкованный маршрут), счёт ≥ 30 | тема metro, игра, две линии через `game.routeStart/routeMove/routeEnd` |
| 2 | Город | автобусы, повёрнутые по маршрутам, парковки | тема city |
| 3 | Аквариум | рыбки, гроты, пузырьки, арки-ворота | тема aquarium |
| 4 | Предупреждение | две фигуры сблизились, красное кольцо «!» | подвести две фигуры на расстояние `warnDistance`; либо пропустить и взять Сад |
| 5 | Меню | LINE DUTY, «Играть», лента тем, демо-поле | меню, тема metro |
| 6 | Обучение / бонусы | шаг «Бонусы» с четырьмя пиктограммами | настройки → «Как играть» → 4× «Дальше» |

Подписи на скриншотах не обязательны: интерфейс говорит сам за себя. Если делать — заголовок Unbounded 700, подзаголовок Golos Text 500, для ja — Noto Sans JP; палитра темы кадра. Варианты подписей (2–5 слов):

| # | en-US | ru | de-DE | es-ES | fr-FR | pt-BR | ja |
|---|---|---|---|---|---|---|---|
| 1 | Draw a route. Let go. | Нарисуй маршрут. Отпусти. | Route zeichnen. Loslassen. | Traza la ruta. Suelta. | Trace la route. Lâche. | Trace a rota. Solte. | ルートを描いて、離す。 |
| 2 | Five themes, one finger | Пять тем, один палец | Fünf Themen, ein Finger | Cinco temas, un dedo | Cinq thèmes, un doigt | Cinco temas, um dedo | 5つのテーマ、指1本 |
| 3 | Every theme has its own gates | У каждой темы свои ворота | Jedes Thema hat eigene Tore | Cada tema tiene sus puertas | Chaque thème a ses portes | Cada tema tem seus portões | テーマごとに違うゲート |
| 4 | Too close? You'll know. | Слишком близко? Ты увидишь. | Zu nah? Du siehst es. | ¿Demasiado cerca? Lo verás. | Trop près ? Tu le verras. | Perto demais? Você vai ver. | 近すぎたら、すぐわかる。 |
| 5 | Offline. No ads. Saved runs. | Офлайн. Без рекламы. Забег сохраняется. | Offline. Keine Werbung. Gespeichert. | Sin conexión. Sin anuncios. Partida guardada. | Hors ligne. Sans pub. Partie sauvegardée. | Offline. Sem anúncios. Partida salva. | オフライン・広告なし・自動セーブ |
| 6 | Freeze, Shield, ×2, Autopilot | Заморозка, Щит, ×2, Автопилот | Einfrieren, Schild, ×2, Autopilot | Congelar, Escudo, ×2, Piloto automático | Gel, Bouclier, ×2, Pilote auto | Congelar, Escudo, ×2, Piloto automático | フリーズ・シールド・×2・オートパイロット |

### Размеры

| Стор | Устройство | Пиксели | Симулятор |
|---|---|---|---|
| App Store, iPhone 6.9" (обязательный набор, остальные iPhone масштабируются из него) | iPhone 17 Pro Max | 1320×2868 | `0135421F-38B2-4A18-8CB4-69FF15B1751F` |
| App Store, iPad 13" (обязателен, пока в сборке есть iPad) | iPad Pro 13" (M4) | 2064×2752 | `CBDA5116-1247-46BF-8200-4DFEDEAD078E` |
| Google Play, телефон | iPhone 17 Pro Max, кадр обрезан до 9:16 (Play принимает только 16:9…9:16) | 1320×2347 | тот же iPhone + `sips --cropToHeightWidth 2347 1320` (обрезка по центру — сверху и снизу уходит фон) |
| Google Play, планшет 7" и 10" | iPad Pro 13" (2064×2752 = 3:4, в допуске) | | тот же iPad |
| Google Play, feature graphic | — | 1024×500, PNG/JPEG без альфы | `store/play_feature_graphic_1024x500.png` |

### Как снято (2026-09-25, en-US)

`script/store_shots.sh <udid> <outdir> [locale]` — запускает `integration_test/store_shots_test.dart` (prod-флейвор, без плашки DEV), ставит статус-бар 9:41 и снимает кадры по маркерам `SHOT NN`. Сцены ставятся детерминированно: автоспавн и пикапы глушатся `restore` снимка с `spawnIn = 1e6`, фигуры расставляются `UnitSnapshot`-ами, маршруты рисуются `routeStart/routeMove` по квадратичной кривой до стыковки, счёт в HUD — через `GameCubit.onDelivered()`. Кадр 04 — две фигуры на 46 ед. друг от друга (кольцо «!», без столкновения). Другая локаль — третьим аргументом (`ru`, `ja`, …), на симуляторе перед этим закрыть другие приложения (иначе «◀ App» в статус-баре).

| Папка | Устройство | Размер | Статус |
|---|---|---|---|
| `store/screenshots/iphone69/en-US/01–06.png` | iPhone 17 Pro Max | 1320×2868 | готово |
| `store/screenshots/ipad13/en-US/01–06.png` | iPad Pro 13" (M4) | 2064×2752 | снято, **но см. вопрос про iPad ниже**; в статус-баре дата на языке симулятора («Пт 25 сент.») — перед финальной съёмкой переключить язык симулятора на английский (`xcrun simctl spawn <udid> defaults write .GlobalPreferences AppleLanguages -array en` и перезагрузить) |
| `store/screenshots/play/en-US/01–06.png` | обрезка iPhone-кадров до 9:16 (`sips --cropToHeightWidth 2347 1320`) | 1320×2347 | готово |
| `store/play_feature_graphic_1024x500.png` | `swift script/make_feature_graphic.swift store/icon_rounded_1024.png <out>` | 1024×500 | готово |

**Открытый вопрос — iPad.** Сборка объявляет iPad (`TARGETED_DEVICE_FAMILY = 1,2`), но поле растягивается на всю ширину 4:3: фигуры и ворота огромные, путь от спавна до ворот вдвое короче, чем на телефоне, — играется иначе. Варианты: (а) на 1.0 оставить только iPhone (`TARGETED_DEVICE_FAMILY = 1` во всех конфигурациях, iPad-скриншоты тогда не нужны); (б) сделать колонку по центру с ограниченной шириной (как у WasDrop) и переснять iPad. Рекомендация — (а) для 1.0, (б) в 1.1.

Локали без своих скриншотов в App Store Connect берут кадры основной локали (en-US). Если снимать ru/ja: `script/store_shots.sh <udid> store/screenshots/iphone69/ru-RU ru`.

## 7. Чеклист форм

### App Store Connect
- App Information: имя, подзаголовок по локалям (§ 3), категория Games → Casual (+ Puzzle), Content Rights — нет стороннего контента, Age Rating — все «None», без неограниченного веб-доступа, без азартных игр → 4+.
- App Privacy: «Data Not Collected» (после публикации политика по ссылке § 1). Privacy Policy URL — § 1.
- Pricing: Free, все страны.
- Version: Description, Keywords, Promotional Text, Support URL (https://pyf.app), Marketing URL (§ 1), Copyright, Version 1.0.0, What's New (§ 4), скриншоты 6.9" и 13" (§ 6).
- App Review Information: контакт (имя, телефон, email), Sign-in **не** требуется, Notes (§ 5).
- Export Compliance: сборка уже несёт `ITSAppUsesNonExemptEncryption = false` — вопросов не будет.
- Build: `script/build.sh prod ipa --upload`.

### Google Play Console
- Приложение ещё не заведено: создать, Default language en-US, тип Game, Free.
- Store listing: Title, Short/Full description по локалям (§ 3), иконка 512, feature graphic 1024×500, скриншоты телефона (≥ 2, 9:16) и планшетов 7"/10" (§ 6).
- Store settings: категория Arcade, контакт email, сайт.
- App content: Privacy policy URL; Ads — нет; App access — все функции без входа; Content rating (IARC) — анкета «Game», все «нет» → Everyone; Target audience — 13+ (без детской программы, иначе доп. требования) либо «все возрасты» с Families policy; News app — нет; COVID — нет; Data safety — «не собирает и не передаёт», данные шифруются не нужно, удаление не нужно; Government apps — нет; Financial features — нет; Health — нет.
- Release: `script/build.sh prod aab`, подпись из `android/key.properties`, Internal testing → Production.
