/// Внешние ссылки приложения (экран настроек).
abstract final class AppConstants {
  /// Политика конфиденциальности — страница на лендинге студии
  /// (`pyf-landing`, `src/content/apps/line-duty.privacy.*.mdx`).
  static const String privacyPolicyUrl =
      'https://www.pyf.app/en/apps/line-duty/privacy';

  /// Apple ID приложения в App Store Connect («Оценить приложение»).
  /// Пустая строка скрывает кнопку.
  static const String appStoreId = '';
}
