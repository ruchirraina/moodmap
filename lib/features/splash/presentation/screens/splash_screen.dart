import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_routes.dart';
import '../../constants/splash_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _idleController;
  late Animation<double> _buttonOpacity;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(vsync: this);
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: SplashConstants.idleAnimationDurationMs,
      ),
    );

    _buttonOpacity = const AlwaysStoppedAnimation(0.0);
    _buttonScale =
        Tween<double>(
          begin: SplashConstants.idleScaleBegin,
          end: SplashConstants.idleScaleEnd,
        ).animate(
          CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _introController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final activeAnimation = isDarkMode
        ? AppAssets.splashAnimationDark
        : AppAssets.splashAnimationLight;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Lottie.asset(
                  activeAnimation,
                  controller: _introController,
                  frameRate: FrameRate.max,
                  onLoaded: (composition) {
                    _introController.duration = composition.duration;

                    final isLoggedIn =
                        FirebaseAuth.instance.currentUser != null;

                    if (isLoggedIn) {
                      Future.delayed(
                        composition.duration +
                            const Duration(
                              milliseconds:
                                  SplashConstants.loginTransitionDelayMs,
                            ),
                        () {
                          if (context.mounted) {
                            context.go(AppRoutes.homePath);
                          }
                        },
                      );
                    } else {
                      final startFraction =
                          (SplashConstants.buttonStartMilliseconds /
                                  composition.duration.inMilliseconds)
                              .clamp(
                                SplashConstants.animationStartFraction,
                                SplashConstants.animationEndFraction,
                              );

                      setState(() {
                        _buttonOpacity =
                            Tween<double>(
                              begin: SplashConstants.animationStartFraction,
                              end: SplashConstants.animationEndFraction,
                            ).animate(
                              CurvedAnimation(
                                parent: _introController,
                                curve: Interval(
                                  startFraction,
                                  SplashConstants.animationEndFraction,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                            );
                      });

                      Future.delayed(
                        const Duration(
                          milliseconds: SplashConstants.buttonStartMilliseconds,
                        ),
                        () {
                          if (mounted) {
                            _idleController.repeat(reverse: true);
                          }
                        },
                      );
                    }

                    FlutterNativeSplash.remove();
                    _introController.forward();
                  },
                ),
              ),
            ),
            AnimatedBuilder(
              animation: Listenable.merge([_introController, _idleController]),
              builder: (context, child) {
                return Opacity(
                  opacity: _buttonOpacity.value,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: SplashConstants.buttonBottomPadding,
                      left: SplashConstants.buttonHorizontalPadding,
                      right: SplashConstants.buttonHorizontalPadding,
                    ),
                    child: SizedBox(
                      width: SplashConstants.buttonWidth * _buttonScale.value,
                      height: SplashConstants.buttonHeight * _buttonScale.value,
                      child: FilledButton(
                        onPressed: () {
                          if (!_introController.isCompleted) return;
                          context.go(AppRoutes.onboardingPath);
                        },
                        child: const Text(
                          SplashConstants.getStartedButtonText,
                          style: TextStyle(
                            fontSize: SplashConstants.buttonTextSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
