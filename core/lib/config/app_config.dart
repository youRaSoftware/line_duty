/// Окружение сборки. Задаётся нативным flavor (`--flavor dev|prod`) и
/// дублируется dart-define `--dart-define=environment=dev|prod`
/// (см. `lib/main.dart`).
enum Flavor {
  dev,
  prod;

  static Flavor fromString(String value) {
    switch (value.toLowerCase()) {
      case 'prod':
      case 'production':
      case 'release':
        return Flavor.prod;
      case 'dev':
      case 'development':
      default:
        return Flavor.dev;
    }
  }
}

/// Конфигурация приложения, зависящая от flavor. Регистрируется в
/// `appLocator` при старте (`setupAppScope`), читается как
/// `appLocator<AppConfig>()`.
class AppConfig {
  final Flavor flavor;
  final String appName;

  const AppConfig({required this.flavor, required this.appName});

  factory AppConfig.fromFlavor(Flavor flavor) {
    switch (flavor) {
      case Flavor.dev:
        return const AppConfig(flavor: Flavor.dev, appName: 'Line Dev');
      case Flavor.prod:
        return const AppConfig(flavor: Flavor.prod, appName: 'Line Duty');
    }
  }

  bool get isDev => flavor == Flavor.dev;

  bool get isProd => flavor == Flavor.prod;

  /// Плашка «DEV» поверх приложения — только в dev-сборке.
  bool get showFlavorBanner => isDev;

  /// Монетизация (реклама за продолжение). Первый релиз выходит без неё:
  /// продолжение после столкновения даётся бесплатно (`GameRules`), кнопка
  /// «Продолжить · реклама» показывается как «Продолжить». Включается
  /// `--dart-define=monetization=on`, когда появится рекламный SDK.
  static const bool monetizationEnabled =
      String.fromEnvironment('monetization') == 'on';
}
