import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/i_tts_service.dart';
import 'package:pbl5_menu/describe_environment.dart';
import 'package:pbl5_menu/picture_service.dart';

import 'describe_environment_test.mocks.dart';

@GenerateMocks([ITtsService, PictureService])
void main() {
  group('DescribeEnvironment', () {
    late MockITtsService mockTtsService;
    late MockPictureService mockPictureService;
    late DescribeEnvironment describeEnvironment;

    setUp(() {
      mockTtsService = MockITtsService();
      mockPictureService = MockPictureService();

      // Stub `getCameraPreview`
      when(mockPictureService.getCameraPreview())
          .thenReturn(Container()); // Return a placeholder widget

      describeEnvironment = DescribeEnvironment(
        ttsService: mockTtsService,
        pictureService: mockPictureService,
      );
    });

    // testWidgets('should display description when labels are detected',
    //     (WidgetTester tester) async {
    //   const mockLabels = 'Label1, Label2';

    //   // Stub `takePicture` to simulate `onLabelsDetected` callback
    //   when(mockPictureService.takePicture(
    //     endpoint: anyNamed('endpoint'),
    //     onLabelsDetected: anyNamed('onLabelsDetected'),
    //     onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    //   )).thenAnswer((invocation) {
    //     final onLabelsDetected = invocation.namedArguments[#onLabelsDetected]
    //         as void Function(String);
    //     // Pass a String to `onLabelsDetected` callback
    //     onLabelsDetected(mockLabels);
    //     return Future.value();
    //   });

    //   await tester.pumpWidget(MaterialApp(
    //     home: Scaffold(
    //       body: describeEnvironment,
    //     ),
    //   ));

    //   // Simulate button press
    //   await tester.tap(find.byType(ElevatedButton));
    //   await tester.pump(); // Wait for UI updates

    //   // Convert mockLabels into a List<String> for speakLabels
    //   final expectedLabels =
    //       mockLabels.split(', ').map((label) => label.trim()).toList();

    //   // Verify TTS service is called with the correct argument
    //   verify(mockTtsService.speakLabels(expectedLabels)).called(1);

    //   // Verify SnackBar is shown with correct text
    //   await tester.pump(); // Wait for SnackBar animation
    //   expect(find.text('Description: $mockLabels'), findsOneWidget);
    // });

    // testWidgets('should display response time when updated',
    //     (WidgetTester tester) async {
    //   const mockDuration = '1.23s';

    //   // Stub `takePicture` to simulate `onResponseTimeUpdated` callback
    //   when(mockPictureService.takePicture(
    //     endpoint: anyNamed('endpoint'),
    //     onLabelsDetected: anyNamed('onLabelsDetected'),
    //     onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
    //   )).thenAnswer((invocation) {
    //     final onResponseTimeUpdated = invocation
    //         .namedArguments[#onResponseTimeUpdated] as void Function(String);
    //     onResponseTimeUpdated(mockDuration); // Trigger the callback
    //     return Future.value();
    //   });

    //   await tester.pumpWidget(MaterialApp(
    //     home: Scaffold(
    //       body: describeEnvironment,
    //     ),
    //   ));

    //   // Simulate button press
    //   await tester.tap(find.byType(ElevatedButton));
    //   await tester.pump(); // Wait for UI updates

    //   // Verify SnackBar is shown with correct text
    //   await tester.pump(); // Wait for SnackBar animation
    //   expect(find.text('Response time: $mockDuration'), findsOneWidget);
    // });

    testWidgets('should take and send image when button is pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: describeEnvironment,
        ),
      ));

      // Simulate button press
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump(); // Wait for UI updates

      // Verify picture service is called
      verify(mockPictureService.takePicture(
        endpoint: 'http://192.168.1.2:1880/describe',
        onLabelsDetected: anyNamed('onLabelsDetected'),
        onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
      )).called(1);
    });
  });
}
