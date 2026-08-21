import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const int buttonStartMilliseconds = 1300;
  static const int idleAnimationDurationMs = 2000;
  static const double idleScaleBegin = 1.0;
  static const double idleScaleEnd = 1.03;
  static const double buttonHeight = 56.0;
  static const double buttonWidth = 240.0;
  static const double buttonHorizontalPadding = 24.0;
  static const double buttonBottomPadding = 48.0;

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
        milliseconds: SplashScreen.idleAnimationDurationMs,
      ),
    );

    _buttonOpacity = const AlwaysStoppedAnimation(0.0);
    _buttonScale =
        Tween<double>(
          begin: SplashScreen.idleScaleBegin,
          end: SplashScreen.idleScaleEnd,
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

                    final startFraction =
                        (SplashScreen.buttonStartMilliseconds /
                                composition.duration.inMilliseconds)
                            .clamp(0.0, 1.0);

                    setState(() {
                      _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0)
                          .animate(
                            CurvedAnimation(
                              parent: _introController,
                              curve: Interval(
                                startFraction,
                                1.0,
                                curve: Curves.easeInOut,
                              ),
                            ),
                          );
                    });

                    Future.delayed(
                      const Duration(
                        milliseconds: SplashScreen.buttonStartMilliseconds,
                      ),
                      () {
                        if (mounted) {
                          _idleController.repeat(reverse: true);
                        }
                      },
                    );

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
                      bottom: SplashScreen.buttonBottomPadding,
                      left: SplashScreen.buttonHorizontalPadding,
                      right: SplashScreen.buttonHorizontalPadding,
                    ),
                    child: SizedBox(
                      width: SplashScreen.buttonWidth * _buttonScale.value,
                      height: SplashScreen.buttonHeight * _buttonScale.value,
                      child: FilledButton(
                        onPressed: () {
                          if (!_introController.isCompleted) return;
                          context.go(AppRoutes.onboardingPath);
                        },
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
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
