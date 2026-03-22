import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/features/transport/models/cargo_animal_model.dart';

void main() {
  group('CargoAnimalModel', () {

    // ── fromJson ──────────────────────────────────────────────────────────
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'animal_id': 42,
          'count': 3,
          'species': 'Cattle',
          'breed': 'HF',
          'estimated_weight_kg': 450.5,
        };
        final m = CargoAnimalModel.fromJson(json);
        expect(m.animalId, 42);
        expect(m.count, 3);
        expect(m.species, 'Cattle');
        expect(m.breed, 'HF');
        expect(m.estimatedWeightKg, 450.5);
      });

      test('uses id as fallback when animal_id absent', () {
        final m = CargoAnimalModel.fromJson({'id': 7, 'count': 1, 'species': 'Goat'});
        expect(m.animalId, 7);
      });

      test('defaults count to 1 when missing', () {
        final m = CargoAnimalModel.fromJson({'species': 'Sheep'});
        expect(m.count, 1);
      });

      test('allows null optional fields', () {
        final m = CargoAnimalModel.fromJson({'count': 2});
        expect(m.animalId, isNull);
        expect(m.species, isNull);
        expect(m.breed, isNull);
        expect(m.estimatedWeightKg, isNull);
      });

      test('parses integer weight to double', () {
        final m = CargoAnimalModel.fromJson({'count': 1, 'estimated_weight_kg': 300});
        expect(m.estimatedWeightKg, 300.0);
      });
    });

    // ── toJson ────────────────────────────────────────────────────────────
    group('toJson', () {
      test('serialises all fields', () {
        final m = CargoAnimalModel(animalId: 5, count: 2, species: 'Buffalo', breed: 'Murrah', estimatedWeightKg: 600.0);
        final j = m.toJson();
        expect(j['animal_id'], 5);
        expect(j['count'], 2);
        expect(j['species'], 'Buffalo');
        expect(j['breed'], 'Murrah');
        expect(j['estimated_weight_kg'], 600.0);
      });

      test('omits weight when null', () {
        final j = CargoAnimalModel(count: 1).toJson();
        expect(j.containsKey('estimated_weight_kg'), isFalse);
      });

      test('omits animalId when null', () {
        final j = CargoAnimalModel(count: 1).toJson();
        expect(j.containsKey('animal_id'), isFalse);
      });
    });

    // ── round-trip ────────────────────────────────────────────────────────
    test('round-trips fromJson -> toJson -> fromJson', () {
      final original = CargoAnimalModel(animalId: 10, count: 4, species: 'Goat', breed: 'Sirohi', estimatedWeightKg: 35.0);
      final restored = CargoAnimalModel.fromJson(original.toJson());
      expect(restored.animalId, original.animalId);
      expect(restored.count, original.count);
      expect(restored.species, original.species);
      expect(restored.breed, original.breed);
      expect(restored.estimatedWeightKg, original.estimatedWeightKg);
    });

    // ── displayName ───────────────────────────────────────────────────────
    group('displayName', () {
      test('returns species when breed is null', () => expect(CargoAnimalModel(count: 1, species: 'Cattle').displayName, 'Cattle'));
      test('returns breed + species when both present', () => expect(CargoAnimalModel(count: 1, species: 'Cattle', breed: 'HF').displayName, 'HF Cattle'));
      test('returns Unknown Animal when both null', () => expect(CargoAnimalModel(count: 1).displayName, 'Unknown Animal'));
      test('ignores empty breed', () => expect(CargoAnimalModel(count: 1, species: 'Goat', breed: '').displayName, 'Goat'));
    });

    // ── formattedWeight ───────────────────────────────────────────────────
    group('formattedWeight', () {
      test('returns null when weight is null', () => expect(CargoAnimalModel(count: 1).formattedWeight, isNull));
      test('formats with kg suffix', () => expect(CargoAnimalModel(count: 1, estimatedWeightKg: 100.0).formattedWeight, '100 kg'));
    });

    // ── summary ───────────────────────────────────────────────────────────
    group('summary', () {
      test('singular', () => expect(CargoAnimalModel(count: 1, species: 'Cattle').summary, '1 Cattle'));
      test('plural', () => expect(CargoAnimalModel(count: 3, species: 'Goat').summary, '3 Goats'));
      test('unknown species', () => expect(CargoAnimalModel(count: 2).summary, '2 Unknown Animals'));
    });

    // ── copyWith ──────────────────────────────────────────────────────────
    group('copyWith', () {
      test('preserves unchanged fields', () {
        final copy = CargoAnimalModel(animalId: 1, count: 2, species: 'Cattle', breed: 'HF', estimatedWeightKg: 400.0).copyWith(count: 5);
        expect(copy.animalId, 1);
        expect(copy.count, 5);
        expect(copy.species, 'Cattle');
      });
    });
  });
}
