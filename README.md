# Flutter App

A Flutter mobile application with Django backend integration support.

## Project Structure

```
lib/
├── main.dart                              # App entry point
│
├── config/                                # Configuration
│   ├── api_config.dart                    # Django API base URLs (dev/prod)
│   └── app_config.dart                    # App settings, token keys
│
├── core/                                  # Core utilities
│   ├── base/
│   │   └── base_controller.dart           # Base controller with loading/error state
│   ├── constants/
│   │   └── api_endpoints.dart             # All Django API endpoint paths
│   ├── errors/
│   │   └── exceptions.dart                # Custom API exceptions
│   ├── mixins/
│   │   └── toast_mixin.dart               # Toast notification mixin
│   └── utils/
│       └── validators.dart                # Email, phone, password validation
│
├── data/                                  # Data layer
│   ├── models/
│   │   └── user_model.dart                # User model (matches Django serializer)
│   ├── repositories/
│   │   └── auth_repository.dart           # Auth business logic
│   └── services/
│       ├── api_service.dart               # HTTP client setup
│       └── auth_service.dart              # Auth API calls
│
├── features/                              # Feature modules (feature-first architecture)
│   │
│   ├── auth/                              # Authentication feature
│   │   ├── controllers/
│   │   │   ├── otp_controller.dart        # OTP operations controller
│   │   │   └── register_controller.dart   # Registration controller
│   │   ├── mixins/
│   │   │   └── auth_state_mixin.dart      # Auth state management mixin
│   │   ├── screens/
│   │   │   ├── otp_verification_page.dart # OTP verification screen
│   │   │   ├── register_page.dart         # Registration screen
│   │   │   └── sendOtp_page.dart          # Phone OTP login screen
│   │   ├── services/
│   │   │   ├── auth_navigation_service.dart # Auth navigation helpers
│   │   │   └── otp_handler_service.dart   # OTP operations service
│   │   └── widgets/
│   │       ├── auth_footer_link.dart      # Footer link widget
│   │       ├── otp_input_widget.dart      # OTP input field
│   │       ├── phone_input_form.dart      # Phone input form
│   │       └── social_login_section.dart  # Social login buttons
│   │
│   ├── home/                              # Home feature
│   │   ├── controllers/
│   │   │   └── home_controller.dart       # Home screen controller
│   │   ├── mixins/
│   │   │   └── home_state_mixin.dart      # Home state management mixin
│   │   ├── screens/
│   │   │   └── home_page.dart             # Home screen
│   │   ├── services/
│   │   │   └── home_navigation_service.dart # Home navigation helpers
│   │   └── widgets/
│   │       ├── custom_bottom_nav_bar.dart # Bottom navigation bar
│   │       ├── home_search_bar.dart       # Search bar widget
│   │       ├── profile_section.dart       # Profile section widget
│   │       ├── quick_actions_section.dart # Quick actions widget
│   │       ├── recent_listing_section.dart # Recent listings widget
│   │       └── scrolling_templates.dart   # Scrolling templates
│   │
│   ├── language/                          # Language selection feature
│   │   ├── controllers/
│   │   │   └── language_controller.dart   # Language selection controller
│   │   ├── mixins/
│   │   │   └── language_state_mixin.dart  # Language state mixin
│   │   ├── models/
│   │   │   └── language_model.dart        # Language model
│   │   ├── screens/
│   │   │   └── choose_language_page.dart  # Language selection screen
│   │   ├── services/
│   │   │   └── language_navigation_service.dart # Language navigation
│   │   └── widgets/
│   │       ├── language_card.dart         # Language card widget
│   │       └── language_list.dart         # Language list widget
│   │
│   ├── sell/                              # Sell/Post animal feature
│   │   ├── controllers/
│   │   │   └── post_animal_controller.dart # Post animal controller
│   │   ├── mixins/
│   │   │   └── post_animal_state_mixin.dart # Post animal state mixin
│   │   ├── screens/
│   │   │   └── post_animal_page.dart      # Multi-step post animal screen
│   │   ├── services/
│   │   │   └── sell_service.dart          # Sell operations service
│   │   └── widgets/
│   │       ├── details_tab.dart           # Animal details tab
│   │       ├── health_tab.dart            # Health info tab
│   │       ├── location_tab.dart          # Location tab
│   │       ├── media_tab.dart             # Media upload tab
│   │       ├── preview_tab.dart           # Preview tab
│   │       └── step_indicator.dart        # Step indicator widget
│   │
│   ├── useridentity/                      # User identity/role feature
│   │   ├── controllers/
│   │   │   └── user_identity_controller.dart # Identity selection controller
│   │   ├── mixins/
│   │   │   └── user_identity_state_mixin.dart # Identity state mixin
│   │   ├── models/
│   │   │   └── user_identity_model.dart   # User identity model
│   │   ├── screens/
│   │   │   └── choose_identity_page.dart  # Identity selection screen
│   │   ├── services/
│   │   │   └── user_identity_service.dart # Identity operations service
│   │   └── widgets/
│   │       ├── user_identity_card.dart    # Identity card widget
│   │       └── user_identity_list.dart    # Identity list widget
│   │
│   └── welcome/                           # Welcome feature
│       └── screens/
│           └── welcome_page.dart          # Welcome/landing screen
│
├── shared/                                # Shared components
│   ├── themes/
│   │   └── app_theme.dart                 # Colors, typography, styles
│   └── widgets/
│       └── custom_button.dart             # Reusable button component
│
└── routes/
    └── app_routes.dart                    # Navigation configuration
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
Flutter App                                      Django Backend
───────────────────────────────────────────────────────────────────

  ┌─────────────────────────────────────┐
  │         features/screens/           │  ◄── UI Layer (Pages)
  │    (with StateMixin for UI state)   │
  └──────────────────┬──────────────────┘
                     │ user actions
                     ▼
  ┌─────────────────────────────────────┐
  │       features/controllers/         │  ◄── Business Logic
  │    (extends BaseController)         │
  └──────────────────┬──────────────────┘
                     │ calls
                     ▼
  ┌─────────────────────────────────────┐
  │        features/services/           │  ◄── Feature Services
  │   (OtpHandlerService, SellService)  │
  └──────────────────┬──────────────────┘
                     │ calls
                     ▼
  ┌─────────────────────────────────────┐
  │          data/services/             │  ◄── API Layer
  │   (ApiService, AuthService)         │
  └──────────────────┬──────────────────┘
                     │
                     │ HTTP Request
                     ▼
           ┌─────────────────┐
           │  Django REST    │
           │      API        │
           └────────┬────────┘
                    │
                    │ JSON Response
                    ▼
  ┌─────────────────────────────────────┐
  │           data/models/              │  ◄── Data Models
  │   (UserModel, AuthResponse)         │
  └─────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Location | Responsibility |
|-------|----------|----------------|
| **UI** | `features/*/screens/` | Display data, handle user input |
| **State Mixin** | `features/*/mixins/` | Manage widget-level UI state |
| **Controller** | `features/*/controllers/` | Business logic, loading/error states |
| **Feature Service** | `features/*/services/` | Feature-specific API operations |
| **Data Service** | `data/services/` | HTTP client, API calls |
| **Model** | `data/models/` | Data structures, JSON parsing |

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
- **core/** - Shared utilities, constants, base classes, and error handling
- **data/** - Data layer (models, services, repositories)
- **features/** - Feature modules, each with its own:
  - `controllers/` - Business logic and state management (extends BaseController)
  - `mixins/` - State management mixins for widgets
  - `models/` - Feature-specific data models
  - `screens/` - UI screens/pages
  - `services/` - Feature-specific API services
  - `widgets/` - Feature-specific reusable widgets
- **shared/** - Reusable widgets and themes across features
- **routes/** - Navigation management

## License

This project is private and not licensed for public use.
