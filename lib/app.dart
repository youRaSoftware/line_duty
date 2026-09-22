import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Корень приложения. Тема оформления берётся из `SettingsModel.themeId`:
/// палитра применяется глобально ([AppColors.apply]) до построения дерева,
/// Material-тема и системные панели строятся под неё, а контент
/// перемонтируется по ключу палитры — иначе `const`-виджеты не перерисуются.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final AppConfig config = appLocator<AppConfig>();
    final AppRouter appRouter = appLocator<AppRouter>();

    return ValueListenableBuilder<SettingsModel>(
      valueListenable: appLocator<SettingsService>().settings,
      builder: (BuildContext context, SettingsModel settings, Widget? _) {
        final AppPalette palette = AppPalettes.byId(settings.themeId);
        AppColors.apply(palette);
        final ThemeData theme = appTheme(palette);

        return MaterialApp.router(
          title: config.appName,
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: theme,
          // Язык — из EasyLocalization над App (см. lib/main_common.dart);
          // делегаты включают Material-локализацию встроенных экранов.
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routeInformationParser: appRouter.router.routeInformationParser,
          routeInformationProvider: appRouter.router.routeInformationProvider,
          routerDelegate: appRouter.router.routerDelegate,
          builder: (BuildContext context, Widget? child) {
            final Widget content = AnnotatedRegion<SystemUiOverlayStyle>(
              value: systemUiStyle(palette),
              child: KeyedSubtree(
                key: ValueKey<String>(palette.id),
                child: child ?? const SizedBox.shrink(),
              ),
            );
            return config.showFlavorBanner
                ? Banner(
                    message: config.flavor.name.toUpperCase(),
                    location: BannerLocation.topEnd,
                    color: AppColors.danger,
                    child: content,
                  )
                : content;
          },
        );
      },
    );
  }
}
