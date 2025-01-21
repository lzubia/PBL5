import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/map_provider.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';

import 'map_provider_test.mocks.dart';

@GenerateMocks([
  Location,
  http.Client,
  PolylinePoints,
  TtsServiceGoogle,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocation mockLocation;
  late MockClient mockHttpClient;
  late MockPolylinePoints mockPolylinePoints;
  late MapProvider mapProvider;

  setUp(() {
    mockLocation = MockLocation();
    mockHttpClient = MockClient();
    mockPolylinePoints = MockPolylinePoints();
    mapProvider = MapProvider(
        httpClient: mockHttpClient,
        polylinePoints: mockPolylinePoints,
        ttsService: MockTtsServiceGoogle())
      ..location = mockLocation;
  });

  group('MapProvider Tests', () {
    // test('getCurrentLocation retrieves and listens for location changes',
    //     () async {
    //   final mockLocationData = LocationData.fromMap({
    //     'latitude': 37.7749,
    //     'longitude': -122.4194,
    //   });

    //   // Mock location.getLocation
    //   when(mockLocation.getLocation())
    //       .thenAnswer((_) async => mockLocationData);

    //   // Mock onLocationChanged stream
    //   when(mockLocation.onLocationChanged)
    //       .thenAnswer((_) => Stream.value(mockLocationData));

    //   await mapProvider.getCurrentLocation();

    //   expect(mapProvider.currentLocation, mockLocationData);

    //   // Simulate location change
    //   await Future.delayed(const Duration(milliseconds: 100));
    //   verify(mockLocation.onLocationChanged).called(1);
    // });

    test('setDestination fetches destination coordinates', () async {
      dotenv.testLoad(fileInput: 'GEOCODING_API_KEY=TEST_API_KEY');
      final destinationAddress = '1600 Amphitheatre Parkway, Mountain View, CA';
      final mockResponse = {
        'status': 'OK',
        'results': [
          {
            'geometry': {
              'location': {'lat': 37.422, 'lng': -122.084}
            }
          }
        ]
      };

      // Mock HTTP client
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockResponse), 200),
      );

      await mapProvider.setDestination(destinationAddress);

      expect(mapProvider.destination, const LatLng(37.422, -122.084));
      verify(mockHttpClient.get(any)).called(1);
    });

    test('setDestination throws exception for invalid address', () async {
      dotenv.testLoad(fileInput: 'GEOCODING_API_KEY=TEST_API_KEY');
      final destinationAddress = 'invalid address';
      final mockResponse = {'status': 'ZERO_RESULTS'};

      // Mock HTTP client
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response(jsonEncode(mockResponse), 200),
      );

      expect(
        () async => await mapProvider.setDestination(destinationAddress),
        throwsA(isA<Exception>()),
      );

      verify(mockHttpClient.get(any)).called(1);
    });

    // test('fetchPolylineCoordinates retrieves polyline coordinates', () async {
    //   dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=TEST_API_KEY');

    //   // Set the current location
    //   mapProvider.currentLocation = LocationData.fromMap({
    //     'latitude': 37.7749,
    //     'longitude': -122.4194,
    //   });

    //   // Set the destination
    //   mapProvider.destination = const LatLng(37.422, -122.084);

    //   // Mock PolylinePoints to return a valid result
    //   when(mockPolylinePoints.getRouteBetweenCoordinates(
    //     googleApiKey: anyNamed('googleApiKey'),
    //     request: anyNamed('request'),
    //   )).thenAnswer((_) async => PolylineResult(
    //         points: [
    //           PointLatLng(37.7749, -122.4194),
    //           PointLatLng(37.422, -122.084),
    //         ],
    //         status: 'OK',
    //       ));

    //   // Call the method under test
    //   await mapProvider.fetchPolylineCoordinates();

    //   // Verify the polyline coordinates
    //   expect(mapProvider.polylineCoordinates, [
    //     const LatLng(37.7749, -122.4194),
    //     const LatLng(37.422, -122.084),
    //   ]);

    //   // Verify that the mocked method was called once
    //   verify(mockPolylinePoints.getRouteBetweenCoordinates(
    //     googleApiKey: anyNamed('googleApiKey'),
    //     request: anyNamed('request'),
    //   )).called(1);
    // });

    // test('fetchPolylineCoordinates throws exception for empty polyline',
    //     () async {
    //   dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=TEST_API_KEY');
    //   mapProvider.currentLocation = LocationData.fromMap({
    //     'latitude': 37.7749,
    //     'longitude': -122.4194,
    //   });
    //   mapProvider.destination = const LatLng(37.422, -122.084);

    //   final mockPolylineResult = PolylineResult(
    //     points: [],
    //     status: 'ZERO_RESULTS',
    //   );

    //   // Mock PolylinePoints
    //   when(mockPolylinePoints.getRouteBetweenCoordinates(
    //     googleApiKey: anyNamed('googleApiKey'),
    //     request: anyNamed('request'),
    //   )).thenAnswer((_) async => mockPolylineResult);

    //   expect(
    //     () async => await mapProvider.fetchPolylineCoordinates(),
    //     throwsA(isA<Exception>()),
    //   );

    //   verify(mockPolylinePoints.getRouteBetweenCoordinates(
    //     googleApiKey: anyNamed('googleApiKey'),
    //     request: anyNamed('request'),
    //   )).called(1);
    // });

    // test('dispose cancels location subscription', () async {
    //   final mockLocationSubscription = Stream.value(
    //     LocationData.fromMap({
    //       'latitude': 37.7749,
    //       'longitude': -122.4194,
    //     }),
    //   ).listen((_) {});

    //   mapProvider.locationSubscription = mockLocationSubscription;

    //   mapProvider.dispose();

    //   expect(mockLocationSubscription.isPaused, true);
    // });
  });
}
