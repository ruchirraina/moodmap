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

  // stores current page index
  int _currPageIndex = 0;

  // back button opacity control
  bool _backButtonOpace = true;

  // forward button opacity control
  bool _fwdButtonOpace = false;

  void _onPageChange(int index) {
    setState(() {
      _currPageIndex = index;
      _backButtonOpace = _currPageIndex == 0;
      _fwdButtonOpace = _currPageIndex == 2;
    });
  }

  // move previous page function
  void _movePrevPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  // move next page function
  void _moveNextPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: _pageController,
          onPageChanged: _onPageChange,
          children: [InfoPg1(), InfoPg2(), InfoPg3()],
        ),
        // back button
        Align(
          alignment: .centerLeft,
          child: IconButton(
            onPressed: _moveNextPage,
            icon: AnimatedOpacity(
              opacity: _backButtonOpace ? 0.5 : 1,
              duration: const Duration(milliseconds: 400),
              child: Icon(Icons.arrow_back_ios_new),
            ),
            style: IconButton.styleFrom(splashFactory: NoSplash.splashFactory),
          ),
        ),
        Align(
          alignment: .centerRight,
          child: IconButton(
            onPressed: _movePrevPage,
            icon: AnimatedOpacity(
              opacity: _fwdButtonOpace ? 0.5 : 1,
              duration: const Duration(milliseconds: 400),
              child: Icon(Icons.arrow_forward_ios),
            ),
            style: IconButton.styleFrom(splashFactory: NoSplash.splashFactory),
          ),
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
