import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moodmap/screens/auth/pass_reset.dart';
import 'package:moodmap/screens/home/home.dart';
import 'package:moodmap/screens/intro_splash.dart';
import 'package:moodmap/screens/onboarding/onb_screens.dart';
import 'package:moodmap/screens/auth/auth_ui.dart';

// a general transition animation builder
CustomTransitionPage _buildGeneralTransitionPage({
  required Widget child,
  required LocalKey? key,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final scaleAnim = animation.drive(
        Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
      );

      final fadeAnim = animation.drive(CurveTween(curve: Curves.easeOutCubic));

      return ScaleTransition(
        scale: scaleAnim,
        child: FadeTransition(opacity: fadeAnim, child: child),
      );
    },
  );
}

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    // intro splash screen
    GoRoute(path: '/', builder: (context, state) => const IntroSplash()),

    // onboarding page (first time user)
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnbScreens(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),

    // auth page
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) {
        final bool loadSignUp = state.uri.queryParameters['signup'] != 'false';

        if (state.extra == 'scale_anim') {
          return _buildGeneralTransitionPage(
            key: state.pageKey,
            child: AuthUi(loadSignUp: loadSignUp),
          );
        }

        // default
        return MaterialPage(
          key: state.pageKey,
          child: AuthUi(loadSignUp: loadSignUp),
        );
      },
    ),

    // password reset page
    GoRoute(
      path: '/passReset',
      pageBuilder: (context, state) => _buildGeneralTransitionPage(
        key: state.pageKey,
        child: const PassReset(),
      ),
    ),

    // home page
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) =>
          _buildGeneralTransitionPage(key: state.pageKey, child: const Home()),
    ),
  ],
);
