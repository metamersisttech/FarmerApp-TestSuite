# Location Feature Flow

## User Journey

```
Home Page (Click Location Icon)
    ↓
Location Page
    ├── Search: "city, area or neighbourhood" (TODO: Global search)
    ├── Use Current Location Button
    │   ├── Request location permission if needed
    │   ├── Get GPS coordinates
    │   └── Return to Home with current location
    └── Choose State Button
        ↓
State Selection Page
    ├── Search: "Search state"
    ├── List: All 36 states/UTs of India
    └── Select State → Navigate to City Selection
        ↓
City Selection Page (Title: State Name)
    ├── Search: "Search city"
    ├── List: Major cities in selected state
    └── Select City → Navigate to Area Selection
        ↓
Area Selection Page (Title: City Name)
    ├── Search: "Search area"
    ├── List: Areas with pincodes
    └── Select Area → Return to Home with complete location
```

## Navigation Stack

```
HomePage
  → LocationPage
    → StateSelectionPage
      → CitySelectionPage
        → AreaSelectionPage
          [Returns LocationData]
        [Returns LocationData]
      [Returns LocationData]
    [Returns LocationData]
  [Update location display]
```

## Data Flow

```dart
// 1. User clicks location icon on Home Page
_handleLocationTap() 
  → Navigator.push(LocationPage)

// 2. User selects state
StateSelectionPage._handleStateSelected()
  → controller.selectState(state.name)
  → Navigator.push(CitySelectionPage)

// 3. User selects city
CitySelectionPage._handleCitySelected()
  → controller.selectCity(city.name)
  → Navigator.push(AreaSelectionPage)

// 4. User selects area
AreaSelectionPage._handleAreaSelected()
  → controller.selectArea(area.name)
  → Navigator.pop(context, controller.selectedLocation)
  → Cascades back through all pages
  → Returns to HomePage with LocationData

// 5. HomePage updates display
setState(() {
  _currentLocationText = selectedLocation.displayLocation;
});
```

## Key Components

### LocationController
- Manages location selection state
- Provides search methods
- Handles location permission requests
- Returns complete `LocationData` object

### LocationData Model
```dart
LocationData(
  state: "Karnataka",
  city: "Bangalore", 
  area: "Koramangala",
  fullAddress: "Koramangala, Bangalore, Karnataka"
)

displayLocation → "Koramangala, Bangalore"
```

### LocationDataService
- Singleton service for India location data
- 36 states/UTs
- Major cities for each state
- Sample areas (expand with API)
- Search functionality

## UI Components

### LocationSearchBar
- Consistent search input across all pages
- White background with subtle shadow
- Green theme matching app design

### LocationListItem
- Reusable list item for states/cities/areas
- Green location icon
- Title and subtitle
- Right arrow indicator
- Hover/touch feedback

## Theme Consistency

All pages use the same design system:
- **Background**: `#F5F5F5`
- **AppBar**: `#4CAF50` (Green)
- **Cards**: White with `12px` border radius
- **Borders**: Light gray `#E0E0E0`
- **Text**: Dark gray `#2B2B2B`
- **Icons**: Green `#4CAF50`
