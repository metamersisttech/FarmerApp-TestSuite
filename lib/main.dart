import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/core/cache/cache_manager.dart';
import 'package:flutter_app/core/services/firebase_cache_sync_service.dart';

/// Global navigation key for accessing navigation context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Global route observer for detecting page visibility changes
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// Create global instance for dependency injection
final FirebaseCacheSyncService firebaseSync = FirebaseCacheSyncService();

/// Main entry point for the Flutter app
///
/// Initializes Firebase, cache system, and checks auth state.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  print('✅ Firebase initialized');
  
  // Initialize cache manager (Hive) - must be before app runs
  await CacheManager().initialize();
  print('✅ Cache manager initialized');
  
  // Initialize Firebase cache sync service (realtime listeners)
  firebaseSync.initialize();
  print('✅ Firebase sync initialized');

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

  // Check stored app mode for vet dashboard routing
  final appMode = user != null ? await commonHelper.getAppMode() : 'farmer';

  runApp(MyApp(user: user, appMode: appMode));
}

class MyApp extends StatelessWidget {
  final UserModel? user;
  final String appMode;

  const MyApp({super.key, this.user, this.appMode = 'farmer'});

  @override
  Widget build(BuildContext context) {
    // Determine initial route based on user existence and app mode
    String initialRoute;
    if (user == null) {
      initialRoute = AppRoutes.login;
    } else if (appMode == 'vet') {
      initialRoute = AppRoutes.vetHome;
    } else {
      initialRoute = AppRoutes.home;
    }

    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,

      // Global navigation key
      navigatorKey: navigatorKey,
      
      // Route observer for page visibility detection
      navigatorObservers: [routeObserver],

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
