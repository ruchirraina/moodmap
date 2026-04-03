// second onboarding screen
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodmap/theme/theme_extension.dart';

class OnbScreen2 extends StatelessWidget {
  const OnbScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // keyboard won't come up
      // better flexibility
      body: Stack(
        children: [
          Align(
            alignment: Alignment(0, -0.30),
            // restricting  the stack size containing two lotties
            child: SizedBox(
              height: 350,
              width: 350,
              // contains two lotties in stack for better flexibility in pos.
              // diagonal with appropriate space
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment(-0.40, -0.40),
                    child: Transform.scale(
                      scale: 1.75, // make it bigger
                      // a photo based lottie json
                      child: Lottie.asset(
                        'assets/onb_screen_assets/onb_asset2_1.json',
                        /* as large as possible while still containing the
                         * source entirely within the target box */
                        fit: .contain,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0.40, 0.40),
                    child: Transform.scale(
                      scale: 3.75, // make it bigger
                      // a music based lottie json
                      child: Lottie.asset(
                        'assets/onb_screen_assets/onb_asset2_2.json',
                        /* as large as possible while still containing the
                         * source entirely within the target box */
                        fit: .contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // bottom text
          Align(
            alignment: Alignment(0, 0.30),
            child: Padding(
              padding: const .symmetric(horizontal: 52), // less width text
              child: Text(
                'Add photos for the memory, a song for the vibe - all inside your entry.',
                style: context.textTheme.bodyMedium,
                textAlign: .center, // feels right
              ),
            ),
          ),
        ],
      ),
    );
  }
}
