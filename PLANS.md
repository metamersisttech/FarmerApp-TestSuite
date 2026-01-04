# PLANS.md

Documentation for screen flows, API structure, and folder organization for the Farmer/Livestock Trading App.

---

## Table of Contents

1. [Screen Flow Diagrams](#screen-flow-diagrams)
2. [Helper Classes](#helper-classes)
3. [API Calling Structure](#api-calling-structure)
4. [Folder Structure](#folder-structure)
5. [Feature Documentation](#feature-documentation)
6. [Reusable Components](#reusable-components)

---

## Screen Flow Diagrams

### Main App Navigation Flow

```
                                    ┌─────────────────┐
                                    │   App Launch    │
                                    │   (main.dart)   │
                                    └────────┬────────┘
                                             │
                              ┌──────────────┴──────────────┐
                              │  Check CommonHelper         │
                              │  getLoggedInUser()          │
                              └──────────────┬──────────────┘
                                             │
                    ┌────────────────────────┼────────────────────────┐
                    │                                                 │
            [User EXISTS]                                    [User NOT EXISTS]
                    │                                                 │
                    ▼                                                 ▼
           ┌─────────────────┐                               ┌─────────────────┐
           │    HomePage     │                               │  SendOtpPage    │
           │  (with user)    │                               │   Route: /      │
           └─────────────────┘                               └────────┬────────┘
                                                                      │
                                     ┌────────────────────────────────┼────────────────┐
                                     │                                │                │
                            [User Not Found]                  [OTP Sent OK]    [Sign Up Link]
                                     │                                │                │
                                     ▼                                ▼                ▼
                            ┌─────────────────┐              ┌─────────────────┐ ┌───────────┐
                            │ Show Toast      │              │ OtpVerification │ │RegisterPage│
                            │ Stay on Screen  │              │      Page       │ └─────┬─────┘
                            └─────────────────┘              └────────┬────────┘       │
                                                                      │        [Register OK]
                                                              [Verify Success]         │
                                                                      │                │
                                                             ┌────────┴────────────────┘
                                                             │  Store user in
                                                             │  CommonHelper
                                                             └────────┬────────┘
                                                                      │
                                                                      ▼
                                                             ┌─────────────────┐
                                                             │    HomePage     │
                                                             │  Route: /home   │
                                                             └────────┬────────┘
                                                                      │
                                     ┌────────────────────────────────┼────────────────────────┐
                                     │                                │                        │
                                     ▼                                ▼                        ▼
                            ┌─────────────────┐              ┌─────────────────┐      ┌─────────────────┐
                            │  ProfilePage    │              │ PostAnimalPage  │      │   (Coming Soon) │
                            │ Route: /profile │              │   (Sell Tab)    │      │ Chat, MyAds,    │
                            └─────────────────┘              └─────────────────┘      │ Saved, Wallet   │
                                                                                      └─────────────────┘
```

### Authentication Flow Detail

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AUTHENTICATION FLOW                                │
└─────────────────────────────────────────────────────────────────────────────┘

1. APP LAUNCH (main.dart):
   ┌──────────────┐     ┌──────────────────┐     ┌───────────────────┐
   │ App Starts   │ ──► │ CommonHelper     │ ──► │ User exists?      │
   │              │     │ getLoggedInUser()│     │                   │
   └──────────────┘     └──────────────────┘     └─────────┬─────────┘
                                                           │
                              ┌─────────────────────────────┼──────────────────┐
                              │ YES                                            │ NO
                              ▼                                                ▼
                    ┌──────────────────┐                           ┌──────────────────┐
                    │ Set APIClient    │                           │ Go to Login      │
                    │ auth token       │                           │ (SendOtpPage)    │
                    │ Go to HomePage   │                           │                  │
                    └──────────────────┘                           └──────────────────┘

2. EXISTING USER LOGIN:
   ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
   │ SendOtpPage  │ ──► │   Send OTP   │ ──► │ OtpVerify    │ ──► │ HomePage │
   │ Enter Phone  │     │   API Call   │     │ Enter 6-digit│     │          │
   └──────────────┘     └──────────────┘     └──────────────┘     └──────────┘
         │                    │                    │
         │              API: POST                 API: POST
         │          auth/send-login-otp/        auth/login/
         │              ▼                          ▼
         │         {phone: "..."}            {phone, otp}
         │                                        │
         │                             ┌──────────┴──────────┐
         │                             │ CommonHelper        │
         │                             │ saveAuthData()      │
         │                             │ APIClient.setAuth() │
         │                             └─────────────────────┘

3. USER NOT FOUND (404):
   ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
   │ SendOtpPage  │ ──► │   Send OTP   │ ──► │ Show Toast   │
   │ Enter Phone  │     │   API: 404   │     │ STAY on page │
   └──────────────┘     └──────────────┘     └──────────────┘
                                               (No auto-redirect to register)

4. NEW USER REGISTRATION:
   ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────┐
   │ SendOtpPage  │ ──► │ RegisterPage │ ──► │ SendOtpPage  │ ──► │ OtpVerify│
   │ [Sign Up]    │     │ Fill Form    │     │              │     │          │
   └──────────────┘     └──────────────┘     └──────────────┘     └────┬─────┘
                              │                                        │
                        API: POST                               [Verify Success]
                       auth/register/                                  │
                             ▼                                         ▼
                    {username, email, phone,                  ┌──────────────┐
                     password, first_name, last_name}         │ HomePage     │
                                                              │ (Direct)     │
                                                              └──────────────┘

5. TOKEN EXPIRY (401 Error):
   ┌──────────────┐     ┌──────────────────────┐     ┌──────────────┐
   │ Any API Call │ ──► │ APIClient intercepts │ ──► │ SendOtpPage  │
   │              │     │ 401 → Clear user     │     │ Re-login     │
   │              │     │ CommonHelper.clear() │     │              │
   └──────────────┘     └──────────────────────┘     └──────────────┘
```

### Bottom Navigation Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         BOTTOM NAVIGATION BAR                                │
│                                                                              │
│    ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐          │
│    │  Home  │   │  Chat  │   │  Sell  │   │ My Ads │   │ Saved  │          │
│    │  (0)   │   │  (1)   │   │  (2)   │   │  (3)   │   │  (4)   │          │
│    └───┬────┘   └───┬────┘   └───┬────┘   └───┬────┘   └───┬────┘          │
│        │            │            │            │            │                │
│        ▼            ▼            ▼            ▼            ▼                │
│   ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐          │
│   │HomePage│   │Coming  │   │PostAnim│   │Coming  │   │Coming  │          │
│   │        │   │ Soon   │   │alPage  │   │ Soon   │   │ Soon   │          │
│   └────────┘   └────────┘   └────────┘   └────────┘   └────────┘          │
│                                 │                                          │
│                    ┌────────────┴────────────┐                             │
│                    │    5-Step Multi-Form    │                             │
│                    │                         │                             │
│                    │ 1. Details              │                             │
│                    │ 2. Health               │                             │
│                    │ 3. Location             │                             │
│                    │ 4. Media                │                             │
│                    │ 5. Preview → Publish    │                             │
│                    └─────────────────────────┘                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Profile Page Navigation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           PROFILE PAGE                                       │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────┐
│  ProfilePage                                                                  │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Profile Header Card (Name, Avatar, Stats, Rating)                    │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  KYC Status Card                                                      │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Menu Items:                                                          │   │
│  │  ├── My Listings ────────► (Coming Soon)                              │   │
│  │  ├── Saved Items ────────► (Coming Soon)                              │   │
│  │  ├── My Bookings ────────► (Coming Soon)                              │   │
│  │  ├── Wallet ─────────────► (Coming Soon)                              │   │
│  │  ├── Reviews ────────────► (Coming Soon)                              │   │
│  │  ├── Notifications ──────► (Coming Soon)                              │   │
│  │  ├── Language ───────────► (Coming Soon)                              │   │
│  │  ├── Privacy ────────────► (Coming Soon)                              │   │
│  │  └── Help ───────────────► (Coming Soon)                              │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────────────────────┐   │
│  │  Logout Button ──────────► WelcomePage (Clear tokens, remove stack)   │   │
│  └──────────────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Helper Classes

### Overview

The app uses three main helper classes for API communication and user management:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           HELPER CLASSES                                     │
└─────────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  api_config.dart │     │  api_helper.dart │     │ common_helper.dart│
│  (Configuration) │     │  (HTTP Client)   │     │ (User Storage)   │
└────────┬─────────┘     └────────┬─────────┘     └────────┬─────────┘
         │                        │                        │
         │                        ▼                        │
         │               ┌──────────────────┐              │
         └──────────────►│ backend_helper   │◄─────────────┘
                         │ (API Methods)    │
                         └──────────────────┘
```

### 1. api_config.dart (`lib/config/api_config.dart`)

API configuration and base URLs:

```dart
class ApiConfig {
  static const String devBaseUrl = 'http://34.28.110.191/api/';
  static const String devBaseUrlIOS = 'http://localhost:8000/api/';
  static const String prodBaseUrl = 'https://your-backend-domain.com/api/';

  static const bool isProduction = false;
  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;

  static const int connectionTimeout = 30000;  // 30 seconds
  static const int receiveTimeout = 30000;     // 30 seconds
}
```

### 2. api_helper.dart (`lib/core/helpers/api_helper.dart`)

Singleton HTTP client with Dio:

```dart
class APIClient {
  static final APIClient _instance = APIClient._internal();
  factory APIClient() => _instance;

  // HTTP Methods
  Future<Response> get(String url, {Map<String, dynamic>? params});
  Future<Response> post(String url, {dynamic data});
  Future<Response> put(String url, {dynamic data});
  Future<Response> patch(String url, {dynamic data});
  Future<Response> delete(String url, {dynamic data});

  // Auth Management
  void setAuthorization(String token);
  void clearAuthorization();
  String? get authToken;

  // Features:
  // - Auto-injects Bearer token to all requests
  // - Handles 401 errors (clears user, redirects to login)
  // - Request/Response logging in debug mode
}
```

### 3. common_helper.dart (`lib/core/helpers/common_helper.dart`)

User data management with flutter_secure_storage:

```dart
class CommonHelper {
  // User Management
  Future<UserModel?> getLoggedInUser();
  Future<void> setLoggedInUser(UserModel user);
  Future<void> clearUser();
  Future<bool> isAuthenticated();

  // Token Management
  Future<void> setTokens({required String accessToken, String? refreshToken});
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  // Combined Save (used after login)
  Future<void> saveAuthData({
    required UserModel user,
    required String accessToken,
    String? refreshToken,
  });
}
```

### 4. backend_helper.dart (`lib/core/helpers/backend_helper.dart`)

API endpoint methods:

```dart
class BackendHelper {
  // Auth Endpoints
  Future<Map<String, dynamic>> postSendLoginOtp(Map<String, dynamic> data);
  Future<Map<String, dynamic>> postVerifyLoginOtp(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getMe();
  Future<void> postLogout(Map<String, dynamic> data);
  Future<Map<String, dynamic>> postRefreshToken(Map<String, dynamic> data);

  // User Endpoints
  Future<Map<String, dynamic>> getUserProfile();
  Future<Map<String, dynamic>> putUpdateProfile(Map<String, dynamic> data);

  // Animal Endpoints
  Future<dynamic> getAnimals({Map<String, dynamic>? params});

  // Listing Endpoints
  Future<dynamic> getListings({Map<String, dynamic>? params});
}

// Error Handling
class BackendException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  bool get isUserNotFound => statusCode == 404;
  bool get isUnauthorized => statusCode == 401;
  bool get isBadRequest => statusCode == 400;
}
```

### Usage Example

```dart
// In a controller or service:
final backendHelper = BackendHelper();

// Fetch listings
try {
  final response = await backendHelper.getListings();
  // Handle response
} on BackendException catch (e) {
  if (e.isUnauthorized) {
    // 401 is auto-handled by APIClient, but you can add extra logic
  }
  showError(e.message);
}

// Check user on app launch (main.dart):
final commonHelper = CommonHelper();
final user = await commonHelper.getLoggedInUser();
if (user != null) {
  final token = await commonHelper.getAccessToken();
  APIClient().setAuthorization(token!);
  // Go to HomePage
} else {
  // Go to LoginPage
}
```

---

## API Calling Structure

### Layer Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              LAYER ARCHITECTURE                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────┐
│  LAYER 1: SCREEN (UI)                                                      │
│  Location: lib/features/*/screens/                                         │
│  Uses: StatefulWidget + Mixin (AuthStateMixin, HomeStateMixin, etc.)       │
│  Example: sendOtp_page.dart, home_page.dart                                │
└─────────────────────────────────┬─────────────────────────────────────────┘
                                  │ Calls
                                  ▼
┌───────────────────────────────────────────────────────────────────────────┐
│  LAYER 2: CONTROLLER                                                       │
│  Location: lib/features/*/controllers/                                     │
│  Extends: BaseController (provides isLoading, errorMessage, setLoading)    │
│  Example: otp_controller.dart, profile_controller.dart                     │
└─────────────────────────────────┬─────────────────────────────────────────┘
                                  │ Calls
                                  ▼
┌───────────────────────────────────────────────────────────────────────────┐
│  LAYER 3: FEATURE SERVICE                                                  │
│  Location: lib/features/*/services/                                        │
│  Returns: Result Objects (OtpResult, ProfileResult, PublishResult)         │
│  Example: otp_handler_service.dart, profile_service.dart                   │
└─────────────────────────────────┬─────────────────────────────────────────┘
                                  │ Calls
                                  ▼
┌───────────────────────────────────────────────────────────────────────────┐
│  LAYER 4: DATA SERVICE                                                     │
│  Location: lib/data/services/                                              │
│  - auth_service.dart (login, register, OTP, logout)                        │
│  - api_service.dart (Dio HTTP client)                                      │
│  - token_storage_service.dart (flutter_secure_storage)                     │
│  - location_service.dart (Geolocator)                                      │
└─────────────────────────────────┬─────────────────────────────────────────┘
                                  │ HTTP Request (Dio)
                                  ▼
┌───────────────────────────────────────────────────────────────────────────┐
│  LAYER 5: DJANGO BACKEND                                                   │
│  Base URL: http://10.0.2.2:8000/api/ (Android)                             │
│            http://localhost:8000/api/ (iOS)                                │
│  Returns: JSON → Parsed into Models (lib/data/models/)                     │
└───────────────────────────────────────────────────────────────────────────┘
```

### API Endpoints Reference

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            API ENDPOINTS                                     │
│                     (lib/core/constants/api_endpoints.dart)                  │
└─────────────────────────────────────────────────────────────────────────────┘

AUTHENTICATION:
┌──────────────────────────┬────────┬─────────────────────────────────────────┐
│ Endpoint                 │ Method │ Description                             │
├──────────────────────────┼────────┼─────────────────────────────────────────┤
│ auth/login/              │ POST   │ Login with email/password OR phone+OTP  │
│ auth/register/           │ POST   │ Register new user                       │
│ auth/logout/             │ POST   │ Logout (sends refresh token)            │
│ auth/send-login-otp/     │ POST   │ Send OTP to phone (existing users)      │
│ auth/otp/send/           │ POST   │ Send OTP (general)                      │
│ auth/otp/verify/         │ POST   │ Verify OTP                              │
│ auth/me/                 │ GET    │ Get current authenticated user          │
│ auth/token/refresh/      │ POST   │ Refresh access token                    │
│ auth/password/reset/     │ POST   │ Request password reset                  │
└──────────────────────────┴────────┴─────────────────────────────────────────┘

USER:
┌──────────────────────────┬────────┬─────────────────────────────────────────┐
│ Endpoint                 │ Method │ Description                             │
├──────────────────────────┼────────┼─────────────────────────────────────────┤
│ users/profile/           │ GET    │ Get user profile                        │
│ users/profile/update/    │ PUT    │ Update profile                          │
│ users/delete/            │ DELETE │ Delete account                          │
│ users/{id}/              │ GET    │ Get user by ID                          │
└──────────────────────────┴────────┴─────────────────────────────────────────┘

ANIMALS:
┌──────────────────────────┬────────┬─────────────────────────────────────────┐
│ Endpoint                 │ Method │ Description                             │
├──────────────────────────┼────────┼─────────────────────────────────────────┤
│ animals/                 │ GET    │ Get all animals catalog                 │
└──────────────────────────┴────────┴─────────────────────────────────────────┘

PLANNED (TODO):
┌──────────────────────────┬────────┬─────────────────────────────────────────┐
│ listings/                │ POST   │ Create animal listing                   │
│ listings/draft/          │ POST   │ Save draft listing                      │
│ media/upload/            │ POST   │ Upload media files                      │
└──────────────────────────┴────────┴─────────────────────────────────────────┘
```

### API Call Example Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    EXAMPLE: SEND OTP API CALL                                │
└─────────────────────────────────────────────────────────────────────────────┘

1. USER ACTION: Tap "Get OTP" button on SendOtpPage

2. SCREEN (sendOtp_page.dart:42-76):
   ┌────────────────────────────────────────────────────────────────────────┐
   │  Future<void> _handleSendOtp() async {                                 │
   │    if (!validateForm()) return;                                        │
   │    final phone = _phoneController.text.trim();                         │
   │    final result = await _otpController.sendOtp(phone);  ◄── CALL       │
   │    ...                                                                 │
   │  }                                                                     │
   └────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
3. CONTROLLER (otp_controller.dart:13-25):
   ┌────────────────────────────────────────────────────────────────────────┐
   │  Future<OtpResult> sendOtp(String phoneNumber) async {                 │
   │    setLoading(true);                                                   │
   │    clearError();                                                       │
   │    final result = await _otpService.sendOtp(phoneNumber);  ◄── CALL    │
   │    setLoading(false);                                                  │
   │    return result;                                                      │
   │  }                                                                     │
   └────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
4. FEATURE SERVICE (otp_handler_service.dart:48-70):
   ┌────────────────────────────────────────────────────────────────────────┐
   │  Future<OtpResult> sendOtp(String phoneNumber) async {                 │
   │    try {                                                               │
   │      final response = await _authService.sendLoginOtp(phone);  ◄──     │
   │      return OtpResult.success(otp: response['otp']);                   │
   │    } on NotFoundException {                                            │
   │      return OtpResult.userNotFound();                                  │
   │    } on ApiException catch (e) {                                       │
   │      return OtpResult.error(e.message);                                │
   │    }                                                                   │
   │  }                                                                     │
   └────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
5. DATA SERVICE (auth_service.dart:74-84):
   ┌────────────────────────────────────────────────────────────────────────┐
   │  Future<Map<String, dynamic>> sendLoginOtp({required String phone}) {  │
   │    final response = await _apiService.post(                            │
   │      ApiEndpoints.sendLoginOtp,    // 'auth/send-login-otp/'           │
   │      data: { 'phone': phone },                                         │
   │    );                                                                  │
   │    return response.data;                                               │
   │  }                                                                     │
   └────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
6. API SERVICE (api_service.dart:79-89):
   ┌────────────────────────────────────────────────────────────────────────┐
   │  Future<Response> post(String endpoint, {dynamic data}) async {        │
   │    return await _dio.post(endpoint, data: data);                       │
   │    // POST http://10.0.2.2:8000/api/auth/send-login-otp/               │
   │    // Headers: { Authorization: Bearer <token>, Content-Type: json }   │
   │    // Body: { "phone": "7406996114" }                                  │
   │  }                                                                     │
   └────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
7. DJANGO RESPONSE:
   ┌────────────────────────────────────────────────────────────────────────┐
   │  SUCCESS (200):                                                        │
   │  { "message": "OTP sent", "otp": "123456", "user_id": 1 }              │
   │                                                                        │
   │  USER NOT FOUND (404):                                                 │
   │  { "detail": "User not found" }                                        │
   └────────────────────────────────────────────────────────────────────────┘
```

### Token Management

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          TOKEN MANAGEMENT                                    │
└─────────────────────────────────────────────────────────────────────────────┘

STORAGE: flutter_secure_storage (encrypted)
SERVICE: lib/data/services/token_storage_service.dart

┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│   1. LOGIN SUCCESS                                                          │
│      ┌──────────────┐                                                       │
│      │ API Response │ ──► { access: "...", refresh: "...", user: {...} }    │
│      └──────┬───────┘                                                       │
│             │                                                               │
│             ▼                                                               │
│      ┌──────────────────────┐                                               │
│      │ TokenStorageService  │                                               │
│      │ saveTokens(access,   │ ──► Secure Storage (encrypted)                │
│      │            refresh)  │                                               │
│      └──────────────────────┘                                               │
│                                                                             │
│   2. API REQUEST                                                            │
│      ┌──────────────────┐                                                   │
│      │ ApiService       │                                                   │
│      │ _authToken       │ ──► Header: Authorization: Bearer <access_token>  │
│      │ (Dio Interceptor)│                                                   │
│      └──────────────────┘                                                   │
│                                                                             │
│   3. 401 UNAUTHORIZED                                                       │
│      ┌──────────────────┐     ┌─────────────────┐                           │
│      │ ApiService       │ ──► │ Clear Tokens    │ ──► Navigate to SendOTP   │
│      │ _handle401Error()│     │ Clear AuthToken │                           │
│      └──────────────────┘     └─────────────────┘                           │
│                                                                             │
│   4. LOGOUT                                                                 │
│      ┌──────────────────┐                                                   │
│      │ POST auth/logout │ ──► { refresh: "..." } ──► Clear all tokens       │
│      └──────────────────┘                                                   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Folder Structure

### Complete Project Structure

```
lib/
├── main.dart                          # App entry point, Firebase init, MaterialApp
│
├── config/                            # Configuration
│   ├── api_config.dart                # Base URLs (dev/prod), timeouts
│   └── app_config.dart                # App constants, token keys
│
├── core/                              # Core utilities (shared across app)
│   ├── base/
│   │   └── base_controller.dart       # Abstract controller with loading/error state
│   ├── constants/
│   │   └── api_endpoints.dart         # All Django API endpoint paths
│   ├── errors/
│   │   └── exceptions.dart            # Custom exceptions (BadRequest, Unauthorized, etc.)
│   ├── helpers/                       # Helper classes for API and storage
│   │   ├── api_helper.dart            # Singleton Dio HTTP client (APIClient)
│   │   ├── backend_helper.dart        # API endpoint methods wrapper
│   │   └── common_helper.dart         # User/token storage with flutter_secure_storage
│   ├── mixins/
│   │   └── toast_mixin.dart           # Toast notification mixin
│   └── utils/
│       └── validators.dart            # Form validators (email, phone, password)
│
├── data/                              # Data layer
│   ├── models/
│   │   ├── listing_model.dart         # ListingModel for animal listings
│   │   └── user_model.dart            # UserModel, AuthResponse
│   ├── repositories/
│   │   └── auth_repository.dart       # Auth business logic (combines services)
│   └── services/
│       ├── api_service.dart           # Dio HTTP client, interceptors, error handling
│       ├── auth_service.dart          # Auth API calls (login, register, OTP)
│       ├── token_storage_service.dart # Secure token storage
│       └── location_service.dart      # GPS and permissions
│
├── features/                          # Feature modules (feature-first architecture)
│   │
│   ├── auth/                          # Authentication feature
│   │   ├── controllers/
│   │   │   ├── otp_controller.dart
│   │   │   └── register_controller.dart
│   │   ├── mixins/
│   │   │   └── auth_state_mixin.dart
│   │   ├── screens/
│   │   │   ├── sendOtp_page.dart      # Phone entry screen
│   │   │   ├── otp_verification_page.dart
│   │   │   └── register_page.dart
│   │   ├── services/
│   │   │   ├── auth_navigation_service.dart
│   │   │   └── otp_handler_service.dart
│   │   └── widgets/
│   │       ├── phone_input_form.dart
│   │       ├── otp_input_widget.dart
│   │       ├── auth_footer_link.dart
│   │       └── social_login_section.dart
│   │
│   ├── home/                          # Home feature
│   │   ├── controllers/
│   │   │   └── home_controller.dart
│   │   ├── mixins/
│   │   │   └── home_state_mixin.dart
│   │   ├── screens/
│   │   │   └── home_page.dart
│   │   ├── services/
│   │   │   └── home_navigation_service.dart
│   │   └── widgets/
│   │       ├── custom_bottom_nav_bar.dart
│   │       ├── home_search_bar.dart
│   │       ├── profile_section.dart
│   │       ├── quick_actions_section.dart
│   │       ├── recent_listing_section.dart
│   │       └── scrolling_templates.dart
│   │
│   ├── profile/                       # Profile feature
│   │   ├── controllers/
│   │   │   └── profile_controller.dart
│   │   ├── mixins/
│   │   │   └── profile_state_mixin.dart
│   │   ├── models/
│   │   │   └── profile_model.dart
│   │   ├── screens/
│   │   │   └── profile_page.dart
│   │   ├── services/
│   │   │   └── profile_service.dart
│   │   └── widgets/
│   │       ├── kyc_status_card.dart
│   │       ├── logout_button.dart
│   │       ├── profile_header_card.dart
│   │       ├── profile_menu_item.dart
│   │       └── profile_menu_list.dart
│   │
│   ├── sell/                          # Sell/Post Animal feature
│   │   ├── controllers/
│   │   │   └── post_animal_controller.dart
│   │   ├── mixins/
│   │   │   └── post_animal_state_mixin.dart
│   │   ├── screens/
│   │   │   └── post_animal_page.dart
│   │   ├── services/
│   │   │   └── sell_service.dart
│   │   └── widgets/
│   │       ├── details_tab.dart
│   │       ├── health_tab.dart
│   │       ├── location_tab.dart
│   │       ├── media_tab.dart
│   │       ├── preview_tab.dart
│   │       └── step_indicator.dart
│   │
│   ├── language/                      # Language selection feature
│   │   ├── controllers/
│   │   │   └── language_controller.dart
│   │   ├── mixins/
│   │   │   └── language_state_mixin.dart
│   │   ├── models/
│   │   │   └── language_model.dart
│   │   ├── screens/
│   │   │   └── choose_language_page.dart
│   │   ├── services/
│   │   │   └── language_navigation_service.dart
│   │   └── widgets/
│   │       ├── language_card.dart
│   │       └── language_list.dart
│   │
│   ├── useridentity/                  # User identity/role selection
│   │   ├── controllers/
│   │   │   └── user_identity_controller.dart
│   │   ├── mixins/
│   │   │   └── user_identity_state_mixin.dart
│   │   ├── models/
│   │   │   └── user_identity_model.dart
│   │   ├── screens/
│   │   │   └── choose_identity_page.dart
│   │   ├── services/
│   │   │   └── user_identity_service.dart
│   │   └── widgets/
│   │       ├── user_identity_card.dart
│   │       └── user_identity_list.dart
│   │
│   └── welcome/                       # Welcome/landing feature
│       └── screens/
│           └── welcome_page.dart
│
├── shared/                            # Shared components
│   ├── themes/
│   │   └── app_theme.dart             # Colors, typography, theme config
│   └── widgets/
│       ├── auth/
│       │   ├── auth_divider.dart
│       │   ├── auth_header_icon.dart
│       │   ├── auth_primary_button.dart
│       │   ├── auth_social_button.dart
│       │   └── phone_number_field.dart
│       ├── cards/
│       │   ├── listing_card.dart      # Reusable animal listing card
│       │   └── selection_card.dart
│       ├── common/
│       │   ├── icon_badge.dart
│       │   ├── page_header.dart
│       │   ├── selection_indicator.dart
│       │   └── title_subtitle.dart
│       ├── custom_button/
│       │   └── custom_button.dart
│       ├── feedback/
│       │   └── message_box.dart
│       └── forms/
│           └── text_field.dart
│
└── routes/
    └── app_routes.dart                # Centralized navigation config
```

### Feature Module Template

```
features/{feature_name}/
├── controllers/
│   └── {feature}_controller.dart      # Extends BaseController
├── mixins/
│   └── {feature}_state_mixin.dart     # Widget-level state
├── models/
│   └── {feature}_model.dart           # Feature-specific models
├── screens/
│   └── {feature}_page.dart            # Main UI screen
├── services/
│   ├── {feature}_service.dart         # API operations
│   └── {feature}_navigation_service.dart  # Navigation helpers
└── widgets/
    └── {feature}_widget.dart          # Feature-specific widgets
```

---

## Feature Documentation

### Result Pattern

All services return Result objects for explicit error handling:

```dart
class OtpResult {
  final bool success;
  final String? otp;
  final String? userId;
  final String? errorMessage;
  final bool isUserNotFound;
  final UserModel? user;
}

class ProfileResult {
  final bool success;
  final String? message;
  final ProfileModel? profile;
}

class PublishResult {
  final bool success;
  final String? message;
  final String? listingId;
}

class NavigationResult {
  final bool success;
  final String? message;
}
```

### Navigation Services

Each feature has a navigation service for type-safe navigation:

| Service | Location | Methods |
|---------|----------|---------|
| `AuthNavigationService` | `features/auth/services/` | `toRegister()`, `toOtpVerification()`, `toSendOtp()`, `toHome()`, `toLanguageSelection()` |
| `HomeNavigationService` | `features/home/services/` | `toChat()`, `toSell()`, `toMyAds()`, `toSaved()`, `toNotifications()`, `toProfile()`, `toWallet()` |
| `LanguageNavigationService` | `features/language/services/` | `toUserIdentity()` |

### State Management

Hybrid approach:
1. **BaseController** (ChangeNotifier) - Business logic, loading/error states
2. **State Mixins** - Widget-level UI state
3. **Result Objects** - Explicit success/failure handling

### Coming Soon Features

Features marked as "Coming Soon" in HomeNavigationService:
- Chat
- My Ads
- Saved listings
- Notifications
- Wallet

---

## Quick Reference

### Add New Feature Checklist

1. Create folder: `lib/features/{feature}/`
2. Add controller extending `BaseController`
3. Add state mixin for UI state
4. Add screen using mixin
5. Add service for API calls (return Result objects)
6. Add navigation service
7. Add widgets
8. Register route in `app_routes.dart` (if needed)

### Add New API Endpoint Checklist

1. Add endpoint constant in `lib/core/constants/api_endpoints.dart`
2. Add method in appropriate data service (`auth_service.dart`, etc.)
3. Add wrapper method in feature service
4. Add method in controller
5. Call from screen

---

## Reusable Components

### ListingCard

**Location:** `lib/shared/widgets/cards/listing_card.dart`

**Purpose:** Displays an animal listing with image, name, age, price, location, rating, and verified status.

**Visual Structure:**
```
┌──────────────────────────────────────────┐
│ ┌────────┐  Name              [Verified] │
│ │  IMG   │  Age                          │
│ │ 96x96  │  ₹Price (bold, green)         │
│ │        │  📍 Location  ★ 4.8           │
│ └────────┘                               │
└──────────────────────────────────────────┘
```

**Props/Parameters:**
```dart
class ListingCard extends StatelessWidget {
  final String? imageUrl;    // Animal image URL (nullable, shows placeholder if null)
  final String name;         // Animal name/title
  final String age;          // Age string (e.g., "2 Years")
  final String price;        // Formatted price (e.g., "₹25,000")
  final String location;     // Location text
  final double rating;       // Rating value (0.0 - 5.0)
  final bool isVerified;     // Shows verified badge if true
  final VoidCallback? onTap; // Tap callback
}
```

**Usage Example:**
```dart
ListingCard(
  imageUrl: listing.imageUrl,
  name: listing.name,
  age: listing.age,
  price: listing.price,
  location: listing.location,
  rating: listing.rating,
  isVerified: listing.isVerified,
  onTap: () => _handleListingTap(listing),
)
```

**Styling:**
| Element | Value |
|---------|-------|
| Card background | `Colors.white` |
| Card border radius | `16.0` |
| Card shadow | `BoxShadow(blurRadius: 8, color: black.withOpacity(0.08))` |
| Card border | `Border.all(color: Colors.grey.shade200)` |
| Image size | `96 x 96` |
| Image radius | `12.0` |
| Name text | `16px bold, AppTheme.authTextPrimary` |
| Age text | `14px, Colors.grey.shade600` |
| Price text | `18px bold, AppTheme.authPrimaryColor` |
| Location text | `14px, Colors.grey.shade500` |
| Verified badge | Green pill with "Verified" text |
| Star color | `Colors.amber` |

---

### ListingModel

**Location:** `lib/data/models/listing_model.dart`

**Purpose:** Data model for animal listings from the API.

**Fields:**
```dart
class ListingModel {
  final int id;
  final String name;
  final String? imageUrl;
  final String age;
  final String price;
  final String location;
  final double rating;
  final bool isVerified;
}
```

**JSON Parsing:**
- `price`: Converts number to formatted string with ₹ symbol
- `age`: Converts number to "X Years" string
- `imageUrl`: Checks both `image_url` and `image` keys
- `isVerified`: Checks both `is_verified` and `verified` keys

**API Endpoint:** `GET /api/listing/`
