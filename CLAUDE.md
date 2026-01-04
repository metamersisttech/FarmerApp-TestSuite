# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run                    # Default device
flutter run -d android         # Android
flutter run -d ios             # iOS (macOS only)
flutter run -d chrome          # Web

# Build for release
flutter build apk --release    # Android APK
flutter build appbundle        # Android App Bundle (Play Store)
flutter build ios --release    # iOS (macOS only)
flutter build web --release    # Web

# Code quality
flutter analyze                # Run Dart analyzer
flutter test                   # Run all tests
flutter test test/widget_test.dart  # Run single test
```

## Architecture Overview

This is a **Farmer/Livestock Trading App** built with Flutter, integrating with a Django REST backend.

### Layer Architecture

```
Screen (StatefulWidget + Mixin) → Controller (BaseController) → Feature Service → Data Service → Django API
```

**Data flow:**
1. **Screens** (`features/*/screens/`) - UI with StatefulWidget, uses Mixins for UI state
2. **Controllers** (`features/*/controllers/`) - Business logic, extends `BaseController` for loading/error handling
3. **Feature Services** (`features/*/services/`) - Feature-specific operations, return Result objects (e.g., `OtpResult`, `ProfileResult`)
4. **Data Services** (`data/services/`) - HTTP layer using Dio, handles auth tokens, converts errors to typed exceptions
5. **Models** (`data/models/`) - Data classes with `fromJson()`/`toJson()` matching Django serializers

### Key Patterns

**BaseController** (`lib/core/base/base_controller.dart`):
- All feature controllers extend this
- Provides `isLoading`, `errorMessage`, `setLoading()`, `setError()`, `executeAsync()`
- Extends `ChangeNotifier` for reactivity

**State Mixins** (`features/*/mixins/`):
- Widget-level UI state (form state, validation, UI flags)
- Example: `AuthStateMixin` provides `formKey`, `isLoading`, `validateForm()`

**Result Pattern**:
- Services return Result objects with `success`, `data`, `errorMessage`
- Enables explicit error handling without exceptions at UI layer

**API Error Handling** (`lib/data/services/api_service.dart`):
- Converts Dio errors to typed exceptions (`BadRequestException`, `UnauthorizedException`, etc.)
- Extracts Django error messages from various formats (`message`, `detail`, `error`, field-level errors)

### Configuration

**API Config** (`lib/config/api_config.dart`):
- `devBaseUrl`: `http://10.0.2.2:8000/api/` (Android emulator)
- `devBaseUrlIOS`: `http://localhost:8000/api/` (iOS simulator)
- Set `isProduction = true` for production builds

**Endpoints** (`lib/core/constants/api_endpoints.dart`):
- Centralized endpoint definitions
- Usage: `ApiEndpoints.login`, `ApiEndpoints.userProfile`

### Feature Structure

Each feature follows this structure:
```
features/{feature}/
├── controllers/    # Business logic (extends BaseController)
├── mixins/         # UI state mixins
├── models/         # Feature-specific data models
├── screens/        # UI pages
├── services/       # Feature API operations
└── widgets/        # Feature-specific widgets
```

### Navigation

- Global routes in `lib/routes/app_routes.dart`
- Feature-specific navigation services (e.g., `AuthNavigationService`)
- Uses `NavigationResult` for success/failure feedback

### Token Storage

- Uses `flutter_secure_storage` for JWT tokens
- `TokenStorageService` (`lib/data/services/token_storage_service.dart`) handles save/retrieve/clear
- Auth token auto-injected via Dio interceptor in `ApiService`

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `dio` | HTTP client for Django API |
| `flutter_secure_storage` | Secure JWT token storage |
| `provider` | State management |
| `geolocator` | Location services |
| `permission_handler` | Runtime permissions |
| `firebase_core` | Firebase integration |
