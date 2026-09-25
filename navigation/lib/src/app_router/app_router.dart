import 'package:domain/domain.dart';
import 'package:features/features.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

Page<dynamic> _fade(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Маршруты: `/menu` (стартовый), `/game`, `/settings`; все с fade-переходом.
/// Из игры в меню — `goNamed('menu')`, чтобы свежее меню перечитало рекорд.
class AppRouter {
  GoRouter get router => _router;

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  final GoRouter _router = GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: '/menu',
    routes: <RouteBase>[
      GoRoute(
        path: '/menu',
        name: 'menu',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(context, state, const MenuScreen()),
      ),
      GoRoute(
        path: '/game',
        name: 'game',
        // extra — RunSnapshot незавершённого забега («Продолжить» в меню).
        pageBuilder: (BuildContext context, GoRouterState state) => _fade(
          context,
          state,
          GameScreen(resumeFrom: state.extra as RunSnapshot?),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(context, state, const SettingsScreen()),
      ),
    ],
  );
}
