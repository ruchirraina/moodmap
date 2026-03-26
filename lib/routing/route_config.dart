import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moodmap/screens/home/home.dart';
import 'package:moodmap/screens/intro_splash.dart';
import 'package:moodmap/screens/onboarding/onb_screens.dart';
import 'package:moodmap/screens/auth/auth_ui.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const IntroSplash()),

    GoRoute(
      path: '/onboarding',
      // a FadeTransition navigation
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const OnbScreens(),
        // half a second feels right
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    ),

    GoRoute(
      path: '/auth',
      // a boom in your face type anim nav
      pageBuilder: (context, state) {
        final bool loadSignUp = state.uri.queryParameters['signup'] != 'false';

        // first time from onb_screen3
        if (state.extra == 'scale_anim') {
          return CustomTransitionPage(
            key: state.pageKey,
            child: AuthUi(loadSignUp: loadSignUp),
            // half a second feels right
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  // create a CurvedAnimation
                  final curvedAnimation = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutQuart,
                  );
                  // a ScaleTransition by CurvedAnimation
                  return ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(curvedAnimation),
                    child: child,
                  );
                },
          );
        }

        // default
        return MaterialPage(
          key: state.pageKey,
          child: AuthUi(loadSignUp: loadSignUp),
        );
      },
    ),

    GoRoute(path: '/home', builder: (context, state) => const Home()),
  ],
);
