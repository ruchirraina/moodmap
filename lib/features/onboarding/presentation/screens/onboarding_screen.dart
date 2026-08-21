import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_routes.dart';
import '../../domain/models/onboarding_slide.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const int pageCount = 3;
  static const double dotSize = 10.0;
  static const double dotSpacing = 16.0;
  static const double bottomPadding = 48.0;
  static const double horizontalPadding = 24.0;
  static const double buttonHeight = 56.0;
  static const double buttonWidth = 240.0;
  static const double animationHeight = 300.0;
  static const double spacingLarge = 32.0;
  static const double spacingSmall = 16.0;

  static const double slide1Scale = 1.125;
  static const double slide2Scale = 3.5;
  static const double slide3Scale = 1.0;

  static const String slide1Title = 'Welcome to MoodMap';
  static const String slide1Body =
      'A daily journal for however your day went. Morning thoughts, evening feelings — all welcome.';
  static const String slide2Title = 'Attach a Song';
  static const String slide2Body =
      'Add a track to any entry — the soundtrack to your day, saved right alongside it.';
  static const String slide3Title = 'AI Mood Mapping';
  static const String slide3Body =
      'Your entries become poetic summaries and bloom into a gradient — rose, marigold, wisteria.';

  static const String signUpButtonText = 'Sign Up';
  static const String existingAccountText = 'Already have an account?';
  static const String signInButtonText = 'Sign In';

  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      animationPath: AppAssets.onboarding1,
      title: slide1Title,
      body: slide1Body,
      scale: slide1Scale,
    ),
    OnboardingSlide(
      animationPath: AppAssets.onboarding2,
      title: slide2Title,
      body: slide2Body,
      scale: slide2Scale,
    ),
    OnboardingSlide(
      animationPath: AppAssets.onboarding3,
      title: slide3Title,
      body: slide3Body,
      scale: slide3Scale,
    ),
  ];

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: OnboardingScreen.pageCount,
                itemBuilder: (context, index) {
                  final slide = OnboardingScreen.slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OnboardingScreen.horizontalPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: OnboardingScreen.animationHeight,
                          child: Transform.scale(
                            scale: slide.scale,
                            child: Lottie.asset(
                              slide.animationPath,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        const SizedBox(height: OnboardingScreen.spacingLarge),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: OnboardingScreen.spacingSmall),
                        Text(
                          slide.body,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                        if (index == 2) ...[
                          const SizedBox(height: OnboardingScreen.spacingLarge),
                          SizedBox(
                            width: OnboardingScreen.buttonWidth,
                            height: OnboardingScreen.buttonHeight,
                            child: FilledButton(
                              onPressed: () {
                                context.go(AppRoutes.signUpPath);
                              },
                              child: const Text(
                                OnboardingScreen.signUpButtonText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: OnboardingScreen.spacingSmall),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                OnboardingScreen.existingAccountText,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  context.go(AppRoutes.signInPath);
                                },
                                child: const Text(
                                  OnboardingScreen.signInButtonText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: OnboardingScreen.horizontalPadding,
                right: OnboardingScreen.horizontalPadding,
                bottom: OnboardingScreen.bottomPadding,
              ),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: OnboardingScreen.pageCount,
                effect: ExpandingDotsEffect(
                  dotHeight: OnboardingScreen.dotSize,
                  dotWidth: OnboardingScreen.dotSize,
                  spacing: OnboardingScreen.dotSpacing,
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
