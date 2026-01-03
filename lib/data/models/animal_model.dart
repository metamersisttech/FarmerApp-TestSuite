/// Animal Model
///
/// Represents animal catalog data from the backend API
class AnimalModel {
  final int animalId;
  final String species;
  final String breed;
  final int typicalLifeYears;

  AnimalModel({
    required this.animalId,
    required this.species,
    required this.breed,
    required this.typicalLifeYears,
  });

  /// Create from JSON response
  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      animalId: json['animal_id'] as int,
      species: json['species'] as String,
      breed: json['breed'] as String,
      typicalLifeYears: json['typical_life_years'] as int,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'animal_id': animalId,
      'species': species,
      'breed': breed,
      'typical_life_years': typicalLifeYears,
    };
  }

  @override
  String toString() {
    return 'AnimalModel(animalId: $animalId, species: $species, breed: $breed, typicalLifeYears: $typicalLifeYears)';
  }
}

