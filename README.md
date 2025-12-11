# Flutter App

A Flutter mobile application with Django backend integration support.

## Project Structure

```
lib/
├── main.dart                          # App entry point
│
├── config/                            # Configuration
│   ├── api_config.dart                # Django API base URLs (dev/prod)
│   └── app_config.dart                # App settings, token keys
│
├── core/                              # Core utilities
│   ├── constants/
│   │   └── api_endpoints.dart         # All Django API endpoint paths
│   ├── errors/
│   │   └── exceptions.dart            # Custom API exceptions
│   └── utils/
│       └── validators.dart            # Email, phone, password validation
│
├── data/                              # Data layer
│   ├── models/
│   │   └── user_model.dart            # User model (matches Django serializer)
│   ├── repositories/
│   │   └── auth_repository.dart       # Auth business logic
│   └── services/
│       ├── api_service.dart           # HTTP client setup
│       └── auth_service.dart          # Auth API calls
│
├── features/                          # Feature modules
│   ├── auth/
│   │   ├── screens/
│   │   │   ├── login_page.dart        # Email login screen
│   │   │   └── phone_login_page.dart  # Phone OTP login screen
│   │   └── widgets/
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_page.dart         # Home screen
│   │   └── widgets/
│   └── welcome/
│       └── screens/
│           └── welcome_page.dart      # Welcome/landing screen
│
├── shared/                            # Shared components
│   ├── themes/
│   │   └── app_theme.dart             # Colors, typography, styles
│   └── widgets/
│       └── custom_button.dart         # Reusable button component
│
└── routes/
    └── app_routes.dart                # Navigation configuration
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `dio` | ^5.4.0 | HTTP client for Django API calls |
| `http` | ^1.2.0 | Alternative HTTP client |
| `flutter_secure_storage` | ^9.2.0 | Secure storage for JWT tokens |
| `provider` | ^6.1.0 | State management |
| `firebase_core` | ^4.2.1 | Firebase integration |

## Requirements

### Flutter SDK
- **Version:** ^3.10.1 or higher
- **Installation:** https://flutter.dev/docs/get-started/install

### Development Tools
- Android Studio or VS Code with Flutter extension
- Xcode (for iOS development on macOS)
- Android SDK (for Android development)

## Getting Started

### 1. Install Flutter SDK

```bash
# Verify installation
flutter doctor
```

### 2. Clone the repository

```bash
git clone <repository-url>
cd flutter_app
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Configure API endpoint

Edit `lib/config/api_config.dart` and update with your Django server URL:

```dart
// Development
static const String devBaseUrl = 'http://10.0.2.2:8000/api/';  // Android Emulator
static const String devBaseUrlIOS = 'http://localhost:8000/api/';  // iOS Simulator

// Production
static const String prodBaseUrl = 'https://your-production-server.com/api/';
```

### 5. Run the app

```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

## Django Backend Integration

This app is designed to work with a Django REST API backend.

### Expected API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/auth/login/` | POST | User login |
| `/api/auth/register/` | POST | User registration |
| `/api/auth/logout/` | POST | User logout |
| `/api/auth/otp/send/` | POST | Send OTP to phone |
| `/api/auth/otp/verify/` | POST | Verify OTP code |
| `/api/users/profile/` | GET | Get user profile |

### Data Flow

```
Flutter App                          Django Backend
─────────────────────────────────────────────────────
features/screens/
       │
       ▼
data/repositories/
       │
       ▼
data/services/  ──── HTTP ────►  Django REST API
       │                              │
       ▼                              ▼
data/models/   ◄──── JSON ────  Serializers
```

## Build Commands

```bash
# Build APK (Android)
flutter build apk --release

# Build App Bundle (Android - for Play Store)
flutter build appbundle --release

# Build iOS (requires macOS)
flutter build ios --release

# Build Web
flutter build web --release
```

## Project Architecture

This project follows a **feature-first** architecture with clean separation of concerns:

- **config/** - Environment and app configuration
- **core/** - Shared utilities, constants, and error handling
- **data/** - Data layer (models, services, repositories)
- **features/** - UI screens organized by feature
- **shared/** - Reusable widgets and themes
- **routes/** - Navigation management

## License

This project is private and not licensed for public use.
