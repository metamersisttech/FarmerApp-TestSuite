# Location Feature

A comprehensive location selection feature for the Farmer Frontend Flutter app.

## Structure

```
lib/features/location/
├── controllers/
│   └── location_controller.dart      # Controller managing location state
├── models/
│   └── location_model.dart           # Location data models
├── screens/
│   ├── location_page.dart            # Main location page with search
│   ├── state_selection_page.dart     # State selection page
│   ├── city_selection_page.dart      # City selection page
│   └── area_selection_page.dart      # Area selection page
├── services/
│   └── location_data_service.dart    # India states/cities/areas data
└── widgets/
    ├── location_search_bar.dart      # Reusable search bar
    └── location_list_item.dart       # Reusable list item
```

## Features

### 1. Main Location Page
- Search bar for "city, area or neighbourhood"
- "Use Current Location" button with location permission handling
- "Choose State" section to start manual selection

### 2. State Selection Page
- Search functionality for all Indian states
- List of all 28 states and 8 union territories
- Click to navigate to city selection

### 3. City Selection Page
- Title shows selected state name
- Search functionality for cities in the selected state
- Major cities included for each state
- Click to navigate to area selection

### 4. Area Selection Page
- Title shows selected city name
- Search functionality for areas
- Shows area name and pincode
- Click to select and return location

## Usage

### Navigate to Location Page

```dart
final selectedLocation = await Navigator.push<LocationData>(
  context,
  MaterialPageRoute(
    builder: (context) => const LocationPage(),
  ),
);

if (selectedLocation != null) {
  // Use the selected location
  print(selectedLocation.displayLocation); // e.g., "Koramangala, Bangalore"
}
```

### LocationData Model

```dart
class LocationData {
  final String? state;      // e.g., "Karnataka"
  final String? city;       // e.g., "Bangalore"
  final String? area;       // e.g., "Koramangala"
  final String? fullAddress;

  String get displayLocation; // Returns formatted location string
}
```

## Design

The location feature follows the same design system as the Edit Profile page:
- **Background Color**: `#F5F5F5` (light gray)
- **Primary Color**: `#4CAF50` (green)
- **Border Radius**: `12px` for rounded corners
- **Border Color**: Light gray `#E0E0E0`
- **Hover/Touch**: Subtle shadows and opacity changes

## Data

### States
All 28 states and 8 union territories of India are included.

### Cities
Major cities are pre-populated for each state. You can expand the list in `location_data_service.dart`.

### Areas
Sample areas are provided for major cities. In production, this should be fetched from an API.

## Integration

The location feature is integrated with the home page:
- Clicking the location icon in the home page header opens the Location Page
- Selected location is displayed in the home page header
- Location is saved in state and passed back through navigation

## Future Enhancements

1. **API Integration**: Fetch cities and areas from backend API
2. **Reverse Geocoding**: Convert GPS coordinates to address
3. **Recent Locations**: Save and show recently selected locations
4. **Map View**: Add map-based location selection
5. **Auto-complete**: Add smart autocomplete for search
