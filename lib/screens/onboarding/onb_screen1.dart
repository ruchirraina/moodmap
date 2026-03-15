// first onboarding screen
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodmap/theme/theme_extension.dart';

class OnbScreen1 extends StatelessWidget {
  const OnbScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // keyboard won't come up
      // better flexibility
      body: Stack(
        children: [
          Align(
            alignment: const Alignment(0, -0.30),
            // making size feel right
            child: SizedBox(
              height: 400,
              width: 400,
              // a journaling based lottie json
              child: Lottie.asset(
                (context.theme.brightness == .light)
                    // light version
                    ? 'assets/info_pages_assets/info_pg1_asset_light.json'
                    // dark version
                    : 'assets/info_pages_assets/info_pg1_asset_dark.json',
                // as large as possible while
                // still containing the source entirely within the target box
                fit: .contain,
              ),
            ),
          ),
          // bottom text
          Align(
            alignment: const Alignment(0, 0.30),
            child: Padding(
              padding: const .symmetric(horizontal: 52), // less width text
              child: Text(
                'Write about your day. Morning, afternoon, evening — any mood.',
                style: context.textTheme.bodyMedium!.copyWith(
                  fontWeight: .bold,
                ),
                textAlign: .center, // feels better
              ),
            ),
          ),
        ],
      ),
    );
  }
}
