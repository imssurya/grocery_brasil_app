import 'package:flutter_test/flutter_test.dart';
import 'package:grocery_brasil_app/core/errors/exceptions.dart';
import 'package:grocery_brasil_app/domain/Address.dart';
import 'package:grocery_brasil_app/domain/Location.dart';
import 'package:grocery_brasil_app/features/addressing/data/AddressingServiceAdapter.dart';
import 'package:grocery_brasil_app/features/addressing/data/GeocodingAddressingServiceAdapter.dart';
import 'package:mockito/mockito.dart';

import 'package:geocoding/geocoding.dart' show GeocodingPlatform, Placemark;

class MockGeocodingPlatform extends Mock implements GeocodingPlatform {}

main() {
  MockGeocodingPlatform mockGeocodingPlatform;
  AddressingServiceAdapter sut;

  setUp(() {
    mockGeocodingPlatform = MockGeocodingPlatform();
    sut = GeocodingAddressingServiceAdapter(
        geocodingPlatform: mockGeocodingPlatform);
  });

  group('GeocodingAddressingServiceAdapter', () {
    test('should bring the address when ', () async {
      //setup
      final location = Location(lat: 10.0, lon: 10.0);
      final serviceReturns = List.of(
        [
          Placemark(
              name:
                  'Av. Epitácio Pessoa, 2566 - Ipanema, Rio de Janeiro - RJ, 22471-003, Brasil',
              street: 'Avenida Epitácio Pessoa',
              isoCountryCode: '',
              country: 'Brasil',
              postalCode: '22471-003',
              administrativeArea: 'Rio de Janeiro',
              subAdministrativeArea: 'Not used',
              locality: 'Rio de Janeiro',
              subLocality: 'Ipanema',
              thoroughfare: '2566',
              subThoroughfare: 'Not used')
        ],
      );
      final expected = Address(
          rawAddress:
              '${serviceReturns[0].street} ${serviceReturns[0].name}, ${serviceReturns[0].subLocality}, CEP: ${serviceReturns[0].postalCode}, ${serviceReturns[0].subAdministrativeArea}, ${serviceReturns[0].administrativeArea}, ${serviceReturns[0].country}',
          street: serviceReturns[0].street,
          number: serviceReturns[0].name,
          complement: '',
          poCode: serviceReturns[0].postalCode,
          county: serviceReturns[0].subLocality,
          country: Country(name: serviceReturns[0].country),
          state: State(name: serviceReturns[0].administrativeArea),
          city: City(name: serviceReturns[0].subAdministrativeArea),
          location: location);

      when(mockGeocodingPlatform.placemarkFromCoordinates(
              location.lat, location.lon))
          .thenAnswer((realInvocation) async => serviceReturns);
      //act
      final actual = await sut.getAddressFromLocation(location);
      //assert
      expect(actual, equals(expected));
      verify(mockGeocodingPlatform.placemarkFromCoordinates(
          location.lat, location.lon));
      verifyNoMoreInteractions(mockGeocodingPlatform);
    });

    test('should throw not found if no placemark is returned ', () async {
      //setup
      final location = Location(lat: 10.0, lon: 10.0);
      final serviceReturns = List<Placemark>.empty();
      final expected = AddressingException(
          messageId: MessageIds.NOT_FOUND,
          message:
              'No addresses found on location(lat: ${location.lat}, lon: ${location.lon})');

      when(mockGeocodingPlatform.placemarkFromCoordinates(
              location.lat, location.lon))
          .thenAnswer((realInvocation) async => serviceReturns);
      //act
      //assert
      expect(() async => await sut.getAddressFromLocation(location),
          throwsA(expected));
    });

    test('should throw exception when some error occurs', () {
//setup
      final location = Location(lat: 10.0, lon: 10.0);

      final expected = AddressingException(
          messageId: MessageIds.UNEXPECTED, message: 'Exception: some error');
      when(mockGeocodingPlatform.placemarkFromCoordinates(10.0, 10.0))
          .thenThrow(Exception('some error'));

//act
//assert
      expect(() async => await sut.getAddressFromLocation(location),
          throwsA(expected));
    });
  });
}
