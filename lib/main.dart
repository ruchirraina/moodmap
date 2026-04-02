import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moodmap/firebase_options.dart';
import 'package:moodmap/screens/auth/auth_state.dart';
import 'package:moodmap/theme/theme_config.dart';
import 'package:moodmap/routing/route_config.dart';

// app starts here duh
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ensuring widget binding init
  // DeviceOrientation set to only portraitUp
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // initialise firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // init SharedPreferences
  await AuthState.initSharedPreferences();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // pre-cache the Google logo
    // prevent UI thread pause on first Auth screen load
    precacheImage(const AssetImage('assets/auth_google/google.png'), context);

    return MaterialApp.router(
      title: 'MoodMap',
      debugShowCheckedModeBanner: false, // remove the debug banner
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      routerConfig: router,
    );
  }
}
