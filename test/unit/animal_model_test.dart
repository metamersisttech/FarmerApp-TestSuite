// test/unit/animal_model_test.dart
//
// Unit tests for lib/data/models/animal_model.dart
// Run: flutter test test/unit/animal_model_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/data/models/animal_model.dart';

void main() {
  group('AnimalModel.fromJson', () {
    test('parses all required fields', () {
      final json = {
        'animal_id': 3,
        'species': 'Cattle',
        'breed': 'Gir',
        'typical_life_years': 20,
      };
      final model = AnimalModel.fromJson(json);
      expect(model.animalId, 3);
      expect(model.species, 'Cattle');
      expect(model.breed, 'Gir');
      expect(model.typicalLifeYears, 20);
    });

    test('handles different species', () {
      final species = ['Cattle', 'Buffalo', 'Goat', 'Sheep', 'Pig'];
      for (final s in species) {
        final json = {
          'animal_id': 1,
          'species': s,
          'breed': 'Mixed',
          'typical_life_years': 10,
        };
        final model = AnimalModel.fromJson(json);
        expect(model.species, s);
      }
    });
  });

  group('AnimalModel.toJson', () {
    test('round-trips all fields', () {
      final original = AnimalModel(
        animalId: 5,
        species: 'Buffalo',
        breed: 'Murrah',
        typicalLifeYears: 25,
      );
      final json = original.toJson();
      final restored = AnimalModel.fromJson(json);

      expect(restored.animalId, original.animalId);
      expect(restored.species, original.species);
      expect(restored.breed, original.breed);
      expect(restored.typicalLifeYears, original.typicalLifeYears);
    });

    test('serializes correct keys', () {
      final model = AnimalModel(
        animalId: 1, species: 'Goat', breed: 'Boer', typicalLifeYears: 12);
      final json = model.toJson();
      expect(json.containsKey('animal_id'), isTrue);
      expect(json.containsKey('species'), isTrue);
      expect(json.containsKey('breed'), isTrue);
      expect(json.containsKey('typical_life_years'), isTrue);
    });
  });

  group('AnimalModel.toString', () {
    test('contains key identifiers', () {
      final model = AnimalModel(
        animalId: 7, species: 'Cattle', breed: 'Sahiwal', typicalLifeYears: 18);
      final str = model.toString();
      expect(str, contains('7'));
      expect(str, contains('Cattle'));
      expect(str, contains('Sahiwal'));
    });
  });
}
