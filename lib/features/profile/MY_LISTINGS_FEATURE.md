# My Listings Feature

## Overview
The My Listings feature allows users to view and manage all their posted animal listings from their profile page. The implementation follows the same architecture as the Recent Listings feature.

## Files Created

### 1. Service Layer
**`lib/features/profile/services/my_listings_service.dart`**
- Handles API calls for fetching user's listings
- Methods:
  - `fetchMyListings({String? status})` - Fetch user's listings, optionally filtered by status
  - `deleteListing(int listingId)` - Delete a listing (TODO: backend implementation needed)
  - `markAsSold(int listingId)` - Mark a listing as sold

### 2. Controller Layer
**`lib/features/profile/controllers/my_listings_controller.dart`**
- Manages state for My Listings
- Extends `BaseController` for loading/error states
- Methods:
  - `fetchMyListings({String? status})` - Fetch listings from API
  - `refreshListings()` - Refresh current listings
  - `deleteListing(int listingId)` - Delete a listing
  - `markAsSold(int listingId)` - Mark listing as sold
  - `filterByStatus(String? status)` - Filter listings by status

### 3. Screen Layer
**`lib/features/profile/screens/my_listings_page.dart`**
- Full-screen page displaying all user's listings
- Features:
  - Pull-to-refresh functionality
  - Filter menu (All, Active, Sold, Expired)
  - Scrollable list of listings
  - Empty state with call-to-action
  - Loading shimmer effect
  - Tap to view listing details

### 4. Widget Layer
**`lib/features/profile/widgets/my_listings_section.dart`**
- Reusable widget for displaying a preview of user's listings
- Similar to `RecentListingSection` from home feature
- Can be embedded in other pages
- Limits displayed listings (default: 3)
- Shows "View All" button to navigate to full page

## Integration

### Profile Page
The feature is integrated into the Profile Page:

```dart
// lib/features/profile/screens/profile_page.dart

import 'package:flutter_app/features/profile/screens/my_listings_page.dart';

void _handleMyListings() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MyListingsPage()),
  );
}
```

## Usage

### Navigate to My Listings Page
From anywhere in the app:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const MyListingsPage()),
);
```

### Use My Listings Section Widget
To embed a preview in any page:
```dart
import 'package:flutter_app/features/profile/widgets/my_listings_section.dart';

MyListingsSection(
  listings: myListings,
  isLoading: isLoading,
  onActionPressed: () {
    // Navigate to full My Listings page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MyListingsPage()),
    );
  },
  onListingTap: (listing) {
    // Handle listing tap
    HomeNavigationService.toAnimalDetail(context, listing.id);
  },
  maxListingsToShow: 3, // Show max 3 listings in preview
)
```

## API Endpoints

The feature uses the existing listings API:
- **GET** `/api/listings/` - Fetch listings (filters by current user on backend)
- **PATCH** `/api/listings/{id}/` - Update listing status

### Query Parameters
- `status` - Filter by status (active, sold, expired)

## Features

### ✅ Implemented
- View all user's listings
- Pull-to-refresh
- Filter by status (All, Active, Sold, Expired)
- Loading states with shimmer effect
- Empty states with helpful messages
- Navigate to listing details
- Scrollable list
- Listing count display

### 🚧 Future Enhancements
- Delete listing functionality (needs backend endpoint)
- Edit listing navigation
- Share listing
- Analytics (views, clicks, etc.)
- Sort options (date, price, etc.)
- Bulk actions (multi-select)

## Design Pattern

The implementation follows the existing codebase patterns:

```
profile/
├── services/
│   └── my_listings_service.dart      # API calls
├── controllers/
│   └── my_listings_controller.dart   # State management
├── screens/
│   └── my_listings_page.dart         # Full page UI
└── widgets/
    └── my_listings_section.dart      # Reusable widget
```

## Dependencies

Reuses existing components:
- `ListingModel` - Data model from `lib/data/models/`
- `ListingCard` - Shared widget from `lib/shared/widgets/cards/`
- `BackendHelper` - API helper from `lib/core/helpers/`
- `BaseController` - Base controller from `lib/core/base/`
- `HomeNavigationService` - Navigation from `lib/features/home/services/`

## Testing

To test the feature:
1. Navigate to Profile page
2. Tap on "My Listings" menu item
3. View your listings (or empty state if none)
4. Test pull-to-refresh
5. Test filter menu
6. Tap on a listing to view details

## Notes

- The feature assumes the backend filters listings by the authenticated user
- Delete functionality is stubbed (throws `UnimplementedError`)
- Listing status updates use PATCH endpoint
- All listings are scrollable with proper physics
- Shimmer loading provides good UX during data fetch
