import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lottie/lottie.dart';
import 'package:moodmap/configs/theme_config.dart';
import 'package:moodmap/extensions/theme_extension.dart';
import 'package:moodmap/onboarding/info_pages/info_pages.dart';
import 'dart:math' as math;
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart';

class IntroSplash extends StatefulWidget {
  const IntroSplash({super.key});

  @override
  State<IntroSplash> createState() => _IntroSplashState();
}

// SingleTickerProviderStateMixin so we can get vsync for AnimationController
class _IntroSplashState extends State<IntroSplash>
    with TickerProviderStateMixin {
  // controls ui element visibility | initially not visible
  bool _uiElementsVisible = false;
  // lottie logo controller
  late AnimationController _lottieLogoController;
  // background icon anim controller
  late AnimationController _iconAnimController;

  @override
  void initState() {
    super.initState();

    // strip away the native splash asap
    FlutterNativeSplash.remove();

    _lottieLogoController = AnimationController(vsync: this);

    _lottieLogoController.addListener(_loadUIElements);

    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
  }

  void _loadUIElements() {
    if (_lottieLogoController.value >= 0.80 && !_uiElementsVisible) {
      if (mounted) {
        setState(() {
          _uiElementsVisible = true;
        });
      }
      _iconAnimController.repeat(); // infinite loop
    }
  }

  void _unLoadUIElementsMoveNext() async {
    if (_lottieLogoController.value <= 0.50 && _uiElementsVisible) {
      if (mounted) {
        setState(() {
          _uiElementsVisible = false;
        });
      }

      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                InfoPages(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) =>
                    FadeTransition(opacity: animation, child: child),
          ),
        );
      }
    }
  }

  Widget _buildBackgroundIcon({
    required double xCord,
    required double yCord,
    required IconData icon,
  }) {
    // icons in opp quad will move in reverse
    bool reverse = (xCord * yCord).isNegative;

    return Align(
      alignment: Alignment(xCord, yCord), // far top left
      child: ListenableBuilder(
        listenable: _iconAnimController,
        builder: (context, child) {
          // convert 0.0-1.0 _iconAnimController value to sine value -1.0-1.0
          final double sineVal = math.sin(
            _iconAnimController.value * 2 * math.pi,
          );

          final double currAngle = reverse ? (-sineVal * 0.4) : (sineVal * 0.4);

          final double floatOffset = reverse ? (-sineVal * 20) : (sineVal * 20);

          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: Transform.rotate(angle: currAngle, child: child),
          );
        },
        child: AnimatedOpacity(
          opacity: _uiElementsVisible ? 1 : 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.fastOutSlowIn,
          child: Icon(
            icon,
            color: context.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  void _getStarted() {
    _lottieLogoController.removeListener(_loadUIElements);
    _lottieLogoController.addListener(_unLoadUIElementsMoveNext);
    _lottieLogoController.reverse();
  }

  @override
  void dispose() {
    _lottieLogoController.removeListener(_unLoadUIElementsMoveNext);
    _lottieLogoController.dispose();
    _iconAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: .center,
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: Lottie.asset(
                (context.theme.brightness == .light)
                    ? 'assets/intro_logo/moodmap_logo_light.json'
                    : 'assets/intro_logo/moodmap_logo_dark.json',
                controller: _lottieLogoController,
                onLoaded: (compostion) {
                  _lottieLogoController.duration = compostion.duration;
                  _lottieLogoController.forward();
                },
              ),
            ),
          ),

          _buildBackgroundIcon(
            xCord: -0.8,
            yCord: -0.8,
            icon: Icons.edit_outlined,
          ),
          _buildBackgroundIcon(
            xCord: 0.0,
            yCord: -0.6,
            icon: Icons.book_outlined,
          ),
          _buildBackgroundIcon(xCord: 0.8, yCord: -0.8, icon: Icons.history),
          _buildBackgroundIcon(xCord: -0.9, yCord: -0.4, icon: Icons.history),
          _buildBackgroundIcon(
            xCord: 0.9,
            yCord: -0.35,
            icon: Icons.edit_outlined,
          ),
          _buildBackgroundIcon(
            xCord: -0.85,
            yCord: 0.08,
            icon: Icons.book_outlined,
          ),
          _buildBackgroundIcon(xCord: 0.85, yCord: 0.2, icon: Icons.history),
          _buildBackgroundIcon(xCord: -0.9, yCord: 0.85, icon: Icons.history),
          _buildBackgroundIcon(
            xCord: -0.5,
            yCord: 0.55,
            icon: Icons.edit_outlined,
          ),
          _buildBackgroundIcon(
            xCord: 0.5,
            yCord: 0.55,
            icon: Icons.book_outlined,
          ),
          _buildBackgroundIcon(
            xCord: 0.9,
            yCord: 0.85,
            icon: Icons.edit_outlined,
          ),

          SafeArea(
            child: AnimatedOpacity(
              opacity: _uiElementsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.fastOutSlowIn,
              child: Align(
                alignment: .bottomCenter,
                child: Padding(
                  padding: const .symmetric(vertical: 32),
                  child: PrettyWaveButton(
                    onPressed: _getStarted,
                    backgroundColor: context.colorScheme.primary,
                    borderRadius: 20,
                    child: Text(
                      'Get Started',
                      style: ThemeConfig.smallButtonTextTheme(context),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
