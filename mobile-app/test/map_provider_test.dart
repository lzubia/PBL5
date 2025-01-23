import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/map_provider.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/translation_provider.dart';
import 'package:provider/provider.dart';

import 'map_provider_test.mocks.dart';

@GenerateMocks([
  Location,
  http.Client,
  PolylinePoints,
  TtsServiceGoogle,
  TranslationProvider,
  AppLocalizations,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocation mockLocation;
  late MockClient mockHttpClient;
  late MockPolylinePoints mockPolylinePoints;
  late MockTtsServiceGoogle mockTtsService;
  late MockTranslationProvider mockTranslationProvider;
  late MockAppLocalizations mockAppLocalizations;
  late MapProvider mapProvider;

  setUp(() {
    mockLocation = MockLocation();
    mockHttpClient = MockClient();
    mockPolylinePoints = MockPolylinePoints();
    mockTtsService = MockTtsServiceGoogle();
    mockTranslationProvider = MockTranslationProvider();
    mockAppLocalizations = MockAppLocalizations();
    mapProvider = MapProvider(
      httpClient: mockHttpClient,
      polylinePoints: mockPolylinePoints,
      ttsService: mockTtsService,
      location: mockLocation,
    );
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TranslationProvider>.value(
            value: mockTranslationProvider),
        Provider<AppLocalizations>.value(value: mockAppLocalizations),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
        ],
        locale: const Locale('en', 'US'),
        home: Scaffold(body: child),
      ),
    );
  }

  group('MapProvider Tests', () {
    // testWidgets('getCurrentLocation retrieves and listens for location changes',
    //     (WidgetTester tester) async {
    //   final mockLocationData = LocationData.fromMap({
    //     'latitude': 37.7749,
    //     'longitude': -122.4194,
    //   });

    //   // Mock `location.getLocation` to return a fixed location
    //   when(mockLocation.getLocation())
    //       .thenAnswer((_) async => mockLocationData);

    //   // Mock `location.onLocationChanged` to emit a stream of location updates
    //   final locationStreamController = StreamController<LocationData>();
    //   when(mockLocation.onLocationChanged)
    //       .thenAnswer((_) => locationStreamController.stream);

    //   // Mock translation
    //   when(mockAppLocalizations.translate("mapa-on"))
    //       .thenReturn("Map is now active.");

    //   await tester.pumpWidget(createTestWidget(Container()));

    //   await tester.pumpAndSettle(); // Ensure the widget tree is fully built

    //   // Call `getCurrentLocation`
    //   await mapProvider
    //       .getCurrentLocation(tester.element(find.byType(Container)));

    //   // Verify that the initial location is set
    //   expect(mapProvider.currentLocation, mockLocationData);

    //   // Simulate a location update
    //   final updatedLocationData = LocationData.fromMap({
    //     'latitude': 37.7750,
    //     'longitude': -122.4195,
    //   });
    //   locationStreamController.add(updatedLocationData);

    //   await Future.delayed(const Duration(milliseconds: 100));
    //   expect(mapProvider.currentLocation, updatedLocationData);

    //   // Verify that the `onLocationChanged` stream was listened to
    //   verify(mockLocation.onLocationChanged).called(1);

    //   // Verify that TTS speaks the "mapa-on" message
    //   verify(mockTtsService.speakLabels(["Map is now active."], any)).called(1);

    //   // Close the stream controller to ensure the test completes
    //   await locationStreamController.close();
    // });

    // testWidgets(
    //     'setDestination fetches destination coordinates and sets destination',
    //     (WidgetTester tester) async {
    //   // Mock loading the API key
    //   dotenv.testLoad(fileInput: 'GEOCODING_API_KEY=TEST_API_KEY');

    //   // Mock destination address
    //   final destinationAddress = '1600 Amphitheatre Parkway, Mountain View, CA';

    //   // Mock response data
    //   final mockResponse = {
    //     'status': 'OK',
    //     'results': [
    //       {
    //         'geometry': {
    //           'location': {'lat': 37.422, 'lng': -122.084}
    //         }
    //       }
    //     ]
    //   };

    //   // Expected URL
    //   final expectedUrl =
    //       'https://maps.googleapis.com/maps/api/geocode/json?address=$destinationAddress&key=TEST_API_KEY';

    //   // Mock the HTTP GET request
    //   when(mockHttpClient.get(Uri.parse(expectedUrl))).thenAnswer(
    //     (_) async => http.Response(jsonEncode(mockResponse), 200),
    //   );

    //   // Pump widget
    //   await tester.pumpWidget(createTestWidget(Container()));

    //   // Ensure the widget tree is built
    //   await tester.pumpAndSettle();

    //   // Call setDestination
    //   await mapProvider.setDestination(
    //     context: tester.element(find.byType(Container)),
    //     address: destinationAddress,
    //   );

    //   // Verify that the destination is set correctly
    //   expect(mapProvider.destination, const LatLng(37.422, -122.084));
    //   expect(mapProvider.destinationName, destinationAddress);

    //   // Verify that the mockHttpClient.get was called with the expected URL
    //   verify(mockHttpClient.get(Uri.parse(expectedUrl))).called(1);
    // });

    // testWidgets('setDestination throws exception for invalid address',
    //     (WidgetTester tester) async {
    //   dotenv.testLoad(fileInput: 'GEOCODING_API_KEY=TEST_API_KEY');
    //   final destinationAddress = 'invalid address';
    //   final mockResponse = {'status': 'ZERO_RESULTS'};

    //   // Mock HTTP client to return ZERO_RESULTS
    //   when(mockHttpClient.get(any)).thenAnswer(
    //     (_) async => http.Response(jsonEncode(mockResponse), 200),
    //   );

    //   // Mock translation
    //   when(mockAppLocalizations.translate("destination-not-found"))
    //       .thenReturn("Destination not found.");

    //   await tester.pumpWidget(createTestWidget(Container()));

    //   await tester.pumpAndSettle(); // Ensure the widget tree is fully built

    //   // Expect an exception when the address is invalid
    //   await expectLater(
    //     () async => await mapProvider.setDestination(
    //       context: tester.element(find.byType(Container)),
    //       address: destinationAddress,
    //     ),
    //     throwsA(isA<Exception>()),
    //   );

    //   // Verify that TTS speaks the error message
    //   verify(mockTtsService.speakLabels(["Destination not found."], any))
    //       .called(1);

    //   // Verify that the HTTP client was called
    //   verify(mockHttpClient.get(any)).called(1);
    // });

    testWidgets('fetchPolylineCoordinates retrieves polyline coordinates',
        (WidgetTester tester) async {
      dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=TEST_API_KEY');

      // Set the current location
      mapProvider.currentLocation = LocationData.fromMap({
        'latitude': 37.7749,
        'longitude': -122.4194,
      });

      // Set the destination
      mapProvider.destination = const LatLng(37.422, -122.084);

      // Mock PolylinePoints to return a valid result
      when(mockPolylinePoints.getRouteBetweenCoordinates(
        googleApiKey: anyNamed('googleApiKey'),
        request: anyNamed('request'),
      )).thenAnswer((_) async => PolylineResult(
            points: [
              PointLatLng(37.7749, -122.4194),
              PointLatLng(37.422, -122.084),
            ],
            status: 'OK',
          ));

      // Call the method under test
      await mapProvider.fetchPolylineCoordinates();

      // Verify the polyline coordinates
      expect(mapProvider.polylineCoordinates, [
        const LatLng(37.7749, -122.4194),
        const LatLng(37.422, -122.084),
      ]);

      // Verify that the mocked method was called once
      verify(mockPolylinePoints.getRouteBetweenCoordinates(
        googleApiKey: anyNamed('googleApiKey'),
        request: anyNamed('request'),
      )).called(1);
    });

    // testWidgets('dispose cancels location subscription',
    //     (WidgetTester tester) async {
    //   final streamController = StreamController<LocationData>();

    //   when(mockLocation.getLocation())
    //       .thenAnswer((_) async => LocationData.fromMap({
    //             'latitude': 37.7749,
    //             'longitude': -122.4194,
    //           }));

    //   when(mockLocation.onLocationChanged)
    //       .thenAnswer((_) => streamController.stream);

    //   await tester.pumpWidget(createTestWidget(Container()));
    //   await tester.pumpAndSettle();
    //   await mapProvider
    //       .getCurrentLocation(tester.element(find.byType(Container)));

    //   expect(mapProvider.locationSubscription, isNotNull);

    //   mapProvider.dispose();

    //   expect(mapProvider.locationSubscription, isNull);
    //   await streamController.close();
    // });

    test('removeHtmlTags removes HTML tags correctly', () {
      const htmlText = '<b>Turn right</b> at the <i>next</i> intersection.';
      const expected = 'Turn right at the next intersection.';
      final result = mapProvider.removeHtmlTags(htmlText);
      expect(result, expected);
    });
  });
}
