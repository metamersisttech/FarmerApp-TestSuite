import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/data/models/animal_detail_model.dart';

void main() {
  group('AnimalDetailModel.fromJson', () {
    Map<String, dynamic> _baseJson() => {
          'listing_id': 101,
          'title': 'HF Cow - High Milker',
          'price': 50000,
          'created_at': '2026-01-15T08:00:00.000Z',
          'updated_at': '2026-02-20T12:00:00.000Z',
        };

    test('should parse listing_id', () {
      final model = AnimalDetailModel.fromJson(_baseJson());
      expect(model.id, 101);
    });

    test('should fallback to id field when listing_id absent', () {
      final json = _baseJson();
      json.remove('listing_id');
      json['id'] = 202;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.id, 202);
    });

    test('should parse title', () {
      final model = AnimalDetailModel.fromJson(_baseJson());
      expect(model.title, 'HF Cow - High Milker');
    });

    test('should use name field when title absent', () {
      final json = _baseJson();
      json.remove('title');
      json['name'] = 'Gir Cow';
      final model = AnimalDetailModel.fromJson(json);
      expect(model.title, 'Gir Cow');
    });

    test('should default title to Unknown when neither title nor name', () {
      final json = _baseJson();
      json.remove('title');
      final model = AnimalDetailModel.fromJson(json);
      expect(model.title, 'Unknown');
    });

    test('should parse price as int', () {
      final model = AnimalDetailModel.fromJson(_baseJson());
      expect(model.price, 50000.0);
    });

    test('should parse price as double', () {
      final json = _baseJson();
      json['price'] = 35000.50;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.price, 35000.50);
    });

    test('should parse price from string', () {
      final json = _baseJson();
      json['price'] = '75000';
      final model = AnimalDetailModel.fromJson(json);
      expect(model.price, 75000.0);
    });

    test('should default price to 0 when absent', () {
      final json = <String, dynamic>{'listing_id': 1, 'title': 'X'};
      final model = AnimalDetailModel.fromJson(json);
      expect(model.price, 0.0);
    });

    test('should parse original_price', () {
      final json = _baseJson();
      json['original_price'] = 60000;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.originalPrice, 60000.0);
    });

    test('should parse originalPrice camelCase alias', () {
      final json = _baseJson();
      json['originalPrice'] = 55000;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.originalPrice, 55000.0);
    });

    test('should parse is_verified true', () {
      final json = _baseJson();
      json['is_verified'] = true;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.isVerified, isTrue);
    });

    test('should parse verified field as alias', () {
      final json = _baseJson();
      json['verified'] = true;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.isVerified, isTrue);
    });

    test('should default isVerified to false', () {
      final model = AnimalDetailModel.fromJson(_baseJson());
      expect(model.isVerified, isFalse);
    });

    test('should parse age_months', () {
      final json = _baseJson();
      json['age_months'] = 24;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.ageMonths, 24);
    });

    test('should parse weight_kg', () {
      final json = _baseJson();
      json['weight_kg'] = 380.0;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.weightKg, 380.0);
    });

    test('should parse milk_per_day', () {
      final json = _baseJson();
      json['milk_per_day'] = 15.0;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.milkPerDay, 15.0);
    });

    test('should fallback to milk_yield for milk per day', () {
      final json = _baseJson();
      json['milk_yield'] = 12.0;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.milkPerDay, 12.0);
    });

    test('should parse lactation_number', () {
      final json = _baseJson();
      json['lactation_number'] = 3;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.lactationNumber, 3);
    });

    test('should parse color', () {
      final json = _baseJson();
      json['color'] = 'Brown';
      final model = AnimalDetailModel.fromJson(json);
      expect(model.color, 'Brown');
    });

    test('should parse ai_price_min and ai_price_max', () {
      final json = _baseJson();
      json['ai_price_min'] = 45000.0;
      json['ai_price_max'] = 55000.0;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.aiPriceMin, 45000.0);
      expect(model.aiPriceMax, 55000.0);
    });

    test('should parse health_status', () {
      final json = _baseJson();
      json['health_status'] = 'Healthy';
      final model = AnimalDetailModel.fromJson(json);
      expect(model.healthStatus, 'Healthy');
    });

    test('should parse vaccination_status', () {
      final json = _baseJson();
      json['vaccination_status'] = 'Fully Vaccinated';
      final model = AnimalDetailModel.fromJson(json);
      expect(model.vaccinationStatus, 'Fully Vaccinated');
    });

    test('should parse vaccinations list', () {
      final json = _baseJson();
      json['vaccinations'] = [
        {'name': 'FMD', 'date': '2025-06-01', 'is_completed': true},
      ];
      final model = AnimalDetailModel.fromJson(json);
      expect(model.vaccinations.length, 1);
      expect(model.vaccinations[0].name, 'FMD');
      expect(model.vaccinations[0].isCompleted, isTrue);
    });

    test('should parse images from animal_images list of maps', () {
      final json = _baseJson();
      json['animal_images'] = [
        {'url': 'https://example.com/img1.jpg'},
        {'image_url': 'https://example.com/img2.jpg'},
      ];
      final model = AnimalDetailModel.fromJson(json);
      expect(model.imageUrls, contains('https://example.com/img1.jpg'));
    });

    test('should parse images from images list of strings', () {
      final json = _baseJson();
      json['images'] = ['https://example.com/a.jpg', 'https://example.com/b.jpg'];
      final model = AnimalDetailModel.fromJson(json);
      expect(model.imageUrls.length, greaterThanOrEqualTo(2));
    });

    test('should prepend primary_image if not already in list', () {
      final json = _baseJson();
      json['primary_image'] = 'https://example.com/main.jpg';
      json['images'] = ['https://example.com/other.jpg'];
      final model = AnimalDetailModel.fromJson(json);
      expect(model.imageUrls.first, 'https://example.com/main.jpg');
    });

    test('should not duplicate primary_image if already in list', () {
      final json = _baseJson();
      json['primary_image'] = 'https://example.com/main.jpg';
      json['images'] = ['https://example.com/main.jpg'];
      final model = AnimalDetailModel.fromJson(json);
      final count = model.imageUrls.where((u) => u == 'https://example.com/main.jpg').length;
      expect(count, 1);
    });

    test('should parse seller from seller field', () {
      final json = _baseJson();
      json['seller'] = {
        'id': 55,
        'name': 'Ramu Farmer',
        'rating': 4.5,
        'review_count': 12,
      };
      final model = AnimalDetailModel.fromJson(json);
      expect(model.seller?.id, 55);
      expect(model.seller?.name, 'Ramu Farmer');
      expect(model.seller?.rating, 4.5);
    });

    test('should parse seller from owner field as fallback', () {
      final json = _baseJson();
      json['owner'] = {'id': 77, 'name': 'Owner Name'};
      final model = AnimalDetailModel.fromJson(json);
      expect(model.seller?.id, 77);
      expect(model.seller?.name, 'Owner Name');
    });

    test('should parse farm info', () {
      final json = _baseJson();
      json['farm'] = {
        'id': 3,
        'name': 'Green Farm',
        'address': 'Patna, Bihar',
        'latitude': 25.5941,
        'longitude': 85.1376,
      };
      final model = AnimalDetailModel.fromJson(json);
      expect(model.farm?.id, 3);
      expect(model.farm?.name, 'Green Farm');
      expect(model.farm?.address, 'Patna, Bihar');
    });

    test('should parse transport_available', () {
      final json = _baseJson();
      json['transport_available'] = true;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.transportAvailable, isTrue);
    });

    test('should default transport_available to false', () {
      final model = AnimalDetailModel.fromJson(_baseJson());
      expect(model.transportAvailable, isFalse);
    });

    test('should parse estimated_transport_cost', () {
      final json = _baseJson();
      json['estimated_transport_cost'] = 1500.0;
      final model = AnimalDetailModel.fromJson(json);
      expect(model.estimatedTransportCost, 1500.0);
    });

    test('should parse createdAt', () {
      final model = AnimalDetailModel.fromJson(_baseJson());
      expect(model.createdAt?.year, 2026);
      expect(model.createdAt?.month, 1);
    });

    test('should parse breed from top-level field', () {
      final json = _baseJson();
      json['breed'] = 'Gir';
      final model = AnimalDetailModel.fromJson(json);
      expect(model.breed, 'Gir');
    });

    test('should extract breed from animal nested object when top-level absent', () {
      final json = _baseJson();
      json['animal'] = {'breed': 'HF', 'name': 'Holstein Friesian'};
      final model = AnimalDetailModel.fromJson(json);
      expect(model.breed, 'HF');
    });

    test('should parse gender', () {
      final json = _baseJson();
      json['gender'] = 'female';
      final model = AnimalDetailModel.fromJson(json);
      expect(model.gender, 'female');
    });

    test('should parse currency', () {
      final json = _baseJson();
      json['currency'] = 'INR';
      final model = AnimalDetailModel.fromJson(json);
      expect(model.currency, 'INR');
    });
  });

  group('AnimalDetailModel computed properties', () {
    AnimalDetailModel _build({
      double price = 50000.0,
      double? originalPrice,
      int? ageMonths,
      double? weightKg,
      double? milkPerDay,
      int? lactationNumber,
      String? breed,
      String? gender,
      double? aiPriceMin,
      double? aiPriceMax,
      FarmInfo? farm,
    }) {
      return AnimalDetailModel(
        id: 1,
        title: 'Test Animal',
        price: price,
        originalPrice: originalPrice,
        ageMonths: ageMonths,
        weightKg: weightKg,
        milkPerDay: milkPerDay,
        lactationNumber: lactationNumber,
        breed: breed,
        gender: gender,
        aiPriceMin: aiPriceMin,
        aiPriceMax: aiPriceMax,
        farm: farm,
      );
    }

    test('formattedPrice returns rupee symbol with no decimal', () {
      expect(_build(price: 50000).formattedPrice, '₹50000');
    });

    test('formattedPrice rounds price correctly', () {
      expect(_build(price: 50000.7).formattedPrice, '₹50001');
    });

    test('formattedOriginalPrice returns null when originalPrice is null', () {
      expect(_build().formattedOriginalPrice, isNull);
    });

    test('formattedOriginalPrice formats with rupee symbol', () {
      expect(_build(originalPrice: 60000.0).formattedOriginalPrice, '₹60000');
    });

    test('formattedAge returns Unknown when ageMonths is null', () {
      expect(_build().formattedAge, 'Unknown');
    });

    test('formattedAge returns months for less than 12 months', () {
      expect(_build(ageMonths: 6).formattedAge, '6 Months');
    });

    test('formattedAge returns "1 Month" for 1 month', () {
      expect(_build(ageMonths: 1).formattedAge, '1 Month');
    });

    test('formattedAge returns years for 12+ months', () {
      expect(_build(ageMonths: 24).formattedAge, '2 Years');
    });

    test('formattedAge returns "1 Year" for 12 months exactly', () {
      expect(_build(ageMonths: 12).formattedAge, '1 Year');
    });

    test('formattedAge rounds down partial years', () {
      expect(_build(ageMonths: 18).formattedAge, '1 Year');
    });

    test('formattedWeight returns null when weightKg is null', () {
      expect(_build().formattedWeight, isNull);
    });

    test('formattedWeight returns integer kg string', () {
      expect(_build(weightKg: 380.0).formattedWeight, '380 kg');
    });

    test('formattedMilkPerDay returns null when milkPerDay is null', () {
      expect(_build().formattedMilkPerDay, isNull);
    });

    test('formattedMilkPerDay returns liters string', () {
      expect(_build(milkPerDay: 15.0).formattedMilkPerDay, '15 Liters');
    });

    test('formattedLactation returns null when lactationNumber is null', () {
      expect(_build().formattedLactation, isNull);
    });

    test('formattedLactation returns "1st" for lactation 1', () {
      expect(_build(lactationNumber: 1).formattedLactation, '1st');
    });

    test('formattedLactation returns "2nd" for lactation 2', () {
      expect(_build(lactationNumber: 2).formattedLactation, '2nd');
    });

    test('formattedLactation returns "3rd" for lactation 3', () {
      expect(_build(lactationNumber: 3).formattedLactation, '3rd');
    });

    test('formattedLactation returns "4th" for lactation 4', () {
      expect(_build(lactationNumber: 4).formattedLactation, '4th');
    });

    test('formattedLactation returns "11th" for lactation 11', () {
      expect(_build(lactationNumber: 11).formattedLactation, '11th');
    });

    test('formattedLactation returns "12th" for lactation 12', () {
      expect(_build(lactationNumber: 12).formattedLactation, '12th');
    });

    test('formattedLactation returns "13th" for lactation 13', () {
      expect(_build(lactationNumber: 13).formattedLactation, '13th');
    });

    test('formattedLactation returns "21st" for lactation 21', () {
      expect(_build(lactationNumber: 21).formattedLactation, '21st');
    });

    test('breedGenderDisplay returns empty when both null', () {
      expect(_build().breedGenderDisplay, '');
    });

    test('breedGenderDisplay returns breed only when gender null', () {
      expect(_build(breed: 'Gir').breedGenderDisplay, 'Gir');
    });

    test('breedGenderDisplay capitalizes gender', () {
      expect(_build(gender: 'female').breedGenderDisplay, 'Female');
    });

    test('breedGenderDisplay joins breed and gender with bullet', () {
      expect(_build(breed: 'HF', gender: 'female').breedGenderDisplay, 'HF • Female');
    });

    test('location returns "Location not available" when farm is null', () {
      expect(_build().location, 'Location not available');
    });

    test('location returns farm address when farm present', () {
      final farm = FarmInfo(id: 1, address: 'Patna, Bihar');
      expect(_build(farm: farm).location, 'Patna, Bihar');
    });

    test('hasAiPriceEstimate is false when both are null', () {
      expect(_build().hasAiPriceEstimate, isFalse);
    });

    test('hasAiPriceEstimate is false when only one is set', () {
      expect(_build(aiPriceMin: 40000.0).hasAiPriceEstimate, isFalse);
    });

    test('hasAiPriceEstimate is true when both are set', () {
      expect(
        _build(aiPriceMin: 45000.0, aiPriceMax: 55000.0).hasAiPriceEstimate,
        isTrue,
      );
    });

    test('aiPriceRangeDisplay returns null when not available', () {
      expect(_build().aiPriceRangeDisplay, isNull);
    });

    test('aiPriceRangeDisplay formats as rupee range', () {
      expect(
        _build(aiPriceMin: 45000.0, aiPriceMax: 55000.0).aiPriceRangeDisplay,
        '₹45000 - ₹55000',
      );
    });
  });

  group('AnimalDetailModel.toJson', () {
    test('should include id, title, and price', () {
      final model = AnimalDetailModel(
        id: 5,
        title: 'Test',
        price: 10000.0,
      );
      final json = model.toJson();
      expect(json['id'], 5);
      expect(json['title'], 'Test');
      expect(json['price'], 10000.0);
    });

    test('should include is_verified', () {
      final model = AnimalDetailModel(id: 1, title: 'T', price: 0, isVerified: true);
      expect(model.toJson()['is_verified'], isTrue);
    });

    test('should include transport_available', () {
      final model = AnimalDetailModel(
        id: 1,
        title: 'T',
        price: 0,
        transportAvailable: true,
      );
      expect(model.toJson()['transport_available'], isTrue);
    });

    test('should include vaccinations list', () {
      final vax = VaccinationRecord(name: 'FMD', isCompleted: true);
      final model = AnimalDetailModel(
        id: 1,
        title: 'T',
        price: 0,
        vaccinations: [vax],
      );
      final json = model.toJson();
      expect((json['vaccinations'] as List).length, 1);
    });
  });

  group('VaccinationRecord', () {
    test('fromJson parses name and is_completed', () {
      final record = VaccinationRecord.fromJson({
        'name': 'FMD',
        'date': '2025-06-01',
        'is_completed': true,
      });
      expect(record.name, 'FMD');
      expect(record.isCompleted, isTrue);
    });

    test('fromJson uses vaccine_name as fallback', () {
      final record = VaccinationRecord.fromJson({'vaccine_name': 'BQ'});
      expect(record.name, 'BQ');
    });

    test('fromJson defaults name to Unknown', () {
      final record = VaccinationRecord.fromJson({});
      expect(record.name, 'Unknown');
    });

    test('formattedDate returns empty when date is null', () {
      final record = VaccinationRecord(name: 'FMD');
      expect(record.formattedDate, '');
    });

    test('formattedDate returns "Jun 2025" format', () {
      final record = VaccinationRecord(
        name: 'FMD',
        date: DateTime(2025, 6, 15),
      );
      expect(record.formattedDate, 'Jun 2025');
    });
  });

  group('SellerInfo', () {
    test('fromJson parses name', () {
      final seller = SellerInfo.fromJson({'id': 1, 'name': 'Ramu'});
      expect(seller.name, 'Ramu');
    });

    test('fromJson builds name from first_name + last_name', () {
      final seller = SellerInfo.fromJson({
        'id': 1,
        'first_name': 'Ram',
        'last_name': 'Kumar',
      });
      expect(seller.name, 'Ram Kumar');
    });

    test('fromJson uses username when no name fields', () {
      final seller = SellerInfo.fromJson({'id': 1, 'username': 'ramkumar99'});
      expect(seller.name, 'ramkumar99');
    });

    test('fromJson defaults name to Unknown Seller', () {
      final seller = SellerInfo.fromJson({'id': 1});
      expect(seller.name, 'Unknown Seller');
    });

    test('fromJson parses rating', () {
      final seller = SellerInfo.fromJson({'id': 1, 'name': 'A', 'rating': 4.5});
      expect(seller.rating, 4.5);
    });

    test('fromJson defaults rating to 0.0', () {
      final seller = SellerInfo.fromJson({'id': 1, 'name': 'A'});
      expect(seller.rating, 0.0);
    });

    test('fromJson parses is_verified', () {
      final seller = SellerInfo.fromJson({
        'id': 1,
        'name': 'A',
        'is_verified': true,
      });
      expect(seller.isVerified, isTrue);
    });
  });

  group('FarmInfo', () {
    test('fromJson parses id, name, address', () {
      final farm = FarmInfo.fromJson({
        'id': 2,
        'name': 'Green Farm',
        'address': 'Patna',
      });
      expect(farm.id, 2);
      expect(farm.name, 'Green Farm');
      expect(farm.address, 'Patna');
    });

    test('fromJson uses location as address fallback', () {
      final farm = FarmInfo.fromJson({'id': 1, 'location': 'Ranchi'});
      expect(farm.address, 'Ranchi');
    });

    test('fromJson parses latitude and longitude', () {
      final farm = FarmInfo.fromJson({
        'id': 1,
        'latitude': 25.5941,
        'longitude': 85.1376,
      });
      expect(farm.latitude, 25.5941);
      expect(farm.longitude, 85.1376);
    });
  });
}
