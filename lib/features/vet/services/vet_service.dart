import 'package:flutter_app/features/vet/models/vet_model.dart';
import 'package:flutter_app/features/vet/models/vet_review_model.dart';

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

  /// Get vet by ID
  Future<VetModel?> getVetById(int id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _sampleVets.firstWhere((vet) => vet.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get reviews for a vet
  Future<List<VetReviewModel>> getReviews(int vetId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));
    return _sampleReviews[vetId] ?? [];
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

  /// Sample vet data with extended fields
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
      bio:
          'Experienced veterinarian specializing in large animals with expertise in cattle and buffalo health. Graduated from IVRI Bareilly with 12+ years of field experience in rural and urban settings.',
      languages: ['Hindi', 'English', 'Marathi'],
      clinicName: 'Sharma Veterinary Clinic',
      clinicAddress: '123, Main Road, Near Bus Stand, Pune - 411001',
      workingHours: 'Mon-Sat: 9:00 AM - 7:00 PM',
      animalTypes: ['Cow', 'Buffalo', 'Goat', 'Sheep'],
      services: [
        'General Checkup',
        'Vaccination',
        'Surgery',
        'Pregnancy Care',
        'Emergency Care'
      ],
      videoCallFee: 200,
      homeVisitFee: 500,
      phoneNumber: '+91 98765 43210',
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
      bio:
          'Dedicated cattle specialist with a focus on dairy animal health and productivity. Expert in artificial insemination and fertility treatments.',
      languages: ['Hindi', 'English', 'Punjabi'],
      clinicName: 'Singh Animal Care Center',
      clinicAddress: '45, Gandhi Nagar, Sector 12, Jaipur - 302015',
      workingHours: 'Mon-Fri: 10:00 AM - 6:00 PM, Sat: 10:00 AM - 2:00 PM',
      animalTypes: ['Cow', 'Buffalo'],
      services: [
        'General Checkup',
        'Artificial Insemination',
        'Fertility Treatment',
        'Vaccination',
        'Deworming'
      ],
      videoCallFee: 150,
      homeVisitFee: 400,
      phoneNumber: '+91 98765 43211',
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
      bio:
          'Specialist in poultry health and small animal care. Extensive experience in disease prevention and flock management for commercial and backyard poultry.',
      languages: ['Hindi', 'English', 'Gujarati'],
      clinicName: 'Patel Pet & Poultry Clinic',
      clinicAddress: '78, Industrial Area, Phase 2, Ahmedabad - 380015',
      workingHours: 'Mon-Sun: 8:00 AM - 8:00 PM',
      animalTypes: ['Poultry', 'Goat', 'Sheep'],
      services: [
        'Poultry Health Check',
        'Vaccination',
        'Disease Prevention',
        'Flock Management',
        'General Checkup'
      ],
      videoCallFee: 150,
      homeVisitFee: 350,
      phoneNumber: '+91 98765 43212',
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
      bio:
          'Senior veterinarian with over 15 years of experience in livestock medicine. Specializes in complex surgical procedures and emergency care.',
      languages: ['Hindi', 'English'],
      clinicName: 'Kumar Veterinary Hospital',
      clinicAddress: '234, MG Road, Civil Lines, Lucknow - 226001',
      workingHours: 'Mon-Sat: 9:00 AM - 5:00 PM',
      animalTypes: ['Cow', 'Buffalo', 'Goat', 'Sheep', 'Horse'],
      services: [
        'General Checkup',
        'Surgery',
        'Emergency Care',
        'X-Ray & Diagnostics',
        'Post-operative Care'
      ],
      videoCallFee: 250,
      homeVisitFee: 600,
      phoneNumber: '+91 98765 43213',
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
      bio:
          'Expert in dairy animal health with focus on milk production optimization and reproductive health. Trained in advanced ultrasonography and pregnancy diagnosis.',
      languages: ['Hindi', 'English', 'Telugu'],
      clinicName: 'Reddy Dairy Care Clinic',
      clinicAddress: '56, Milk Colony, Ameerpet, Hyderabad - 500016',
      workingHours: 'Mon-Sat: 7:00 AM - 9:00 PM',
      animalTypes: ['Cow', 'Buffalo'],
      services: [
        'Pregnancy Diagnosis',
        'Ultrasound',
        'Milk Fever Treatment',
        'Vaccination',
        'Nutrition Counseling'
      ],
      videoCallFee: 180,
      homeVisitFee: 450,
      phoneNumber: '+91 98765 43214',
    ),
  ];

  /// Sample reviews data
  static final Map<int, List<VetReviewModel>> _sampleReviews = {
    1: [
      VetReviewModel(
        id: 1,
        reviewerName: 'Ramesh Patil',
        rating: 5.0,
        reviewText:
            'Excellent service! Dr. Sharma treated my cow very well. Very knowledgeable and caring. She explained everything clearly and the treatment was effective.',
        reviewDate: DateTime(2024, 1, 15),
        animalType: 'Cow',
      ),
      VetReviewModel(
        id: 2,
        reviewerName: 'Suresh Kumar',
        rating: 4.5,
        reviewText:
            'Good experience. The video consultation was very convenient. Dr. Sharma diagnosed the problem accurately and prescribed the right medicine.',
        reviewDate: DateTime(2024, 1, 10),
        animalType: 'Buffalo',
      ),
      VetReviewModel(
        id: 3,
        reviewerName: 'Lakshmi Devi',
        rating: 5.0,
        reviewText:
            'Dr. Priya is the best vet in our area. She comes for home visits even late at night. Very dedicated doctor.',
        reviewDate: DateTime(2024, 1, 5),
        animalType: 'Cow',
      ),
      VetReviewModel(
        id: 4,
        reviewerName: 'Mohan Rao',
        rating: 4.0,
        reviewText:
            'Professional service. Clinic is well-equipped. Waiting time was a bit long but treatment was good.',
        reviewDate: DateTime(2023, 12, 28),
        animalType: 'Goat',
      ),
      VetReviewModel(
        id: 5,
        reviewerName: 'Geeta Sharma',
        rating: 5.0,
        reviewText:
            'Highly recommended! Dr. Sharma saved my buffalo during a difficult delivery. Forever grateful.',
        reviewDate: DateTime(2023, 12, 20),
        animalType: 'Buffalo',
      ),
    ],
    2: [
      VetReviewModel(
        id: 6,
        reviewerName: 'Amit Singh',
        rating: 5.0,
        reviewText:
            'Dr. Vikram is an expert in AI (Artificial Insemination). Very successful results with my cattle.',
        reviewDate: DateTime(2024, 1, 12),
        animalType: 'Cow',
      ),
      VetReviewModel(
        id: 7,
        reviewerName: 'Prem Chand',
        rating: 4.5,
        reviewText:
            'Good doctor. Understood my buffalo\'s problem quickly. Medicine worked well.',
        reviewDate: DateTime(2024, 1, 8),
        animalType: 'Buffalo',
      ),
      VetReviewModel(
        id: 8,
        reviewerName: 'Raju Verma',
        rating: 4.0,
        reviewText:
            'Decent experience. Doctor is knowledgeable but clinic could be better organized.',
        reviewDate: DateTime(2024, 1, 2),
        animalType: 'Cow',
      ),
    ],
    3: [
      VetReviewModel(
        id: 9,
        reviewerName: 'Kishan Patel',
        rating: 5.0,
        reviewText:
            'Dr. Anjali is amazing with poultry. My entire flock was sick and she saved them all. Very affordable too.',
        reviewDate: DateTime(2024, 1, 14),
        animalType: 'Poultry',
      ),
      VetReviewModel(
        id: 10,
        reviewerName: 'Bharat Shah',
        rating: 4.5,
        reviewText:
            'Good vaccination service for my goats. Doctor explained the schedule properly.',
        reviewDate: DateTime(2024, 1, 6),
        animalType: 'Goat',
      ),
      VetReviewModel(
        id: 11,
        reviewerName: 'Narayan Das',
        rating: 5.0,
        reviewText:
            'Best poultry doctor in the city. Has helped my farm grow from 100 to 500 birds with proper care.',
        reviewDate: DateTime(2023, 12, 25),
        animalType: 'Poultry',
      ),
    ],
    4: [
      VetReviewModel(
        id: 12,
        reviewerName: 'Dinesh Gupta',
        rating: 4.5,
        reviewText:
            'Excellent surgical skills. Dr. Kumar performed a complex surgery on my horse successfully.',
        reviewDate: DateTime(2024, 1, 11),
        animalType: 'Horse',
      ),
      VetReviewModel(
        id: 13,
        reviewerName: 'Shankar Mishra',
        rating: 4.0,
        reviewText:
            'Good hospital with all facilities. Treatment is a bit expensive but quality is good.',
        reviewDate: DateTime(2024, 1, 3),
        animalType: 'Cow',
      ),
    ],
    5: [
      VetReviewModel(
        id: 14,
        reviewerName: 'Venkat Reddy',
        rating: 5.0,
        reviewText:
            'Dr. Meena is exceptional! My cow\'s milk production increased significantly after her nutrition advice.',
        reviewDate: DateTime(2024, 1, 13),
        animalType: 'Cow',
      ),
      VetReviewModel(
        id: 15,
        reviewerName: 'Srinivas Rao',
        rating: 5.0,
        reviewText:
            'Best dairy specialist. Her pregnancy diagnosis using ultrasound is very accurate. Highly recommended!',
        reviewDate: DateTime(2024, 1, 9),
        animalType: 'Buffalo',
      ),
      VetReviewModel(
        id: 16,
        reviewerName: 'Lakshman Naidu',
        rating: 4.5,
        reviewText:
            'Very helpful doctor. Available even on Sundays. Treated my cow\'s milk fever quickly.',
        reviewDate: DateTime(2024, 1, 4),
        animalType: 'Cow',
      ),
      VetReviewModel(
        id: 17,
        reviewerName: 'Krishna Murthy',
        rating: 5.0,
        reviewText:
            'Excellent service! Dr. Meena\'s home visit was very convenient. She is very patient and thorough.',
        reviewDate: DateTime(2023, 12, 30),
        animalType: 'Buffalo',
      ),
    ],
  };
}
