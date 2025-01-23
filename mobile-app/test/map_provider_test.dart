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

    testWidgets('fetchNavigationInstructions retrieves and parses instructions',
        (WidgetTester tester) async {
      dotenv.testLoad(fileInput: 'GOOGLE_MAPS_API_KEY=TEST_API_KEY');

      mapProvider.currentLocation = LocationData.fromMap({
        'latitude': 37.7749,
        'longitude': -122.4194,
      });

      mapProvider.destination = const LatLng(37.422, -122.084);

      final mockResponse = {
        'routes': [
          {
            'legs': [
              {
                'steps': [
                  {
                    'html_instructions': '<b>Turn right</b> onto Main Street.',
                    'start_location': {'lat': 37.7749, 'lng': -122.4194},
                  },
                  {
                    'html_instructions': '<b>Turn left</b> onto Elm Street.',
                    'start_location': {'lat': 37.7750, 'lng': -122.4195},
                  },
                ]
              }
            ]
          }
        ]
      };

      final expectedUrl =
          'https://maps.googleapis.com/maps/api/directions/json?origin=37.7749,-122.4194&destination=37.422,-122.084&mode=walking&key=TEST_API_KEY';

      when(mockHttpClient.get(Uri.parse(expectedUrl))).thenAnswer(
        (_) async => http.Response(jsonEncode(mockResponse), 200),
      );

      when(mockTranslationProvider.translateText(any, any))
          .thenAnswer((_) async => 'Translated instruction.');

      await tester.pumpWidget(createTestWidget(Container()));

      await tester.pumpAndSettle();

      await mapProvider
          .fetchNavigationInstructions(tester.element(find.byType(Container)));

      expect(mapProvider.instructions.length, 2);

      expect(mapProvider.instructions[0]['instruction'],
          'Turn right onto Main Street.');
      expect(mapProvider.instructions[1]['instruction'],
          'Turn left onto Elm Street.');

      verify(mockHttpClient.get(Uri.parse(expectedUrl))).called(1);
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
