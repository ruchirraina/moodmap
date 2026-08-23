import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_routes.dart';
import '../../domain/models/onboarding_slide.dart';
import '../../constants/onboarding_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      animationPath: AppAssets.onboarding1,
      title: OnboardingConstants.slide1Title,
      body: OnboardingConstants.slide1Body,
      scale: OnboardingConstants.slide1Scale,
    ),
    OnboardingSlide(
      animationPath: AppAssets.onboarding2,
      title: OnboardingConstants.slide2Title,
      body: OnboardingConstants.slide2Body,
      scale: OnboardingConstants.slide2Scale,
    ),
    OnboardingSlide(
      animationPath: AppAssets.onboarding3,
      title: OnboardingConstants.slide3Title,
      body: OnboardingConstants.slide3Body,
      scale: OnboardingConstants.slide3Scale,
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
                itemCount: OnboardingConstants.pageCount,
                itemBuilder: (context, index) {
                  final slide = OnboardingScreen.slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: OnboardingConstants.horizontalPadding,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: OnboardingConstants.animationHeight,
                          child: Transform.scale(
                            scale: slide.scale,
                            child: Lottie.asset(
                              slide.animationPath,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: OnboardingConstants.spacingLarge,
                        ),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(
                          height: OnboardingConstants.spacingSmall,
                        ),
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
                          const SizedBox(
                            height: OnboardingConstants.spacingLarge,
                          ),
                          SizedBox(
                            width: OnboardingConstants.buttonWidth,
                            height: OnboardingConstants.buttonHeight,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondary,
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onSecondary,
                              ),
                              onPressed: () {
                                context.go(AppRoutes.signUpPath);
                              },
                              child: const Text(
                                OnboardingConstants.signUpButtonText,
                                style: TextStyle(
                                  fontSize: OnboardingConstants.buttonTextSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: OnboardingConstants.spacingSmall,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                OnboardingConstants.existingAccountText,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                ),
                                onPressed: () {
                                  context.go(AppRoutes.signInPath);
                                },
                                child: const Text(
                                  OnboardingConstants.signInButtonText,
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
                left: OnboardingConstants.horizontalPadding,
                right: OnboardingConstants.horizontalPadding,
                bottom: OnboardingConstants.bottomPadding,
              ),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: OnboardingConstants.pageCount,
                effect: ExpandingDotsEffect(
                  dotHeight: OnboardingConstants.dotSize,
                  dotWidth: OnboardingConstants.dotSize,
                  spacing: OnboardingConstants.dotSpacing,
                  activeDotColor: Theme.of(context).colorScheme.tertiary,
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
