# Home Feature - Refactored Clean Architecture

## Overview
The home feature has been refactored to follow **Clean Architecture** principles with proper separation of concerns.

---

## Architecture Layers

```
┌─────────────────────────────────────────┐
│           UI Layer (Screen)             │
│         home_page.dart                  │
│   - Only build() methods                │
│   - Widget composition                  │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Mixin Layer (UI Logic)          │
│  HomeStateMixin + LocationMixin         │
│   - setState() calls                    │
│   - Navigation                          │
│   - UI coordination                     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│    Controller Layer (Business Logic)    │
│         HomeController                  │
│   - State management                    │
│   - Business rules                      │
│   - notifyListeners()                   │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│      Service Layer (Data)               │
│          HomeService                    │
│   - Data fetching                       │
│   - Data transformation                 │
│   - Response parsing                    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Backend Layer (API)             │
│        BackendHelper                    │
│   - HTTP requests                       │
│   - Error handling                      │
└─────────────────────────────────────────┘
```

---

## Files Structure

```
lib/features/home/
├── screens/
│   └── home_page.dart              # UI only (200 lines vs 583 lines before)
├── mixins/
│   ├── home_state_mixin.dart       # Business logic coordination
│   └── location_mixin.dart         # Location functionality
├── controllers/
│   └── home_controller.dart        # State management (uses HomeService)
├── services/
│   ├── home_service.dart           # Data operations (NEW!)
│   └── home_navigation_service.dart
└── widgets/
    └── ... (unchanged)
```

---

## Layer Responsibilities

### 1. **Screen (home_page.dart)**
**Purpose:** UI rendering only

```dart
class _HomePageState extends State<HomePage>
    with ToastMixin, HomeStateMixin, LocationMixin {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(), // Only UI
    );
  }
  
  Widget _buildProfileWithSearch() { ... }
  Widget _buildScrollingTemplates() { ... }
}
```

**Responsibilities:**
- ✅ Build UI widgets
- ✅ Compose layout
- ❌ NO business logic
- ❌ NO API calls
- ❌ NO navigation logic

---

### 2. **Mixins (UI Logic Layer)**

#### HomeStateMixin
**Purpose:** Coordinate between UI and controller

```dart
mixin HomeStateMixin<T extends StatefulWidget> on State<T> {
  late HomeController homeController;
  
  Future<void> fetchListings() async {
    await homeController.fetchListings();
    setState(() {});
    // Show error if any
  }
  
  void handleProfileTap() {
    HomeNavigationService.toProfile(context);
  }
}
```

**Responsibilities:**
- ✅ Initialize controller
- ✅ Call controller methods
- ✅ Handle navigation (has context)
- ✅ Show toasts/dialogs
- ✅ setState() for UI updates
- ❌ NO data fetching
- ❌ NO API calls

#### LocationMixin
**Purpose:** Handle location-specific logic

```dart
mixin LocationMixin<T extends StatefulWidget> on State<T> {
  Future<void> checkLocationPermission() { ... }
  Future<void> fetchAndDisplayCurrentLocation() { ... }
  void showLocationOffDialog() { ... }
}
```

**Responsibilities:**
- ✅ Location permissions
- ✅ Location dialogs
- ✅ GPS functionality
- ✅ setState() for location updates

---

### 3. **Controller (Business Logic)**

```dart
class HomeController extends BaseController {
  final HomeService _homeService;
  
  List<ListingModel> _listings = [];
  
  Future<void> fetchListings() async {
    setLoading(true);
    
    _listings = await _homeService.fetchListings();
    
    notifyListeners();
    setLoading(false);
  }
}
```

**Responsibilities:**
- ✅ Manage state (_listings, _isLoading, _error)
- ✅ Business logic
- ✅ Call service methods
- ✅ notifyListeners() to update UI
- ❌ NO UI code (no context, no setState)
- ❌ NO direct API calls (uses service)

---

### 4. **Service (Data Layer) - NEW!**

```dart
class HomeService {
  final BackendHelper _backendHelper;
  
  Future<List<ListingModel>> fetchListings() async {
    final response = await _backendHelper.getListings();
    
    // Parse different response formats
    List<dynamic> rawListings = [];
    if (response is List) {
      rawListings = response;
    } else if (response is Map && response['results'] != null) {
      rawListings = response['results'];
    }
    
    // Transform to models
    return rawListings
        .map((json) => ListingModel.fromJson(json))
        .toList();
  }
}
```

**Responsibilities:**
- ✅ Fetch data from API
- ✅ Parse responses
- ✅ Transform to models
- ✅ Handle different response formats
- ❌ NO state management
- ❌ NO UI updates

---

### 5. **BackendHelper (HTTP Layer)**

```dart
class BackendHelper {
  Future<dynamic> getListings({Map<String, dynamic>? params}) async {
    final response = await _client.get(ApiEndpoints.listings, params: params);
    return response.data;
  }
}
```

**Responsibilities:**
- ✅ HTTP requests
- ✅ Error handling
- ✅ Token management
- ❌ NO data transformation
- ❌ NO business logic

---

## Key Improvements

### Before Refactoring ❌
```dart
class _HomePageState {
  // 583 lines of mixed UI and logic
  
  Future<void> _fetchListings() async {
    // API call directly
    final response = await _backendHelper.getListings();
    // Parse response
    // Handle errors
    setState(() { ... });
  }
  
  Future<void> _checkLocationPermission() async { ... }
  Future<void> _loadUserFromStorage() async { ... }
  void _handleProfileTap() async { ... }
  // ... 15+ more methods
}
```

**Problems:**
- ❌ 583 lines - too long
- ❌ Mixed UI and business logic
- ❌ Hard to test
- ❌ Not reusable
- ❌ Controller knows about HTTP

### After Refactoring ✅
```dart
class _HomePageState with HomeStateMixin, LocationMixin {
  // ~200 lines of pure UI
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }
}

mixin HomeStateMixin {
  // Business logic coordination
}

mixin LocationMixin {
  // Location logic
}

class HomeController {
  // State management
}

class HomeService {
  // Data operations
}
```

**Benefits:**
- ✅ Clean separation of concerns
- ✅ Each file < 200 lines
- ✅ Easy to test
- ✅ Reusable components
- ✅ Controller independent of HTTP

---

## Testing Strategy

### Controller Testing (Easy)
```dart
test('fetchListings updates state', () async {
  final mockService = MockHomeService();
  when(mockService.fetchListings()).thenReturn([...]);
  
  final controller = HomeController(homeService: mockService);
  await controller.fetchListings();
  
  expect(controller.listings.length, 5);
});
```

### Service Testing (Easy)
```dart
test('fetchListings parses response', () async {
  final mockBackend = MockBackendHelper();
  when(mockBackend.getListings()).thenReturn({'results': [...]});
  
  final service = HomeService(backendHelper: mockBackend);
  final listings = await service.fetchListings();
  
  expect(listings.length, 5);
});
```

### Mixin Testing (Harder - needs widget)
```dart
testWidgets('handleProfileTap navigates', (tester) async {
  await tester.pumpWidget(TestWidget());
  // Test navigation
});
```

---

## setState() vs notifyListeners()

### setState() - Mixin (Local State)
```dart
mixin HomeStateMixin {
  int _selectedTab = 0; // Local to widget
  
  void selectTab(int index) {
    setState(() => _selectedTab = index);
    // Only this widget rebuilds
  }
}
```

**Use For:**
- Selected tab
- Expanded/collapsed sections
- UI-only state

### notifyListeners() - Controller (Global State)
```dart
class HomeController {
  List<ListingModel> _listings = []; // Shared across app
  
  Future<void> fetchListings() async {
    _listings = await _homeService.fetchListings();
    notifyListeners(); // All listening widgets rebuild
  }
}
```

**Use For:**
- API data
- Shared state
- Business data

---

## Migration Guide

### For New Features
Follow this structure:
1. Create `*_service.dart` in services/
2. Create `*_controller.dart` in controllers/
3. Create `*_mixin.dart` in mixins/ (if needed)
4. Create `*_page.dart` in screens/ (UI only)

### For Existing Features
Refactor in this order:
1. Extract API calls → Service
2. Update Controller to use Service
3. Move UI logic → Mixin
4. Clean up Screen to be UI-only

---

## Summary

| Layer | Purpose | Has Context | Can setState | Can Navigate |
|-------|---------|-------------|--------------|--------------|
| **Screen** | UI rendering | ✅ | ✅ | ✅ |
| **Mixin** | UI coordination | ✅ | ✅ | ✅ |
| **Controller** | Business logic | ❌ | ❌ | ❌ |
| **Service** | Data operations | ❌ | ❌ | ❌ |
| **BackendHelper** | HTTP requests | ❌ | ❌ | ❌ |

**Golden Rule:**
- **Screen** = What user sees
- **Mixin** = What user does
- **Controller** = What happens
- **Service** = Where data comes from
- **BackendHelper** = How data is fetched

---

## Related Documentation
- [BaseController](../../core/base/base_controller.dart)
- [ToastMixin](../../core/mixins/toast_mixin.dart)
- [BackendHelper](../../core/helpers/backend_helper.dart)
