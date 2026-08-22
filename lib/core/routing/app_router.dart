import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/providers/sign_up_provider.dart';
import '../../features/auth/presentation/providers/sign_in_provider.dart';
import '../../features/auth/presentation/providers/forgot_password_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../constants/app_routes.dart';
import '../constants/app_animations.dart';

class _ConditionalOffsetTween extends Tween<Offset> {
  _ConditionalOffsetTween({super.begin, super.end});

  @override
  Offset lerp(double t) {
    if (AppRouter.isNavigatingToForgotPassword ||
        AppRouter.isNavigatingSequentially) {
      return AppAnimations.offsetZero;
    }
    return super.lerp(t);
  }
}

class AppRouter {
  static const double transitionHalf = 0.5;
  static const double transitionFull = 1.0;

  static bool isNavigatingToForgotPassword = false;
  static bool isNavigatingSequentially = false;

  static void navigateSequentially(BuildContext context, String path) {
    isNavigatingSequentially = true;
    context.go(path, extra: {'isSequential': true});
    Future.delayed(const Duration(milliseconds: 1000), () {
      isNavigatingSequentially = false;
    });
  }

  static CustomTransitionPage _buildCrossFadeTransitionPage({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: AppAnimations.fadeDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeIn = Tween<double>(
          begin: AppAnimations.opacityBegin,
          end: AppAnimations.opacityEnd,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn));
        return FadeTransition(opacity: fadeIn, child: child);
      },
    );
  }

  static CustomTransitionPage _buildSequentialFadeTransitionPage({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 800),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final bgOpacity =
            Tween<double>(
              begin: AppAnimations.opacityBegin,
              end: AppAnimations.opacityEnd,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              ),
            );

        final contentOpacity =
            Tween<double>(
              begin: AppAnimations.opacityBegin,
              end: AppAnimations.opacityEnd,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
              ),
            );

        return Stack(
          children: [
            FadeTransition(
              opacity: bgOpacity,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            FadeTransition(opacity: contentOpacity, child: child),
          ],
        );
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
      transitionDuration: AppAnimations.slideDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleIn =
            Tween<double>(
              begin: AppAnimations.scaleBegin,
              end: AppAnimations.scaleEnd,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(
                  transitionHalf,
                  transitionFull,
                  curve: Curves.easeOutCubic,
                ),
              ),
            );

        final fadeIn =
            Tween<double>(
              begin: AppAnimations.opacityBegin,
              end: AppAnimations.opacityEnd,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(
                  transitionHalf,
                  transitionFull,
                  curve: Curves.easeIn,
                ),
              ),
            );

        return FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(scale: scaleIn, child: child),
        );
      },
    );
  }

  static CustomTransitionPage _buildSlideTransitionPage({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: AppAnimations.slideDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideIn =
            Tween<Offset>(
              begin: AppAnimations.offsetRight,
              end: AppAnimations.offsetZero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );
        final slideOut =
            _ConditionalOffsetTween(
              begin: AppAnimations.offsetZero,
              end: AppAnimations.offsetLeft,
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );
        return SlideTransition(
          position: slideOut,
          child: SlideTransition(position: slideIn, child: child),
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
        pageBuilder: (context, state) => _buildCrossFadeTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.homeName,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isSequential = extra?['isSequential'] == true;

          if (isSequential) {
            return _buildSequentialFadeTransitionPage(
              key: state.pageKey,
              child: const HomeScreen(),
            );
          }
          return _buildCrossFadeTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          );
        },
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
          final isSequential = extra?['isSequential'] == true;

          final child = ChangeNotifierProvider(
            create: (_) => SignUpProvider(),
            child: const SignUpScreen(),
          );

          return CustomTransitionPage(
            key: state.pageKey,
            transitionDuration: isSequential
                ? const Duration(milliseconds: 800)
                : AppAnimations.slideDuration,
            child: child,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final slideOutToLeft =
                      _ConditionalOffsetTween(
                        begin: AppAnimations.offsetZero,
                        end: AppAnimations.offsetLeft,
                      ).animate(
                        CurvedAnimation(
                          parent: secondaryAnimation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        ),
                      );

                  Widget primaryTransition;

                  if (isSequential) {
                    final bgOpacity =
                        Tween<double>(
                          begin: AppAnimations.opacityBegin,
                          end: AppAnimations.opacityEnd,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              0.0,
                              0.5,
                              curve: Curves.easeOut,
                            ),
                          ),
                        );
                    final contentOpacity =
                        Tween<double>(
                          begin: AppAnimations.opacityBegin,
                          end: AppAnimations.opacityEnd,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              0.5,
                              1.0,
                              curve: Curves.easeIn,
                            ),
                          ),
                        );
                    primaryTransition = Stack(
                      children: [
                        FadeTransition(
                          opacity: bgOpacity,
                          child: Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        FadeTransition(opacity: contentOpacity, child: child),
                      ],
                    );
                  } else if (isPush) {
                    final slideInFromLeft =
                        Tween<Offset>(
                          begin: AppAnimations.offsetLeft,
                          end: AppAnimations.offsetZero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                            reverseCurve: Curves.easeInCubic,
                          ),
                        );
                    primaryTransition = SlideTransition(
                      position: slideInFromLeft,
                      child: child,
                    );
                  } else {
                    final scaleIn =
                        Tween<double>(
                          begin: AppAnimations.scaleBegin,
                          end: AppAnimations.scaleEnd,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              transitionHalf,
                              transitionFull,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        );
                    final fadeIn =
                        Tween<double>(
                          begin: AppAnimations.opacityBegin,
                          end: AppAnimations.opacityEnd,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              transitionHalf,
                              transitionFull,
                              curve: Curves.easeIn,
                            ),
                          ),
                        );
                    primaryTransition = FadeTransition(
                      opacity: fadeIn,
                      child: ScaleTransition(scale: scaleIn, child: child),
                    );
                  }

                  return SlideTransition(
                    position: slideOutToLeft,
                    child: primaryTransition,
                  );
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
          final isSequential = extra?['isSequential'] == true;

          final child = ChangeNotifierProvider(
            create: (_) => SignInProvider(),
            child: const SignInScreen(),
          );

          return CustomTransitionPage(
            key: state.pageKey,
            transitionDuration: isSequential
                ? const Duration(milliseconds: 800)
                : AppAnimations.slideDuration,
            child: child,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final slideOutToRight =
                      _ConditionalOffsetTween(
                        begin: AppAnimations.offsetZero,
                        end: AppAnimations.offsetRight,
                      ).animate(
                        CurvedAnimation(
                          parent: secondaryAnimation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        ),
                      );

                  Widget primaryTransition;

                  if (isSequential) {
                    final bgOpacity =
                        Tween<double>(
                          begin: AppAnimations.opacityBegin,
                          end: AppAnimations.opacityEnd,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              0.0,
                              0.5,
                              curve: Curves.easeOut,
                            ),
                          ),
                        );
                    final contentOpacity =
                        Tween<double>(
                          begin: AppAnimations.opacityBegin,
                          end: AppAnimations.opacityEnd,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              0.5,
                              1.0,
                              curve: Curves.easeIn,
                            ),
                          ),
                        );
                    primaryTransition = Stack(
                      children: [
                        FadeTransition(
                          opacity: bgOpacity,
                          child: Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                        FadeTransition(opacity: contentOpacity, child: child),
                      ],
                    );
                  } else if (isPush) {
                    final slideInFromRight =
                        Tween<Offset>(
                          begin: AppAnimations.offsetRight,
                          end: AppAnimations.offsetZero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                            reverseCurve: Curves.easeInCubic,
                          ),
                        );
                    primaryTransition = SlideTransition(
                      position: slideInFromRight,
                      child: child,
                    );
                  } else {
                    final scaleIn =
                        Tween<double>(
                          begin: AppAnimations.scaleBegin,
                          end: AppAnimations.scaleEnd,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              transitionHalf,
                              transitionFull,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        );
                    final fadeIn =
                        Tween<double>(
                          begin: AppAnimations.opacityBegin,
                          end: AppAnimations.opacityEnd,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: const Interval(
                              transitionHalf,
                              transitionFull,
                              curve: Curves.easeIn,
                            ),
                          ),
                        );
                    primaryTransition = FadeTransition(
                      opacity: fadeIn,
                      child: ScaleTransition(scale: scaleIn, child: child),
                    );
                  }

                  return SlideTransition(
                    position: slideOutToRight,
                    child: primaryTransition,
                  );
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
      GoRoute(
        path: AppRoutes.profilePath,
        name: AppRoutes.profileName,
        pageBuilder: (context, state) {
          return _buildSlideTransitionPage(
            key: state.pageKey,
            child: ChangeNotifierProvider(
              create: (_) => ProfileProvider(),
              child: const ProfileScreen(),
            ),
          );
        },
      ),
    ],
  );
}
