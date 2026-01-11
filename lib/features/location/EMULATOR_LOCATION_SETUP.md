# Setting Location in Android Emulator

## Problem: Getting "Mountain View, California"

This is the **default GPS location** of Android emulators (Google's headquarters).

## Solutions

### 🎯 Method 1: Emulator Extended Controls (Easiest)

1. **Open Extended Controls**:
   - Look for the **3 dots (•••)** on the right side of emulator
   - Click it to open Extended Controls
   - OR press `Ctrl + Shift + A` in Android Studio

2. **Navigate to Location**:
   - Find and click **Location** in the left menu

3. **Set Your Location**:

   #### Option A: Search for City
   - Type "Bangalore" in the search box
   - Select from results
   - Click **Send**

   #### Option B: Use Coordinates
   Enter these coordinates manually:
   
   **Bangalore, Karnataka:**
   - Latitude: `12.9716`
   - Longitude: `77.5946`
   
   **Pune, Maharashtra:**
   - Latitude: `18.5204`
   - Longitude: `73.8567`
   
   **Mumbai, Maharashtra:**
   - Latitude: `19.0760`
   - Longitude: `72.8777`
   
   Click **Send** button

4. **Test Your App**:
   - Hot restart your app (R or Shift+R)
   - Location should now show correctly!

---

### 🎯 Method 2: Using ADB Commands (Terminal)

Open terminal and run:

```bash
# For Bangalore
adb emu geo fix 77.5946 12.9716

# For Pune
adb emu geo fix 73.8567 18.5204

# For Mumbai
adb emu geo fix 72.8777 19.0760

# Format: adb emu geo fix <longitude> <latitude>
# Note: longitude comes BEFORE latitude in ADB command!
```

**After running the command:**
- Hot restart your app
- The new location will be active

---

### 🎯 Method 3: GPX File (Simulate Movement)

If you want to simulate movement or test multiple locations:

1. Create a GPX file with your route
2. In Extended Controls → Location
3. Click "Load GPX/KML"
4. Select your GPX file
5. Click Play to simulate movement

**Sample GPX for Bangalore locations:**
```xml
<?xml version="1.0"?>
<gpx version="1.1">
  <wpt lat="12.9716" lon="77.5946">
    <name>MG Road, Bangalore</name>
  </wpt>
  <wpt lat="12.9352" lon="77.6245">
    <name>Koramangala, Bangalore</name>
  </wpt>
  <wpt lat="12.9698" lon="77.6501">
    <name>Whitefield, Bangalore</name>
  </wpt>
</gpx>
```

---

### 🎯 Method 4: Test on Real Device (Best)

**For the most accurate results:**
1. Connect your Android phone via USB
2. Enable USB debugging in Developer Options
3. Run: `flutter run`
4. Select your physical device
5. GPS will use actual device location

---

## Quick Reference: Indian City Coordinates

| City | Latitude | Longitude | ADB Command |
|------|----------|-----------|-------------|
| Bangalore | 12.9716 | 77.5946 | `adb emu geo fix 77.5946 12.9716` |
| Mumbai | 19.0760 | 72.8777 | `adb emu geo fix 72.8777 19.0760` |
| Delhi | 28.7041 | 77.1025 | `adb emu geo fix 77.1025 28.7041` |
| Pune | 18.5204 | 73.8567 | `adb emu geo fix 73.8567 18.5204` |
| Chennai | 13.0827 | 80.2707 | `adb emu geo fix 80.2707 13.0827` |
| Kolkata | 22.5726 | 88.3639 | `adb emu geo fix 88.3639 22.5726` |
| Hyderabad | 17.3850 | 78.4867 | `adb emu geo fix 78.4867 17.3850` |

---

## Verification

After setting location, check the logs:

```
📍 Geocoded address: Koramangala, Bangalore (lat: 12.9352, lng: 77.6245)
```

If you still see Mountain View warning:
```
⚠️ Detected emulator default location (Mountain View, CA)
💡 TIP: Set custom location in emulator settings
```

This means the location wasn't updated. Try the methods above again.

---

## Troubleshooting

### Location not updating?
1. **Restart the emulator**
2. Set location again
3. Hot restart the app (not just hot reload)

### Still showing wrong location?
1. Check if location services are ON in emulator
2. Verify GPS coordinates are correct (lat/lng order!)
3. Try using a different method from above

### Permission denied?
1. Uninstall the app from emulator
2. Run `flutter run` again
3. Grant location permission when prompted

---

## Pro Tip: Set Default Location for New Emulators

Edit your emulator config:
1. Close emulator
2. Navigate to: `C:\Users\<YourName>\.android\avd\<EmulatorName>.avd\`
3. Edit `config.ini`
4. Add these lines:
   ```ini
   hw.gps=yes
   hw.gpsLocation=12.9716,77.5946
   ```
5. Save and restart emulator

Now it will always start with Bangalore location!
