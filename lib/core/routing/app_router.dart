import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/splash/presentation/providers/splash_provider.dart';
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
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/journal/presentation/screens/journal_editor_screen.dart';
import '../../features/journal/presentation/providers/journal_editor_provider.dart';
import '../../features/journal/domain/models/journal_entry.dart';
import '../../features/journal/presentation/screens/journal_expanded_screen.dart';
import '../../features/music/presentation/screens/music_search_screen.dart';
import '../../features/music/presentation/providers/music_search_provider.dart';
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

class _ConditionalScaleTween extends Tween<double> {
  _ConditionalScaleTween({super.begin, super.end});

  @override
  double lerp(double t) {
    if (AppRouter.isNavigatingWithFade) {
      return AppAnimations.scaleEnd;
    }
    if (t <= AppRouter.transitionHalf) return AppAnimations.scaleBegin;
    final mappedT =
        (t - AppRouter.transitionHalf) /
        (AppRouter.transitionFull - AppRouter.transitionHalf);
    return super.lerp(Curves.easeOutCubic.transform(mappedT));
  }
}

class _ConditionalOpacityTween extends Tween<double> {
  _ConditionalOpacityTween({super.begin, super.end});

  @override
  double lerp(double t) {
    if (AppRouter.isNavigatingWithFade) {
      return super.lerp(Curves.easeInOut.transform(t));
    }
    if (t <= AppRouter.transitionHalf) return AppAnimations.opacityBegin;
    final mappedT =
        (t - AppRouter.transitionHalf) /
        (AppRouter.transitionFull - AppRouter.transitionHalf);
    return super.lerp(Curves.easeIn.transform(mappedT));
  }
}

class AppRouter {
  static const double transitionHalf = 0.5;
  static const double transitionFull = 1.0;

  static bool isNavigatingToForgotPassword = false;
  static bool isNavigatingSequentially = false;
  static bool isNavigatingWithFade = false;

  static void navigateSequentially(BuildContext context, String path) {
    isNavigatingSequentially = true;
    context.go(path, extra: {AppRoutes.argIsSequential: true});
    Future.delayed(AppAnimations.sequentialDelayDuration, () {
      isNavigatingSequentially = false;
    });
  }

  static void navigateWithFade(
    BuildContext context,
    String path, {
    Object? extra,
  }) {
    isNavigatingWithFade = true;
    context.pushReplacement(path, extra: extra);
    Future.delayed(AppAnimations.fadeDuration, () {
      isNavigatingWithFade = false;
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
      transitionDuration: AppAnimations.sequentialTransitionDuration,
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
        final scaleIn = _ConditionalScaleTween(
          begin: AppAnimations.scaleBegin,
          end: AppAnimations.scaleEnd,
        ).animate(animation);

        final fadeIn = _ConditionalOpacityTween(
          begin: AppAnimations.opacityBegin,
          end: AppAnimations.opacityEnd,
        ).animate(animation);

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

  static CustomTransitionPage _buildPureFadeTransitionPage({
    required Widget child,
    required LocalKey key,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: AppAnimations.fadeDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage _buildAuthTransitionPage({
    required Widget child,
    required LocalKey key,
    required bool isSequential,
    required bool isPush,
    required bool isSlideLeft,
  }) {
    return CustomTransitionPage(
      key: key,
      transitionDuration: isSequential
          ? AppAnimations.sequentialTransitionDuration
          : AppAnimations.slideDuration,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideOut =
            _ConditionalOffsetTween(
              begin: AppAnimations.offsetZero,
              end: isSlideLeft
                  ? AppAnimations.offsetLeft
                  : AppAnimations.offsetRight,
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
          final slideIn =
              Tween<Offset>(
                begin: isSlideLeft
                    ? AppAnimations.offsetLeft
                    : AppAnimations.offsetRight,
                end: AppAnimations.offsetZero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                  reverseCurve: Curves.easeInCubic,
                ),
              );
          primaryTransition = SlideTransition(position: slideIn, child: child);
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

        return SlideTransition(position: slideOut, child: primaryTransition);
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
          child: ChangeNotifierProvider(
            create: (_) => SplashProvider(),
            child: const SplashScreen(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.homeName,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isSequential = extra?[AppRoutes.argIsSequential] == true;

          final child = ChangeNotifierProvider(
            create: (_) => HomeProvider(),
            child: const HomeScreen(),
          );

          if (isSequential) {
            return _buildSequentialFadeTransitionPage(
              key: state.pageKey,
              child: child,
            );
          }
          return _buildCrossFadeTransitionPage(
            key: state.pageKey,
            child: child,
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
          final isPush = extra?[AppRoutes.argIsPush] == true;
          final isSequential = extra?[AppRoutes.argIsSequential] == true;

          final child = ChangeNotifierProvider(
            create: (_) => SignUpProvider(),
            child: const SignUpScreen(),
          );

          return _buildAuthTransitionPage(
            child: child,
            key: state.pageKey,
            isSequential: isSequential,
            isPush: isPush,
            isSlideLeft: true,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signInPath,
        name: AppRoutes.signInName,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isPush = extra?[AppRoutes.argIsPush] == true;
          final isSequential = extra?[AppRoutes.argIsSequential] == true;

          final child = ChangeNotifierProvider(
            create: (_) => SignInProvider(),
            child: const SignInScreen(),
          );

          return _buildAuthTransitionPage(
            child: child,
            key: state.pageKey,
            isSequential: isSequential,
            isPush: isPush,
            isSlideLeft: false,
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
      GoRoute(
        path: AppRoutes.journalEditorPath,
        name: AppRoutes.journalEditorName,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final entryDate =
              extra?[AppRoutes.argEntryDate] as DateTime? ?? DateTime.now();
          final existingEntry =
              extra?[AppRoutes.argExistingEntry] as JournalEntry?;
          final isFade = extra?[AppRoutes.argIsFadeTransition] == true;

          final child = ChangeNotifierProvider(
            create: (_) => JournalEditorProvider(),
            child: JournalEditorScreen(
              entryDate: entryDate,
              existingEntry: existingEntry,
            ),
          );

          if (isFade) {
            return _buildPureFadeTransitionPage(
              key: state.pageKey,
              child: child,
            );
          }
          return _buildScaleFadeTransitionPage(
            key: state.pageKey,
            child: child,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.journalExpandedPath,
        name: AppRoutes.journalExpandedName,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final existingEntry =
              extra?[AppRoutes.argExistingEntry] as JournalEntry;
          final isFade = extra?[AppRoutes.argIsFadeTransition] == true;

          final child = JournalExpandedScreen(entry: existingEntry);

          if (isFade) {
            return _buildPureFadeTransitionPage(
              key: state.pageKey,
              child: child,
            );
          }
          return _buildScaleFadeTransitionPage(
            key: state.pageKey,
            child: child,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.musicSearchPath,
        name: AppRoutes.musicSearchName,
        pageBuilder: (context, state) {
          return _buildSlideTransitionPage(
            key: state.pageKey,
            child: ChangeNotifierProvider(
              create: (_) => MusicSearchProvider(),
              child: const MusicSearchScreen(),
            ),
          );
        },
      ),
    ],
  );
}
