// placeholder rn
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moodmap/screens/auth/auth_logic.dart';
import 'package:moodmap/theme/theme_config.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            FilledButton(
              onPressed: () {
                AuthLogic.signOutAuth();
                context.go('/auth?signup=${false}');
              },
              style: FilledButton.styleFrom(
                // consistency with get started button
                minimumSize: const Size(175, 50),
                // consistency with get started button
                shape: RoundedRectangleBorder(borderRadius: .circular(16)),
              ),
              child: Text(
                'Sign Out',
                style: ThemeConfig.smallButtonTextTheme(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
