// third onboarding screen | also has buttons to go to auth screen
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodmap/extensions/theme_extension.dart';
import 'package:moodmap/configs/theme_config.dart';
import 'package:moodmap/screens/auth/auth_ui.dart';

class OnbScreen3 extends StatelessWidget {
  const OnbScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    // function handling to auth nav
    // auth screen loads sign up or sign in page and default is sign up screen
    void navToAuth({bool loadSignUp = true}) {
      // a boom in your face type anim nav
      // pushReplacement bc ux wise why option to return?
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AuthUi(loadSignUp: loadSignUp),
          // half a second feels right
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // create a CurvedAnimation
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutExpo,
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
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false, // keyboard won't come up
      // regular column works
      body: Column(
        mainAxisAlignment: .center, // feels right
        children: [
          // restricting lottie json size
          SizedBox(
            height: 350,
            width: 350,
            // a cool abstract lottie json
            child: Lottie.asset(
              (context.theme.brightness == .light)
                  // light version
                  ? 'assets/info_pages_assets/info_pg3_asset_light.json'
                  // dark version
                  : 'assets/info_pages_assets/info_pg3_asset_dark.json',
              // as large as possible while
              // still containing the source entirely within the target box
              fit: .contain,
            ),
          ),
          // bottom text
          Padding(
            padding: const .symmetric(vertical: 20, horizontal: 32),
            child: Text(
              'Every week, your entries bloom into a gradient — rose, marigold, and wisteria.',
              style: context.textTheme.bodyMedium!.copyWith(fontWeight: .bold),
              textAlign: .center,
            ),
          ),
          // appropriate separation
          const SizedBox(height: 52),
          // sign up button
          FilledButton(
            onPressed: () => navToAuth(loadSignUp: true),
            style: FilledButton.styleFrom(
              // consistency with get started button
              minimumSize: const Size(175, 50),
              // consistency with get started button
              shape: RoundedRectangleBorder(borderRadius: .circular(16)),
            ),
            child: Text(
              'Sign Up',
              style: ThemeConfig.smallButtonTextTheme(context),
            ),
          ),
          // alternate -> go sign in screen
          Row(
            mainAxisAlignment: .center,
            children: [
              Text(
                'Already have an account?',
                style: context.textTheme.bodySmall, // feels right
              ),
              TextButton(
                onPressed: () => navToAuth(loadSignUp: false),
                // feels part of text
                style: TextButton.styleFrom(padding: .all(0)),
                child: Text(
                  'Sign In',
                  // feels right
                  style: context.textTheme.bodySmall!.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: .bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
