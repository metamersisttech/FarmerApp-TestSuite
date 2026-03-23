/// Location Picker Widget
///
/// Address input with search and current location support.
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/core/helpers/backend_helper.dart';
import 'package:geolocator/geolocator.dart';

class LocationData {
  final String address;
  final double latitude;
  final double longitude;

  const LocationData({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

class LocationPickerWidget extends StatefulWidget {
  final String label;
  final String? hint;
  final LocationData? initialLocation;
  final ValueChanged<LocationData?> onLocationChanged;
  final bool showCurrentLocationButton;
  final IconData? prefixIcon;

  const LocationPickerWidget({
    super.key,
    required this.label,
    this.hint,
    this.initialLocation,
    required this.onLocationChanged,
    this.showCurrentLocationButton = true,
    this.prefixIcon,
  });

  @override
  State<LocationPickerWidget> createState() => _LocationPickerWidgetState();
}

class _LocationPickerWidgetState extends State<LocationPickerWidget> {
  final TextEditingController _controller = TextEditingController();
  final BackendHelper _backendHelper = BackendHelper();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isGettingLocation = false;
  Timer? _debounceTimer;
  LocationData? _selectedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLocation = widget.initialLocation;
      _controller.text = widget.initialLocation!.address;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _searchLocations(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await _backendHelper.getLocationSearch(query);
      final results = response['results'] as List<dynamic>? ?? [];

      if (mounted) {
        setState(() {
          _searchResults = results.cast<Map<String, dynamic>>();
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchLocations(query);
    });
  }

  void _selectResult(Map<String, dynamic> result) {
    final address = result['display_name'] as String? ?? '';
    final lat = double.tryParse(result['lat']?.toString() ?? '') ?? 0.0;
    final lon = double.tryParse(result['lon']?.toString() ?? '') ?? 0.0;

    final location = LocationData(
      address: address,
      latitude: lat,
      longitude: lon,
    );

    setState(() {
      _selectedLocation = location;
      _controller.text = address;
      _searchResults = [];
    });

    widget.onLocationChanged(location);
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Reverse geocode (use a simple address for now)
      final address = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';

      final location = LocationData(
        address: address,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (mounted) {
        setState(() {
          _selectedLocation = location;
          _controller.text = address;
          _isGettingLocation = false;
        });

        widget.onLocationChanged(location);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _clearLocation() {
    setState(() {
      _selectedLocation = null;
      _controller.clear();
      _searchResults = [];
    });
    widget.onLocationChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        // Input field
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint ?? 'Search for an address...',
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : const Icon(Icons.location_on_outlined),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearLocation,
                    tooltip: 'Clear',
                  ),
                if (widget.showCurrentLocationButton)
                  _isGettingLocation
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: _getCurrentLocation,
                          tooltip: 'Use current location',
                        ),
              ],
            ),
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (_selectedLocation != null && value != _selectedLocation!.address) {
              // Clear selection if user modifies the text
              setState(() {
                _selectedLocation = null;
              });
              widget.onLocationChanged(null);
            }
            _onSearchChanged(value);
          },
        ),

        // Search results
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_searchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                final displayName = result['display_name'] as String? ?? '';

                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(
                    displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  onTap: () => _selectResult(result),
                );
              },
            ),
          ),

        // Selected location indicator
        if (_selectedLocation != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Location selected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
