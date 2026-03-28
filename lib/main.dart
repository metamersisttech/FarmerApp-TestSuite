import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/api_helper.dart';
import 'package:flutter_app/core/helpers/common_helper.dart';
import 'package:flutter_app/core/services/api_logger.dart';
import 'package:flutter_app/data/models/user_model.dart';
import 'package:flutter_app/routes/app_routes.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/core/cache/cache_manager.dart';
import 'package:flutter_app/core/services/firebase_cache_sync_service.dart';
import 'package:flutter_app/core/services/fcm_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Theme Notifier ───────────────────────────────────────────────────────────

/// Manages theme mode preference with SharedPreferences persistence.
/// Key: 'theme_mode', values: 'light', 'dark', 'system'.
class ThemeNotifier extends ChangeNotifier {
  static const _key = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key) ?? 'light';
    _themeMode = _fromString(value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _toString(mode));
  }

  void toggleTheme() {
    // Cycles: light -> dark -> system -> light
    switch (_themeMode) {
      case ThemeMode.light:
        setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        setThemeMode(ThemeMode.light);
        break;
    }
  }

  static ThemeMode _fromString(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
      case ThemeMode.light:
        return 'light';
    }
  }
}

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

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  print('✅ Firebase initialized');

  // Initialize API logger for file-based logging
  await ApiLogger.initialize();
  print('✅ API logger initialized');

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

  // Initialize FCM service (but don't handle initial message yet)
  await FCMService().initialize();
  print('✅ FCM service initialized');

  // If user is already logged in, register/refresh FCM token
  if (user != null) {
    final token = await commonHelper.getAccessToken();
    if (token != null) {
      FCMService().registerToken(); // fire-and-forget
    }
  }

  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en'),
          Locale('hi'),
          Locale('mr'),
          Locale('pa'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: MyApp(user: user, appMode: appMode),
      ),
    ),
  );
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

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) => MaterialApp(
        title: 'Flutter App',
        debugShowCheckedModeBanner: false,

        // Localization
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        // Global navigation key
        navigatorKey: navigatorKey,

        // Route observer for page visibility detection
        navigatorObservers: [routeObserver],

        // Theme configuration
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeNotifier.themeMode,

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
      ),
    );
  }
}
