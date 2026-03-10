import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodmap/extensions/theme_extension.dart';

class InfoPg1 extends StatelessWidget {
  const InfoPg1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: .center,
        children: [
          Lottie.asset(
            (context.theme.brightness == .light)
                ? 'assets/info_pages_assets/info_pg1_asset_light.json'
                : 'assets/info_pages_assets/info_pg1_asset_dark.json',
            fit: .contain,
          ),
          Padding(
            padding: const .symmetric(horizontal: 32),
            child: Text(
              'Morning thoughts, afternoon chaos, evening quiet. It all goes here.',
              style: context.textTheme.bodyMedium!.copyWith(fontWeight: .bold),
              textAlign: .center,
            ),
          ),
        ],
      ),
    );
  }
}
