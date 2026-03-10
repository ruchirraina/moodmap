import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:moodmap/extensions/theme_extension.dart';
import 'package:moodmap/configs/theme_config.dart';
import 'package:pretty_animated_buttons/widgets/pretty_wave_button.dart';

class InfoPg3 extends StatelessWidget {
  const InfoPg3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: .center,
        children: [
          Lottie.asset(
            (context.theme.brightness == .light)
                ? 'assets/info_pages_assets/info_pg3_asset_light.json'
                : 'assets/info_pages_assets/info_pg3_asset_dark.json',
            fit: .contain,
          ),
          Padding(
            padding: const .symmetric(vertical: 20, horizontal: 32),
            child: Text(
              'Your week in rose, marigold, and wisteria.',
              style: context.textTheme.bodyMedium!.copyWith(fontWeight: .bold),
              textAlign: .center,
            ),
          ),
          const SizedBox(height: 32),
          PrettyWaveButton(
            onPressed: () {},
            backgroundColor: context.colorScheme.primary,
            borderRadius: 20,
            child: Text(
              'Sign Up',
              style: ThemeConfig.smallButtonTextTheme(context),
            ),
          ),
          Row(
            mainAxisAlignment: .center,
            children: [
              Text('Already a user?', style: context.textTheme.bodySmall),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: .all(0)),
                child: Text(
                  'Sign In',
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
