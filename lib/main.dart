import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';

/// Global navigation key for accessing navigation context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Main entry point for the Flutter app
///
/// Initializes Firebase, checks auth state, and runs the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check if user exists in localStorage
  final commonHelper = CommonHelper();
  final user = await commonHelper.getLoggedInUser();

  // If user exists, restore auth token to API client
  if (user != null) {
    final token = await commonHelper.getAccessToken();
    if (token != null) {
      APIClient().setAuthorization(token);
    }
  }

  runApp(MyApp(user: user));
}

class MyApp extends StatelessWidget {
  final UserModel? user;

  const MyApp({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    // Determine initial route based on user existence
    // If user exists in localStorage → Home
    // If user NOT exists → Login
    final String initialRoute = user != null ? AppRoutes.home : AppRoutes.login;

    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,

      // Global navigation key
      navigatorKey: navigatorKey,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Navigation - set initial route based on auth state
      initialRoute: initialRoute,
      onGenerateRoute: (settings) {
        // Pass user data to home route if authenticated
        if (settings.name == AppRoutes.home && user != null) {
          return AppRoutes.generateRoute(
            RouteSettings(
              name: settings.name,
              arguments: {'user': user},
            ),
          );
        }
        return AppRoutes.generateRoute(settings);
      },
    );
  }
}
