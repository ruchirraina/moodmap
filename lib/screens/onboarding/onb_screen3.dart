// third onboarding screen | also has buttons to go to auth screen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:moodmap/theme/theme_extension.dart';
import 'package:moodmap/theme/theme_config.dart';

class OnbScreen3 extends StatefulWidget {
  const OnbScreen3({super.key});

  @override
  State<OnbScreen3> createState() => _OnbScreen3State();
}

class _OnbScreen3State extends State<OnbScreen3> {
  @override
  Widget build(BuildContext context) {
    // function handling to auth nav
    // auth screen loads sign up or sign in page and default is sign up screen
    void navToAuth({bool loadSignUp = true}) async {
      // a boom in your face type anim nav
      // router go bc ux wise why option to return?
      if (context.mounted) {
        context.go('/auth?signup=$loadSignUp', extra: 'scale_anim');
      }
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
