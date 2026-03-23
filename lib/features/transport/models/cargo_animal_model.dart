/// Cargo Animal Model
///
/// Represents an animal in a transport request cargo.
/// Maps to Django CargoAnimalSerializer.
library;

import 'package:flutter_app/features/profile/models/listing_model.dart';

class CargoAnimalModel {
  final int? animalId;
  final int count;
  final String? species;
  final String? breed;
  final double? estimatedWeightKg;

  const CargoAnimalModel({
    this.animalId,
    required this.count,
    this.species,
    this.breed,
    this.estimatedWeightKg,
  });

  factory CargoAnimalModel.fromJson(Map<String, dynamic> json) {
    return CargoAnimalModel(
      animalId: json['animal_id'] as int? ?? json['id'] as int?,
      count: json['count'] as int? ?? 1,
      species: json['species'] as String?,
      breed: json['breed'] as String?,
      estimatedWeightKg: json['estimated_weight_kg'] != null
          ? (json['estimated_weight_kg'] as num).toDouble()
          : null,
    );
  }

  /// Create from a ListingModel (for selecting listed animals)
  factory CargoAnimalModel.fromListing(ListingModel listing, {int count = 1}) {
    return CargoAnimalModel(
      animalId: listing.id, // Links to the listing
      count: count,
      species: listing.species,
      breed: listing.breed,
      estimatedWeightKg: null, // Listings don't have weight field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animal_id': animalId, // Always send (null for manual entries)
      'count': count,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (estimatedWeightKg != null) 'estimated_weight_kg': estimatedWeightKg,
    };
  }

  /// Get display name (species + breed)
  String get displayName {
    if (species == null) return 'Unknown Animal';
    if (breed != null && breed!.isNotEmpty) {
      return '$breed $species';
    }
    return species!;
  }

  /// Get formatted weight
  String? get formattedWeight {
    if (estimatedWeightKg == null) return null;
    return '${estimatedWeightKg!.toStringAsFixed(0)} kg';
  }

  /// Get summary (e.g., "2 Cattle")
  String get summary => '$count $displayName${count > 1 ? 's' : ''}';

  CargoAnimalModel copyWith({
    int? animalId,
    int? count,
    String? species,
    String? breed,
    double? estimatedWeightKg,
  }) {
    return CargoAnimalModel(
      animalId: animalId ?? this.animalId,
      count: count ?? this.count,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      estimatedWeightKg: estimatedWeightKg ?? this.estimatedWeightKg,
    );
  }

  @override
  String toString() {
    return 'CargoAnimalModel(count: $count, species: $species, breed: $breed)';
  }
}
