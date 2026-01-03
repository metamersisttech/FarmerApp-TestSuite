import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/features/welcome/screens/welcome_page.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Global navigation key for accessing navigation context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Main entry point for the Flutter app
///
/// Initializes Firebase and runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,

      // Global navigation key
      navigatorKey: navigatorKey,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Navigation
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRoutes.generateRoute,

      // Fallback home (not used when onGenerateRoute is set)
      home: const WelcomePage(),
    );
  }
}
