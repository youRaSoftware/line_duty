# Line Duty на лендинге pyf.app — что и куда класть

Пакет для проекта `pyf-landing` (Next.js 16, скилл `mdx-content`). Слаг — `line-duty`, страница политики — `https://www.pyf.app/en/apps/line-duty/privacy` (этот URL уже прописан в приложении: `AppConstants.privacyPolicyUrl`, строка «Политика конфиденциальности» в настройках).

## 1. Контент (MDX)

Скопировать в `pyf-landing/src/content/apps/`:

| Файл здесь | Куда |
|---|---|
| `content/line-duty.en.mdx` | `src/content/apps/line-duty.en.mdx` |
| `content/line-duty.ru.mdx` | `src/content/apps/line-duty.ru.mdx` |
| `content/line-duty.privacy.en.mdx` | `src/content/apps/line-duty.privacy.en.mdx` |
| `content/line-duty.privacy.ru.mdx` | `src/content/apps/line-duty.privacy.ru.mdx` |

Frontmatter повторяет схему Fruity Drop: `status: coming-soon`, `appStoreUrl: ""`, `featured: false` (пока нет hero-видео), `accentColor: "#3E8BE8"` (синий потока темы Метро), `releaseDate: 2026-10-15` — поправить, когда будет дата. Иконки фич — имена из lucide-react (`pen-tool`, `shapes`, `alert-triangle`, `layers`, `hexagon`, `wifi-off`); если какого-то нет в используемой версии lucide, заменить на близкое.

## 2. Картинки

Скопировать папку `public/` в `pyf-landing/public/apps/line-duty/`:

| Файл | Что это |
|---|---|
| `icon.png` | иконка 1024×1024, скруглённая, прозрачные углы (та же, что в сторах) |
| `screenshot-1.png` | меню, тема Метро |
| `screenshot-2.png` | поле Метро с двумя маршрутами |
| `screenshot-3.png` | поле Город (автобусы) |
| `screenshot-4.png` | поле Аквариум (рыбки) |
| `screenshot-5.png` | обучение «Как играть», шаг «Рисуй маршрут» |

Скриншоты сняты с prod-сборки на iPhone 17 Pro (1206×2622, без плашки DEV), язык интерфейса — английский, статус-бар 9:41. Пересъёмка: временный интеграционный тест по образцу `integration_test/game_smoke_test.dart` (setThemeId / setLocale, `debugPrint('SHOT …')` как маркер) + `xcrun simctl io <udid> screenshot`; перед запуском `xcrun simctl status_bar <udid> override --time 9:41 --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4` и закрыть другие приложения, иначе в статус-баре будет «◀ <app>».

## 3. Реестр приложений

В `src/data/apps.ts` добавить запись (по образцу `fruity-drop`), поля должны совпадать с frontmatter:

```ts
{
  slug: "line-duty",
  name: "Line Duty",
  tagline: "Draw routes, keep them apart",
  category: "Games",
  appStoreUrl: "",
  googlePlayUrl: "",
  price: "Free",
  minIOSVersion: "15.0",
  status: "coming-soon",
  featured: false,
  accentColor: "#3E8BE8",
  theme: {
    accent: "#3E8BE8",
    accentRgb: "62 139 232",
    soft: "#6FA8F0",
    deep: "#2A66B8",
    tint: "#D6E6FA",
  },
  releaseDate: "2026-10-15",
  icon: "/apps/line-duty/icon.png",
  screenshots: [
    "/apps/line-duty/screenshot-1.png",
    "/apps/line-duty/screenshot-2.png",
    "/apps/line-duty/screenshot-3.png",
    "/apps/line-duty/screenshot-4.png",
    "/apps/line-duty/screenshot-5.png",
  ],
},
```

Если в `apps.ts` `tagline` локализуется отдельно (проверить по `fruity-drop`), русский вариант — «Рисуй маршруты, не сталкивай».

## 4. Проверка

```bash
npm run build
```

Открыть `/en/apps/line-duty`, `/ru/apps/line-duty`, `/en/apps/line-duty/privacy`, `/ru/apps/line-duty/privacy`. Последний URL должен открываться из настроек приложения (строка «Политика конфиденциальности»).

## 5. Когда появятся ссылки сторов

`appStoreUrl`, `googlePlayUrl`, `status: released`, `releaseDate` — и в MDX (оба языка), и в `apps.ts`. В приложении вписать `AppConstants.appStoreId` — появится «Оценить».
