import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/features/describe_environment.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'describe_environment_test.mocks.dart';

@GenerateMocks([ITtsService, PictureService, AppInitializer])
void main() {
  group('DescribeEnvironment', () {
    late MockITtsService mockTtsService;
    late MockPictureService mockPictureService;
    late MockAppInitializer mockAppInitializer;

    setUp(() async {
      mockTtsService = MockITtsService();
      mockPictureService = MockPictureService();
      mockAppInitializer = MockAppInitializer();

      // Initialize dotenv
      await dotenv.load(fileName: ".env");

      // Stub `getCameraPreview`
      when(mockPictureService.getCameraPreview())
          .thenReturn(Container()); // Return a placeholder widget

      // Stub `isCameraInitialized`
      when(mockPictureService.isCameraInitialized).thenReturn(true);

      // Stub `sessionToken`
      when(mockAppInitializer.sessionToken).thenReturn('testSessionToken');
    });

    testWidgets('should take and send image when button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ITtsService>.value(value: mockTtsService),
            ChangeNotifierProvider<PictureService>.value(
                value: mockPictureService),
            Provider<AppInitializer>.value(value: mockAppInitializer),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DescribeEnvironment(),
            ),
          ),
        ),
      );

      // Simulate button press
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Wait for UI updates

      // Verify picture service is called
      verify(mockPictureService.takePicture(
        httpClient: anyNamed('httpClient'),
        endpoint:
            'https://begiapbl.duckdns.org:1880/API?id=4&session_id=testSessionToken',
        onLabelsDetected: anyNamed('onLabelsDetected'),
        onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
      )).called(1);
    });

    testWidgets('should call ttsService.speakLabels with correct labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ITtsService>.value(value: mockTtsService),
            ChangeNotifierProvider<PictureService>.value(
                value: mockPictureService),
            Provider<AppInitializer>.value(value: mockAppInitializer),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DescribeEnvironment(),
            ),
          ),
        ),
      );

      // Simulate button press
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Wait for UI updates

      // Capture the onLabelsDetected callback
      final captured = verify(mockPictureService.takePicture(
        httpClient: anyNamed('httpClient'),
        endpoint: anyNamed('endpoint'),
        onLabelsDetected: captureAnyNamed('onLabelsDetected'),
        onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
      )).captured;

      // Simulate the `onLabelsDetected` callback being invoked
      final onLabelsDetected = captured.first as Function(List<String>);
      onLabelsDetected(['Label1', 'Label2']);

      // Verify that `ttsService.speakLabels` is called with the correct labels
      verify(mockTtsService.speakLabels(['Label1', 'Label2'])).called(1);
    });

    testWidgets('should show SnackBar with correct description',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ITtsService>.value(value: mockTtsService),
            ChangeNotifierProvider<PictureService>.value(
                value: mockPictureService),
            Provider<AppInitializer>.value(value: mockAppInitializer),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DescribeEnvironment(),
            ),
          ),
        ),
      );

      // Simulate button press
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Wait for UI updates

      // Capture the onLabelsDetected callback
      final captured = verify(mockPictureService.takePicture(
        httpClient: anyNamed('httpClient'),
        endpoint: anyNamed('endpoint'),
        onLabelsDetected: captureAnyNamed('onLabelsDetected'),
        onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
      )).captured;

      // Simulate the `onLabelsDetected` callback being invoked
      final onLabelsDetected = captured.first as Function(List<String>);
      onLabelsDetected(['Label1', 'Label2']);

      // Allow time for SnackBar to appear
      await tester.pumpAndSettle();

      // Verify that the SnackBar shows the correct description
      expect(find.text('Description: [Label1, Label2]'), findsOneWidget);
    });

    testWidgets('should show SnackBar with correct response time',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ITtsService>.value(value: mockTtsService),
            ChangeNotifierProvider<PictureService>.value(
                value: mockPictureService),
            Provider<AppInitializer>.value(value: mockAppInitializer),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: DescribeEnvironment(),
            ),
          ),
        ),
      );

      // Simulate button press
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Wait for UI updates

      // Capture the onResponseTimeUpdated callback
      final captured = verify(mockPictureService.takePicture(
        httpClient: anyNamed('httpClient'),
        endpoint: anyNamed('endpoint'),
        onLabelsDetected: anyNamed('onLabelsDetected'),
        onResponseTimeUpdated: captureAnyNamed('onResponseTimeUpdated'),
      )).captured;

      // Simulate the `onResponseTimeUpdated` callback being invoked
      final onResponseTimeUpdated = captured.first as Function(Duration);
      onResponseTimeUpdated(Duration(seconds: 2));

      // Allow time for SnackBar to appear
      await tester.pumpAndSettle();

      // Verify that the SnackBar shows the correct response time
      expect(find.text('Response time: 0:00:02.000000'), findsOneWidget);
    });
  });
}
