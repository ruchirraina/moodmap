// intro splash sequence | first screen
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:moodmap/theme/theme_config.dart';
import 'package:moodmap/theme/theme_extension.dart';
import 'dart:math' as math;
import 'package:moodmap/screens/auth/auth_state.dart';
import 'package:pretty_animated_buttons/pretty_animated_buttons.dart';

class IntroSplash extends StatefulWidget {
  const IntroSplash({super.key});

  @override
  State<IntroSplash> createState() => _IntroSplashState();
}

// TickerProviderStateMixin so we can get vsync for AnimationControllers
class _IntroSplashState extends State<IntroSplash>
    with TickerProviderStateMixin {
  // lottie logo controller (animates app logo and name)
  late AnimationController _lottieLogoController;
  // background icon anim controller (floaties of journal, time, and pen)
  late AnimationController _iconAnimController;
  // controls ui element(floaties and button) visibility | initially not visible
  bool _uiElementsVisible = false;

  // store auth state
  bool _authState = false;

  @override
  void initState() {
    super.initState();

    // strip away the native splash asap
    FlutterNativeSplash.remove();

    // give vysnc to _lottieLogoController
    _lottieLogoController = AnimationController(vsync: this);

    // adding a listener so we as per how much lottie loaded -> load ui elements
    _lottieLogoController.addListener(_loadUIElements);

    // give vsync to _iconAnimController
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10), // also after which it reverses
    );

    // store auth state
    _authState = AuthState.loadAuthState();
    // if already auth
    if (_authState) _lottieLogoController.addListener(_navToHome);
  }

  // listens to _lottieLogoController | load ui elements
  void _loadUIElements() {
    // load when next stage of lottie animation is showing app name
    if (_lottieLogoController.value >= 0.80 && !_uiElementsVisible) {
      if (mounted) {
        setState(() {
          _uiElementsVisible = true;
        });
      }
      _iconAnimController.repeat(); // infinite loop
    }
  }

  // listens to _lottieLogoController | unload ui elements when button press
  void _unLoadUIElementsMoveNext() async {
    // unload when lottie animation is about to finish
    if (_lottieLogoController.value <= 0.50 && _uiElementsVisible) {
      if (mounted) {
        setState(() {
          _uiElementsVisible = false;
        });
      }

      // let lottie animation finish
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        // a FadeTransition navigation
        // router go bc ux wise why option to return?
        context.go('/onboarding');
      }
    }
  }

  // direct nav to home
  void _navToHome() async {
    // once lottie logo loads in
    if (_lottieLogoController.value == 1.0) {
      // ux wise 2 seconds wait once it loads
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.go('/home');
      }
    }
  }

  // helper Widget to make floaties
  Widget _buildBackgroundIcon({
    required double xCord,
    required double yCord,
    required IconData icon,
  }) {
    // icons in opp quad will move and roatate in reverse
    bool reverse = (xCord * yCord).isNegative;

    return Align(
      alignment: Alignment(xCord, yCord),
      child: ListenableBuilder(
        listenable: _iconAnimController, // listents to _iconAnimController
        builder: (context, child) {
          // convert 0.0-1.0 _iconAnimController value to sine value -1.0-1.0
          final double sineVal = math.sin(
            _iconAnimController.value * 2 * math.pi,
          );

          // floatie's current rotation (variable as _iconAnimController.value)
          final double currAngle = reverse ? (-sineVal * 0.4) : (sineVal * 0.4);

          // floaties current location (variable as _iconAnimController.value)
          final double floatOffset = reverse ? (-sineVal * 20) : (sineVal * 20);

          return Transform.translate(
            offset: Offset(0, floatOffset),
            child: Transform.rotate(angle: currAngle, child: child),
          );
        },
        // fade in when app opens and fade out when pressed button
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

  // on button press
  void _getStarted() {
    // removing old listener (floaties already loaded)
    _lottieLogoController.removeListener(_loadUIElements);
    // adding new listener so as to unload based on _lottieLogoController
    _lottieLogoController.addListener(_unLoadUIElementsMoveNext);
    // reverse the lottie animation
    _lottieLogoController.reverse();
  }

  // good habits :)
  @override
  void dispose() {
    _lottieLogoController.removeListener(_unLoadUIElementsMoveNext);
    _lottieLogoController.removeListener(_navToHome);
    _lottieLogoController.dispose();
    _iconAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // keyboard won't come up
      body: Stack(
        children: [
          Align(
            alignment: .center,
            child: FractionallySizedBox(
              // feels right than hardcoding
              widthFactor: 0.85,
              // the lottie json that shows app logo and title
              child: Lottie.asset(
                (context.theme.brightness == .light)
                    // light version
                    ? 'assets/intro_logo/moodmap_logo_light.json'
                    // dark version
                    : 'assets/intro_logo/moodmap_logo_dark.json',
                // as large as possible while
                // still containing the source entirely within the target box
                fit: .contain,
                // giving a controller
                controller: _lottieLogoController,
                onLoaded: (compostion) {
                  // pass in the duration
                  _lottieLogoController.duration = compostion.duration;
                  _lottieLogoController.forward(); // move forward
                },
              ),
            ),
          ),

          // bunch of floaties making background filled in non static
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

          // if not auth and no button fill in empty space
          if (!_authState)
            _buildBackgroundIcon(
              xCord: 0,
              yCord: 0.8,
              icon: Icons.book_outlined,
            ),

          // gotta protect it from being cut out
          if (!_authState) ...[
            SafeArea(
              child: AnimatedOpacity(
                opacity: _uiElementsVisible ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
                child: Align(
                  alignment: .bottomCenter,
                  child: Padding(
                    padding: const .symmetric(vertical: 32),
                    // cool animation on tap
                    child: PrettyWaveButton(
                      onPressed: _getStarted,
                      backgroundColor: context.colorScheme.primary,
                      borderRadius: 16, // trying to match logo border radius
                      child: Text(
                        'Get Started',
                        style: ThemeConfig.buttonTextTheme(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
