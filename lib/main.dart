import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moodmap/theme/theme_config.dart';
import 'package:moodmap/routing/route_config.dart';

// app starts here duh
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // ensuring widget binding init
  // DeviceOrientation set to only portraitUp
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MoodMap',
      debugShowCheckedModeBanner: false, // remove the debug banner
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      routerConfig: router,
    );
  }
}
