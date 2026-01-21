import 'package:flutter_app/features/vet/models/vet_model.dart';

/// Service for vet-related data operations
/// Currently returns hardcoded data, will be connected to API in future
class VetService {
  /// List of available breeds for filtering
  static const List<String> breeds = [
    'All',
    'Cow',
    'Buffalo',
    'Goat',
    'Sheep',
    'Horse',
    'Poultry',
  ];

  /// Get all vets (hardcoded for now)
  Future<List<VetModel>> getVets() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _sampleVets;
  }

  /// Search vets by name or specialization
  Future<List<VetModel>> searchVets(String query) async {
    if (query.isEmpty) return _sampleVets;

    final lowerQuery = query.toLowerCase();
    return _sampleVets.where((vet) {
      return vet.name.toLowerCase().contains(lowerQuery) ||
          vet.specialization.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter vets by breed specialization
  Future<List<VetModel>> filterByBreed(String breed) async {
    if (breed == 'All') return _sampleVets;

    // In a real app, this would filter based on vet's specializations
    // For now, we return all vets as they all handle multiple animals
    return _sampleVets;
  }

  /// Sample vet data
  static final List<VetModel> _sampleVets = [
    const VetModel(
      id: 1,
      name: 'Dr. Priya Sharma',
      specialization: 'Large Animal Specialist',
      rating: 4.9,
      reviewCount: 234,
      distanceKm: 2.5,
      experienceYears: 12,
      consultationFee: 300,
      isAvailable: true,
      isVerified: true,
    ),
    const VetModel(
      id: 2,
      name: 'Dr. Vikram Singh',
      specialization: 'Cattle & Buffalo Expert',
      rating: 4.7,
      reviewCount: 156,
      distanceKm: 4.2,
      experienceYears: 8,
      consultationFee: 250,
      isAvailable: true,
      isVerified: true,
    ),
    const VetModel(
      id: 3,
      name: 'Dr. Anjali Patel',
      specialization: 'Poultry & Small Animals',
      rating: 4.8,
      reviewCount: 189,
      distanceKm: 3.1,
      experienceYears: 10,
      consultationFee: 200,
      isAvailable: true,
      isVerified: true,
    ),
    const VetModel(
      id: 4,
      name: 'Dr. Rajesh Kumar',
      specialization: 'Livestock General Practice',
      rating: 4.6,
      reviewCount: 112,
      distanceKm: 5.8,
      experienceYears: 15,
      consultationFee: 350,
      isAvailable: false,
      isVerified: true,
    ),
    const VetModel(
      id: 5,
      name: 'Dr. Meena Reddy',
      specialization: 'Dairy Animal Specialist',
      rating: 4.9,
      reviewCount: 278,
      distanceKm: 1.8,
      experienceYears: 9,
      consultationFee: 280,
      isAvailable: true,
      isVerified: true,
    ),
  ];
}
