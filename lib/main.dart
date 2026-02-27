import 'package:flutter/material.dart';
import 'package:moodmap/configs/theme_config.dart';
import 'package:moodmap/intro/intro_splash.dart';

void main() => runApp(const MainApp());

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      home: IntroSplash(),
    );
  }
}
