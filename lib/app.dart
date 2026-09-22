import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final AppConfig config = appLocator<AppConfig>();
    final AppRouter appRouter = appLocator<AppRouter>();

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      themeMode: ThemeMode.dark,
      // Язык — из EasyLocalization над App (см. lib/main_common.dart);
      // делегаты включают Material-локализацию встроенных экранов.
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routeInformationParser: appRouter.router.routeInformationParser,
      routeInformationProvider: appRouter.router.routeInformationProvider,
      routerDelegate: appRouter.router.routerDelegate,
      builder: (BuildContext context, Widget? child) {
        final Widget content = child ?? const SizedBox.shrink();
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
  }
}
