import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/providers/sign_up_provider.dart';
import '../../features/auth/presentation/providers/sign_in_provider.dart';
import '../../features/auth/presentation/providers/forgot_password_provider.dart';
import '../constants/app_routes.dart';

class AppRouter {
  static const int fadeDurationMs = 600;
  static const int slideDurationMs = 400;

  static CustomTransitionPage _buildFadeTransitionPage({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: fadeDurationMs),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
          ),
        );
        return FadeTransition(opacity: fadeIn, child: child);
      },
    );
  }

  static CustomTransitionPage _buildScaleFadeTransitionPage({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: slideDurationMs),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleIn = Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

        final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

        return FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(scale: scaleIn, child: child),
        );
      },
    );
  }

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashPath,
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingPath,
        name: AppRoutes.onboardingName,
        pageBuilder: (context, state) => _buildScaleFadeTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signUpPath,
        name: AppRoutes.signUpName,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isPush = extra?['isPush'] == true;

          return CustomTransitionPage(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: slideDurationMs),
            child: ChangeNotifierProvider(
              create: (_) => SignUpProvider(),
              child: const SignUpScreen(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  if (isPush) {
                    final slideInFromLeft =
                        Tween<Offset>(
                          begin: const Offset(-1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                            reverseCurve: Curves.easeInCubic,
                          ),
                        );

                    return SlideTransition(
                      position: slideInFromLeft,
                      child: child,
                    );
                  } else {
                    final scaleIn = Tween<double>(begin: 0.9, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                      ),
                    );

                    final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                      ),
                    );

                    return FadeTransition(
                      opacity: fadeIn,
                      child: ScaleTransition(scale: scaleIn, child: child),
                    );
                  }
                },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signInPath,
        name: AppRoutes.signInName,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isPush = extra?['isPush'] == true;

          return CustomTransitionPage(
            key: state.pageKey,
            transitionDuration: const Duration(milliseconds: slideDurationMs),
            child: ChangeNotifierProvider(
              create: (_) => SignInProvider(),
              child: const SignInScreen(),
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  if (isPush) {
                    final slideInFromRight =
                        Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                            reverseCurve: Curves.easeInCubic,
                          ),
                        );

                    return SlideTransition(
                      position: slideInFromRight,
                      child: child,
                    );
                  } else {
                    final scaleIn = Tween<double>(begin: 0.9, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                      ),
                    );

                    final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                        reverseCurve: Curves.easeInCubic,
                      ),
                    );

                    return FadeTransition(
                      opacity: fadeIn,
                      child: ScaleTransition(scale: scaleIn, child: child),
                    );
                  }
                },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPasswordPath,
        name: AppRoutes.forgotPasswordName,
        pageBuilder: (context, state) {
          return _buildScaleFadeTransitionPage(
            key: state.pageKey,
            child: ChangeNotifierProvider(
              create: (_) => ForgotPasswordProvider(),
              child: const ForgotPasswordScreen(),
            ),
          );
        },
      ),
    ],
  );
}
