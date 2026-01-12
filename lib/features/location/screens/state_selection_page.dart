import 'package:flutter/material.dart';
import 'package:flutter_app/shared/themes/app_theme.dart';
import 'package:flutter_app/features/location/controllers/location_controller.dart';
import 'package:flutter_app/features/location/models/location_model.dart';
import 'package:flutter_app/features/location/screens/city_selection_page.dart';
import 'package:flutter_app/features/location/widgets/location_search_bar.dart';
import 'package:flutter_app/features/location/widgets/location_list_item.dart';

/// State selection page
class StateSelectionPage extends StatefulWidget {
  final LocationController controller;

  const StateSelectionPage({
    super.key,
    required this.controller,
  });

  @override
  State<StateSelectionPage> createState() => _StateSelectionPageState();
}

class _StateSelectionPageState extends State<StateSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<StateModel> _filteredStates = [];
  List<StateModel> _allStates = [];

  @override
  void initState() {
    super.initState();
    _allStates = widget.controller.getAllStates();
    _filteredStates = _allStates;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    setState(() {
      _filteredStates = widget.controller.searchStates(query);
    });
  }

  void _handleStateSelected(StateModel state) {
    widget.controller.selectState(state.name);
    
    // Navigate to city selection
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CitySelectionPage(
          controller: widget.controller,
          stateName: state.name,
          stateCode: state.code,
        ),
      ),
    ).then((selectedLocation) {
      if (selectedLocation != null) {
        // Pass the location back to the previous page
        Navigator.pop(context, selectedLocation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Select State',
          style: TextStyle(
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
            hint: 'Search state',
            controller: _searchController,
            onChanged: _handleSearch,
          ),
          
          const SizedBox(height: 8),
          
          // States list
          Expanded(
            child: _filteredStates.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _filteredStates.length,
                    itemBuilder: (context, index) {
                      final state = _filteredStates[index];
                      return LocationListItem(
                        title: state.name,
                        subtitle: state.code,
                        onTap: () => _handleStateSelected(state),
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
            'No states found',
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
