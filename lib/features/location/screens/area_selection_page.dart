import 'package:flutter/material.dart';
import 'package:flutter_app/features/location/controllers/location_controller.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:flutter_app/features/location/widgets/location_search_bar.dart';
import 'package:flutter_app/features/location/widgets/location_list_item.dart';

/// Area selection page
class AreaSelectionPage extends StatefulWidget {
  final LocationController controller;
  final String cityName;
  final String stateCode;

  const AreaSelectionPage({
    super.key,
    required this.controller,
    required this.cityName,
    required this.stateCode,
  });

  @override
  State<AreaSelectionPage> createState() => _AreaSelectionPageState();
}

class _AreaSelectionPageState extends State<AreaSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<AreaModel> _filteredAreas = [];
  List<AreaModel> _allAreas = [];

  @override
  void initState() {
    super.initState();
    _allAreas = widget.controller.getAreasForCity(
      widget.cityName,
      widget.stateCode,
    );
    _filteredAreas = _allAreas;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _filteredAreas = widget.controller.searchAreas(
        query,
        widget.cityName,
        widget.stateCode,
      );
    });
  }

  void _handleAreaSelected(AreaModel area) {
    widget.controller.selectArea(area.name);
    
    // Return the complete location data back through all navigation stack
    Navigator.pop(context, widget.controller.selectedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.cityName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          
          // Search bar
          LocationSearchBar(
            hint: 'Search area',
            controller: _searchController,
            onChanged: _handleSearch,
          ),
          
          const SizedBox(height: 8),
          
          // Areas list
          Expanded(
            child: _filteredAreas.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _filteredAreas.length,
                    itemBuilder: (context, index) {
                      final area = _filteredAreas[index];
                      return LocationListItem(
                        title: area.name,
                        subtitle: area.pincode.isNotEmpty
                            ? 'PIN: ${area.pincode}'
                            : widget.cityName,
                        onTap: () => _handleAreaSelected(area),
                        showArrow: false,
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
            'No areas found',
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
