# View All Listings Feature (Marketplace)

## Overview
The View All Listings feature displays all marketplace listings in a grid view. This feature is accessed when users tap the "Marketplace" quick action on the home screen.

## Architecture
Follows clean architecture pattern:

```
viewalllistings/
├── controllers/
│   └── viewalllistings_controller.dart    # Business logic & state management
├── services/
│   └── viewalllistings_service.dart       # Data fetching (currently hardcoded)
├── mixins/
│   └── viewalllistings_state_mixin.dart   # State management helpers
├── screens/
│   └── viewalllistings_page.dart          # Main UI screen
└── widgets/
    ├── listing_card.dart                   # Individual listing card
    ├── sort_filter_bar.dart                # Sort & filter controls
    └── sort_bottom_sheet.dart              # Sort options bottom sheet
```

## Features

### Current Implementation
- ✅ Grid view of livestock listings (2 columns)
- ✅ Search functionality
- ✅ Sort options (Relevance, Price: Low to High, Price: High to Low, Newest First)
- ✅ Pull-to-refresh
- ✅ Hardcoded sample data (8 listings)
- ✅ Navigation to animal detail page
- ✅ Verified badge display
- ✅ Rating display
- ✅ Image loading with placeholders
- ✅ Loading and error states

### Planned Features
- ⏳ Filter by category, price range, location
- ⏳ Favorite/Save listings
- ⏳ API integration (replace hardcoded data)
- ⏳ Pagination for large datasets
- ⏳ Advanced filters (age, breed, etc.)

## Usage

### Navigation
From HomePage:
```dart
HomeNavigationService.toMarketplace(context);
```

Direct navigation:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ViewAllListingsPage()),
);
```

### Controller Methods
```dart
// Fetch all listings
await controller.fetchListings();

// Search listings
await controller.searchListings('cow');

// Filter listings
await controller.filterListings(
  category: 'cow',
  minPrice: 50000,
  maxPrice: 100000,
);

// Change sort order
controller.setSortBy('price_low'); // or 'price_high', 'newest', 'relevance'

// Refresh
await controller.refreshListings();
```

## Data Flow

1. **User Action** → Tap "Marketplace" quick action
2. **Navigation** → `HomeNavigationService.toMarketplace()`
3. **Screen Load** → `ViewAllListingsPage` initialized
4. **Data Fetch** → `ViewAllListingsController.fetchListings()`
5. **Service Call** → `ViewAllListingsService.fetchListings()` (currently returns hardcoded data)
6. **UI Update** → Grid displays listings

## Hardcoded Data

Currently uses 8 sample livestock listings:
- Cow
- Murrah Buffalo
- Sahiwal Cow
- Tharparkar Cow
- Gir Cow
- Jersey Cow
- Holstein Friesian
- Red Sindhi

Each listing includes:
- Title
- Image URL (from Unsplash)
- Age (in months)
- Price (in INR)
- Location
- Rating (0-5)
- Verified status

## API Integration (TODO)

Replace hardcoded data with API calls:

```dart
// In viewalllistings_service.dart
Future<List<ListingModel>> fetchListings({Map<String, dynamic>? params}) async {
  final backendHelper = BackendHelper();
  final response = await backendHelper.getListings(params: params);
  
  List<dynamic> rawListings = [];
  if (response is List) {
    rawListings = response;
  } else if (response is Map && response['results'] != null) {
    rawListings = response['results'] as List;
  }

  return rawListings
      .map((item) => ListingModel.fromJson(item as Map<String, dynamic>))
      .toList();
}
```

Endpoint: `ApiEndpoints.listings` (`listings/`)

## UI Components

### ListingCard
- Displays individual listing in grid
- Shows image, title, age, price, location, rating
- Verified badge for verified sellers
- Favorite button (tap action placeholder)

### SortFilterBar
- Shows listing count
- Sort button with current sort option
- Filter button (opens filter sheet - not implemented yet)

### SortBottomSheet
- Bottom sheet with sort options
- Visual indication of selected option
- Closes on selection

## Testing

### Manual Testing
1. Run app and navigate to home screen
2. Tap "Marketplace" quick action
3. Verify grid displays 8 listings
4. Test search functionality
5. Test sort options
6. Test pull-to-refresh
7. Tap listing card → verify navigation to detail page

### Test Cases
- [ ] Initial load displays all listings
- [ ] Search filters listings correctly
- [ ] Sort by price (low to high) works
- [ ] Sort by price (high to low) works
- [ ] Sort by newest works
- [ ] Pull-to-refresh reloads data
- [ ] Error state displays correctly
- [ ] Empty state displays when no results
- [ ] Tap on listing navigates to detail page

## Dependencies
- `flutter_app/core/base/base_controller.dart` - Base controller
- `flutter_app/data/models/listing_model.dart` - Listing data model
- `flutter_app/features/home/services/home_navigation_service.dart` - Navigation
- `flutter_app/shared/themes/app_theme.dart` - App theming

## Notes
- Follows same architecture as home feature
- Service layer ready for API integration
- UI matches marketplace design patterns
- Grid uses 2 columns with 0.75 aspect ratio
- Images load from external URLs (Unsplash)
