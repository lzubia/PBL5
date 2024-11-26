import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pbl5_menu/picture_service.dart';

class MockCameraController extends Mock implements CameraController {}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late PictureService pictureService;
  late MockCameraController mockCameraController;
  late MockHttpClient mockHttpClient;

  setUp(() {
    pictureService = PictureService();
    mockCameraController = MockCameraController();
    mockHttpClient = MockHttpClient();
  });

  group('PictureService.takePicture', () {
    test('should capture, resize, and upload image successfully', () async {
      // Mock CameraController behavior
      final mockImageFile = File('test_image.jpg');
      final mockXFile = XFile(mockImageFile.path);

      when(mockCameraController.takePicture())
          .thenAnswer((_) async => mockXFile);

      // Mock FileSystem behavior
      final tempDirectory = Directory.systemTemp;
      when(getApplicationDocumentsDirectory())
          .thenAnswer((_) async => tempDirectory);

      // Mock HTTP request
      final mockResponse = http.StreamedResponse(
        Stream.value(utf8.encode(jsonEncode({
          'detected_objects': ['object1', 'object2']
        }))),
        200,
      );

      when(mockHttpClient.send(any)).thenAnswer((_) async => mockResponse);

      // Define callbacks
      List<dynamic> detectedObjects = [];
      Duration responseTime = Duration.zero;

      await pictureService.takePicture(
        controller: mockCameraController,
        onLabelsDetected: (labels) => detectedObjects = labels,
        onResponseTimeUpdated: (duration) => responseTime = duration,
      );

      // Verify results
      expect(detectedObjects, ['object1', 'object2']);
      expect(responseTime, isNot(Duration.zero));
      verify(mockCameraController.takePicture()).called(1);
      verify(mockHttpClient.send(any)).called(1);
    });

    test('should handle errors during picture capture', () async {
      when(mockCameraController.takePicture())
          .thenThrow(Exception('Camera error'));

      // Define callbacks
      List<dynamic> detectedObjects = [];
      Duration responseTime = Duration.zero;

      await pictureService.takePicture(
        controller: mockCameraController,
        onLabelsDetected: (labels) => detectedObjects = labels,
        onResponseTimeUpdated: (duration) => responseTime = duration,
      );

      // Verify results
      expect(detectedObjects, isEmpty);
      expect(responseTime, Duration.zero);
      verify(mockCameraController.takePicture()).called(1);
    });

    test('should handle errors during image upload', () async {
      // Mock CameraController behavior
      final mockImageFile = File('test_image.jpg');
      final mockXFile = XFile(mockImageFile.path);

      when(mockCameraController.takePicture())
          .thenAnswer((_) async => mockXFile);

      // Mock FileSystem behavior
      final tempDirectory = Directory.systemTemp;
      when(getApplicationDocumentsDirectory())
          .thenAnswer((_) async => tempDirectory);

      // Mock HTTP request failure
      when(mockHttpClient.send(any)).thenThrow(Exception('HTTP error'));

      // Define callbacks
      List<dynamic> detectedObjects = [];
      Duration responseTime = Duration.zero;

      await pictureService.takePicture(
        controller: mockCameraController,
        onLabelsDetected: (labels) => detectedObjects = labels,
        onResponseTimeUpdated: (duration) => responseTime = duration,
      );

      // Verify results
      expect(detectedObjects, isEmpty);
      expect(responseTime, Duration.zero);
      verify(mockCameraController.takePicture()).called(1);
      verify(mockHttpClient.send(any)).called(1);
    });
  });
}
