// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:pbl5_menu/services/stt/i_tts_service.dart';
// import 'package:pbl5_menu/features/describe_environment.dart';
// import 'package:pbl5_menu/services/picture_service.dart';

// import 'describe_environment_test.mocks.dart';

// @GenerateMocks([ITtsService, PictureService])
// void main() {
//   group('DescribeEnvironment', () {
//     late MockITtsService mockTtsService;
//     late MockPictureService mockPictureService;
//     late DescribeEnvironment describeEnvironment;

//     setUp(() {
//       mockTtsService = MockITtsService();
//       mockPictureService = MockPictureService();

//       // Stub `getCameraPreview`
//       when(mockPictureService.getCameraPreview())
//           .thenReturn(Container()); // Return a placeholder widget

//       describeEnvironment = DescribeEnvironment(
//         ttsService: mockTtsService,
//         pictureService: mockPictureService,
//         sessionToken: 'testSessionToken',
//       );
//     });

//     testWidgets('should take and send image when button is pressed',
//         (WidgetTester tester) async {
//       await tester.pumpWidget(MaterialApp(
//         home: Scaffold(
//           body: describeEnvironment,
//         ),
//       ));

//       // Simulate button press
//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump(); // Wait for UI updates

//       // Verify picture service is called
//       verify(mockPictureService.takePicture(
//         endpoint:
//             'https://192.168.1.5:1880/describe?session_id=testSessionToken', // Updated endpoint
//         onLabelsDetected: anyNamed('onLabelsDetected'),
//         onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
//       )).called(1);
//     });

//     testWidgets('should call ttsService.speakLabels with correct labels',
//         (WidgetTester tester) async {
//       await tester.pumpWidget(MaterialApp(
//         home: Scaffold(
//           body: describeEnvironment,
//         ),
//       ));

//       // Simulate button press
//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump(); // Wait for UI updates

//       // Capture the onLabelsDetected callback
//       final captured = verify(mockPictureService.takePicture(
//         endpoint: anyNamed('endpoint'),
//         onLabelsDetected: captureAnyNamed('onLabelsDetected'),
//         onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
//       )).captured;

//       final onLabelsDetected = captured.first as Function(List<String>);
//       onLabelsDetected(['Label1', 'Label2']);

//       // Verify ttsService is called with correct labels
//       verify(mockTtsService.speakLabels(['Label1', 'Label2'])).called(1);
//     });

//     testWidgets('should show SnackBar with correct description',
//         (WidgetTester tester) async {
//       await tester.pumpWidget(MaterialApp(
//         home: Scaffold(
//           body: describeEnvironment,
//         ),
//       ));

//       // Simulate button press
//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump(); // Wait for UI updates

//       // Capture the onLabelsDetected callback
//       final captured = verify(mockPictureService.takePicture(
//         endpoint: anyNamed('endpoint'),
//         onLabelsDetected: captureAnyNamed('onLabelsDetected'),
//         onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
//       )).captured;

//       final onLabelsDetected = captured.first as Function(List<String>);
//       onLabelsDetected(['Label1', 'Label2']);

//       // Allow time for SnackBar to appear
//       await tester.pumpAndSettle();

//       // Verify SnackBar is shown with correct description
//       expect(find.text('Description: [Label1, Label2]'), findsOneWidget);
//     });

//     testWidgets('should show SnackBar with correct response time',
//         (WidgetTester tester) async {
//       await tester.pumpWidget(MaterialApp(
//         home: Scaffold(
//           body: describeEnvironment,
//         ),
//       ));

//       // Simulate button press
//       await tester.tap(find.byType(ElevatedButton));
//       await tester.pump(); // Wait for UI updates

//       // Capture the onResponseTimeUpdated callback
//       final captured = verify(mockPictureService.takePicture(
//         endpoint: anyNamed('endpoint'),
//         onLabelsDetected: anyNamed('onLabelsDetected'),
//         onResponseTimeUpdated: captureAnyNamed('onResponseTimeUpdated'),
//       )).captured;

//       final onResponseTimeUpdated = captured.first as Function(Duration);
//       onResponseTimeUpdated(Duration(seconds: 2));

//       // Allow time for SnackBar to appear
//       await tester.pumpAndSettle();

//       // Verify SnackBar is shown with correct response time
//       expect(find.text('Response time: 0:00:02.000000'), findsOneWidget);
//     });
//   });
// }
