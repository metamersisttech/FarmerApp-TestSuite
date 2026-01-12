import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/features/location/controllers/location_controller.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:flutter_app/features/location/screens/area_selection_page.dart';
import 'package:flutter_app/features/location/widgets/location_search_bar.dart';
import 'package:flutter_app/features/location/widgets/location_list_item.dart';

/// City selection page
class CitySelectionPage extends StatefulWidget {
  final LocationController controller;
  final String stateName;
  final String stateCode;

  const CitySelectionPage({
    super.key,
    required this.controller,
    required this.stateName,
    required this.stateCode,
  });

  @override
  State<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<CityModel> _filteredCities = [];
  List<CityModel> _allCities = [];

  @override
  void initState() {
    super.initState();
    _allCities = widget.controller.getCitiesForState(widget.stateCode);
    _filteredCities = _allCities;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _filteredCities = widget.controller.searchCities(query, widget.stateCode);
    });
  }

  void _handleCitySelected(CityModel city) {
    widget.controller.selectCity(city.name);
    
    // Navigate to area selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AreaSelectionPage(
          controller: widget.controller,
          cityName: city.name,
          stateCode: widget.stateCode,
        ),
      ),
    ).then((selectedLocation) {
      if (selectedLocation != null) {
        // Pass the location back to the previous pages
        Navigator.pop(context, selectedLocation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.stateName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.authPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          
          // Search bar
          LocationSearchBar(
            hint: 'Search city',
            controller: _searchController,
            onChanged: _handleSearch,
          ),
          
          const SizedBox(height: 8),
          
          // Cities list
          Expanded(
            child: _filteredCities.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _filteredCities.length,
                    itemBuilder: (context, index) {
                      final city = _filteredCities[index];
                      return LocationListItem(
                        title: city.name,
                        subtitle: widget.stateName,
                        onTap: () => _handleCitySelected(city),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No cities found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search term',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
