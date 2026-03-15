// onboarding screens in PageView and cool indicators at bottom with anim
import 'package:flutter/material.dart';
import 'package:moodmap/theme/theme_extension.dart';
import 'package:moodmap/screens/onboarding/onb_screen1.dart';
import 'package:moodmap/screens/onboarding/onb_screen2.dart';
import 'package:moodmap/screens/onboarding/onb_screen3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnbScreens extends StatefulWidget {
  const OnbScreens({super.key});

  @override
  State<OnbScreens> createState() => _OnbScreensState();
}

class _OnbScreensState extends State<OnbScreens> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    // feels the sensible way to do things
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          // the three screens
          children: [
            const OnbScreen1(),
            const OnbScreen2(),
            const OnbScreen3(),
          ],
        ),
        // indicators with anim | safe area cuz gotta protect it
        SafeArea(
          child: Align(
            alignment: .bottomCenter, // feels best place
            child: Padding(
              padding: const .symmetric(vertical: 32), // also feels right
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                // the anim when page changes
                effect: WormEffect(
                  dotColor: context.colorScheme.onSurface.withValues(
                    // feels right
                    alpha: (context.theme.brightness == .light) ? 0.25 : 0.5,
                  ),
                  activeDotColor: context.colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
