import 'package:flutter_app/features/location/models/location_model.dart';

/// Service for managing India location data (States, Cities, Areas)
class LocationDataService {
  // Singleton
  static final LocationDataService _instance = LocationDataService._internal();
  factory LocationDataService() => _instance;
  LocationDataService._internal();

  /// Get all states in India
  List<StateModel> getAllStates() {
    return _indianStates;
  }

  /// Get cities for a specific state
  List<CityModel> getCitiesForState(String stateCode) {
    return _indianCities.where((city) => city.stateCode == stateCode).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get areas for a specific city (sample data - in real app, fetch from API)
  List<AreaModel> getAreasForCity(String cityName, String stateCode) {
    // Sample areas - in production, this should come from an API
    return _sampleAreas.where((area) => area.cityName == cityName).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Search states by name
  List<StateModel> searchStates(String query) {
    if (query.isEmpty) return getAllStates();
    
    final lowerQuery = query.toLowerCase();
    return _indianStates
        .where((state) => state.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Search cities by name within a state
  List<CityModel> searchCities(String query, String stateCode) {
    final cities = getCitiesForState(stateCode);
    if (query.isEmpty) return cities;
    
    final lowerQuery = query.toLowerCase();
    return cities
        .where((city) => city.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Search areas by name within a city
  List<AreaModel> searchAreas(String query, String cityName, String stateCode) {
    final areas = getAreasForCity(cityName, stateCode);
    if (query.isEmpty) return areas;
    
    final lowerQuery = query.toLowerCase();
    return areas
        .where((area) => area.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  // Major Indian States
  static final List<StateModel> _indianStates = [
    const StateModel(name: 'Andhra Pradesh', code: 'AP'),
    const StateModel(name: 'Arunachal Pradesh', code: 'AR'),
    const StateModel(name: 'Assam', code: 'AS'),
    const StateModel(name: 'Bihar', code: 'BR'),
    const StateModel(name: 'Chhattisgarh', code: 'CG'),
    const StateModel(name: 'Goa', code: 'GA'),
    const StateModel(name: 'Gujarat', code: 'GJ'),
    const StateModel(name: 'Haryana', code: 'HR'),
    const StateModel(name: 'Himachal Pradesh', code: 'HP'),
    const StateModel(name: 'Jharkhand', code: 'JH'),
    const StateModel(name: 'Karnataka', code: 'KA'),
    const StateModel(name: 'Kerala', code: 'KL'),
    const StateModel(name: 'Madhya Pradesh', code: 'MP'),
    const StateModel(name: 'Maharashtra', code: 'MH'),
    const StateModel(name: 'Manipur', code: 'MN'),
    const StateModel(name: 'Meghalaya', code: 'ML'),
    const StateModel(name: 'Mizoram', code: 'MZ'),
    const StateModel(name: 'Nagaland', code: 'NL'),
    const StateModel(name: 'Odisha', code: 'OD'),
    const StateModel(name: 'Punjab', code: 'PB'),
    const StateModel(name: 'Rajasthan', code: 'RJ'),
    const StateModel(name: 'Sikkim', code: 'SK'),
    const StateModel(name: 'Tamil Nadu', code: 'TN'),
    const StateModel(name: 'Telangana', code: 'TG'),
    const StateModel(name: 'Tripura', code: 'TR'),
    const StateModel(name: 'Uttar Pradesh', code: 'UP'),
    const StateModel(name: 'Uttarakhand', code: 'UK'),
    const StateModel(name: 'West Bengal', code: 'WB'),
    // Union Territories
    const StateModel(name: 'Andaman and Nicobar Islands', code: 'AN'),
    const StateModel(name: 'Chandigarh', code: 'CH'),
    const StateModel(name: 'Dadra and Nagar Haveli and Daman and Diu', code: 'DD'),
    const StateModel(name: 'Delhi', code: 'DL'),
    const StateModel(name: 'Jammu and Kashmir', code: 'JK'),
    const StateModel(name: 'Ladakh', code: 'LA'),
    const StateModel(name: 'Lakshadweep', code: 'LD'),
    const StateModel(name: 'Puducherry', code: 'PY'),
  ];

  // Major cities in India (sample - expand as needed)
  static final List<CityModel> _indianCities = [
    // Karnataka
    const CityModel(name: 'Bangalore', stateCode: 'KA'),
    const CityModel(name: 'Mysore', stateCode: 'KA'),
    const CityModel(name: 'Mangalore', stateCode: 'KA'),
    const CityModel(name: 'Hubli', stateCode: 'KA'),
    const CityModel(name: 'Belgaum', stateCode: 'KA'),
    const CityModel(name: 'Dharwad', stateCode: 'KA'),
    const CityModel(name: 'Gulbarga', stateCode: 'KA'),
    
    // Maharashtra
    const CityModel(name: 'Mumbai', stateCode: 'MH'),
    const CityModel(name: 'Pune', stateCode: 'MH'),
    const CityModel(name: 'Nagpur', stateCode: 'MH'),
    const CityModel(name: 'Nashik', stateCode: 'MH'),
    const CityModel(name: 'Aurangabad', stateCode: 'MH'),
    const CityModel(name: 'Solapur', stateCode: 'MH'),
    const CityModel(name: 'Kolhapur', stateCode: 'MH'),
    
    // Delhi
    const CityModel(name: 'New Delhi', stateCode: 'DL'),
    const CityModel(name: 'Delhi', stateCode: 'DL'),
    
    // Tamil Nadu
    const CityModel(name: 'Chennai', stateCode: 'TN'),
    const CityModel(name: 'Coimbatore', stateCode: 'TN'),
    const CityModel(name: 'Madurai', stateCode: 'TN'),
    const CityModel(name: 'Tiruchirappalli', stateCode: 'TN'),
    const CityModel(name: 'Salem', stateCode: 'TN'),
    
    // Gujarat
    const CityModel(name: 'Ahmedabad', stateCode: 'GJ'),
    const CityModel(name: 'Surat', stateCode: 'GJ'),
    const CityModel(name: 'Vadodara', stateCode: 'GJ'),
    const CityModel(name: 'Rajkot', stateCode: 'GJ'),
    
    // Rajasthan
    const CityModel(name: 'Jaipur', stateCode: 'RJ'),
    const CityModel(name: 'Jodhpur', stateCode: 'RJ'),
    const CityModel(name: 'Udaipur', stateCode: 'RJ'),
    const CityModel(name: 'Kota', stateCode: 'RJ'),
    
    // West Bengal
    const CityModel(name: 'Kolkata', stateCode: 'WB'),
    const CityModel(name: 'Howrah', stateCode: 'WB'),
    const CityModel(name: 'Durgapur', stateCode: 'WB'),
    
    // Uttar Pradesh
    const CityModel(name: 'Lucknow', stateCode: 'UP'),
    const CityModel(name: 'Kanpur', stateCode: 'UP'),
    const CityModel(name: 'Agra', stateCode: 'UP'),
    const CityModel(name: 'Varanasi', stateCode: 'UP'),
    const CityModel(name: 'Noida', stateCode: 'UP'),
    const CityModel(name: 'Ghaziabad', stateCode: 'UP'),
    
    // Telangana
    const CityModel(name: 'Hyderabad', stateCode: 'TG'),
    const CityModel(name: 'Warangal', stateCode: 'TG'),
    
    // Kerala
    const CityModel(name: 'Thiruvananthapuram', stateCode: 'KL'),
    const CityModel(name: 'Kochi', stateCode: 'KL'),
    const CityModel(name: 'Kozhikode', stateCode: 'KL'),
    
    // Punjab
    const CityModel(name: 'Chandigarh', stateCode: 'PB'),
    const CityModel(name: 'Ludhiana', stateCode: 'PB'),
    const CityModel(name: 'Amritsar', stateCode: 'PB'),
    
    // Add more cities as needed...
  ];

  // Sample areas (In production, fetch from API based on city)
  static final List<AreaModel> _sampleAreas = [
    // Bangalore areas
    const AreaModel(name: 'Koramangala', cityName: 'Bangalore', pincode: '560034'),
    const AreaModel(name: 'Indiranagar', cityName: 'Bangalore', pincode: '560038'),
    const AreaModel(name: 'Whitefield', cityName: 'Bangalore', pincode: '560066'),
    const AreaModel(name: 'Jayanagar', cityName: 'Bangalore', pincode: '560041'),
    const AreaModel(name: 'HSR Layout', cityName: 'Bangalore', pincode: '560102'),
    const AreaModel(name: 'BTM Layout', cityName: 'Bangalore', pincode: '560076'),
    const AreaModel(name: 'Electronic City', cityName: 'Bangalore', pincode: '560100'),
    
    // Pune areas
    const AreaModel(name: 'Koregaon Park', cityName: 'Pune', pincode: '411001'),
    const AreaModel(name: 'Hinjewadi', cityName: 'Pune', pincode: '411057'),
    const AreaModel(name: 'Wakad', cityName: 'Pune', pincode: '411057'),
    const AreaModel(name: 'Baner', cityName: 'Pune', pincode: '411045'),
    const AreaModel(name: 'Viman Nagar', cityName: 'Pune', pincode: '411014'),
    
    // Mumbai areas
    const AreaModel(name: 'Andheri', cityName: 'Mumbai', pincode: '400053'),
    const AreaModel(name: 'Bandra', cityName: 'Mumbai', pincode: '400050'),
    const AreaModel(name: 'Powai', cityName: 'Mumbai', pincode: '400076'),
    const AreaModel(name: 'Malad', cityName: 'Mumbai', pincode: '400064'),
    
    // Add more areas as needed...
  ];
}
