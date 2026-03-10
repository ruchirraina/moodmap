import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodmap/extensions/theme_extension.dart';

class InfoPg2 extends StatelessWidget {
  const InfoPg2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: .center,
        children: [
          SizedBox(
            height: 360,
            width: 360,
            child: Stack(
              children: [
                Transform.scale(
                  scale: 1.75,
                  child: Align(
                    alignment: Alignment(-0.1, -0.15),
                    child: Lottie.asset(
                      (context.theme.brightness == .light)
                          ? 'assets/info_pages_assets/info_pg2_asset1_light.json'
                          : 'assets/info_pages_assets/info_pg2_asset1_dark.json',
                      fit: .contain,
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 3.5,
                  child: Align(
                    alignment: Alignment(0.1, 0.15),
                    child: Lottie.asset(
                      (context.theme.brightness == .light)
                          ? 'assets/info_pages_assets/info_pg2_asset2_light.json'
                          : 'assets/info_pages_assets/info_pg2_asset2_dark.json',
                      fit: .contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const .symmetric(horizontal: 32),
            child: Text(
              'Attach a song. Drop in a photo. The little things matter.',
              style: context.textTheme.bodyMedium!.copyWith(fontWeight: .bold),
              textAlign: .center,
            ),
          ),
        ],
      ),
    );
  }
}
