import 'package:flutter/material.dart';
import 'package:moodmap/extensions/theme_extension.dart';
import 'package:moodmap/onboarding/info_pages/info_pg1.dart';
import 'package:moodmap/onboarding/info_pages/info_pg2.dart';
import 'package:moodmap/onboarding/info_pages/info_pg3.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class InfoPages extends StatefulWidget {
  const InfoPages({super.key});

  @override
  State<InfoPages> createState() => _InfoPagesState();
}

class _InfoPagesState extends State<InfoPages> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          children: [InfoPg1(), InfoPg2(), InfoPg3()],
        ),
        // indicators
        SafeArea(
          child: Align(
            alignment: .bottomCenter,
            child: Padding(
              padding: const .symmetric(vertical: 32),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: WormEffect(
                  dotColor: context.colorScheme.onSurface.withValues(
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
