import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:pbl5_menu/picture_service.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

import 'picture_service_test.mocks.dart'; // Replace with the correct import

class MockCameraPlatform extends CameraPlatform {
  @override
  Future<List<CameraDescription>> availableCameras() async {
    return <CameraDescription>[
      CameraDescription(
        name: 'Test Camera',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 90,
      ),
    ];
  }

  @override
  Stream<DeviceOrientationChangedEvent> onDeviceOrientationChanged() {
    // Implement this method to avoid UnimplementedError
    return Stream.empty();
  }

  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    // Implement this method to avoid UnimplementedError
    return 0; // Return a valid camera ID
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    // Provide a non-empty stream to avoid the error
    return Stream.value(CameraInitializedEvent(
      cameraId,
      1920,
      1080,
      ExposureMode.auto,
      true,
      FocusMode.auto,
      true, // Add the missing argument
    ));
  }

  @override
  Future<void> initializeCamera(int cameraId, {ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown}) async {
    // Implement this method to avoid UnimplementedError
  }
}

@GenerateMocks([CameraController, http.Client, http.MultipartRequest])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late PictureService pictureService;
  late MockCameraController mockController;
  late MockClient mockHttpClient;
  late MockMultipartRequest mockMultipartRequest;

  setUp(() {
    CameraPlatform.instance = MockCameraPlatform();
    mockController = MockCameraController();
    mockHttpClient = MockClient();
    mockMultipartRequest = MockMultipartRequest();
    pictureService = PictureService();
    pictureService.controller = mockController;
    pictureService.httpClient = mockHttpClient;
  });

  group('initializeCamera', () {
    test('should initialize the camera successfully', () async {
      when(mockController.initialize()).thenAnswer((_) async => null);

      await pictureService.initializeCamera();

      expect(pictureService.isCameraInitialized, true);
      verify(mockController.initialize()).called(1);
    });

    test('should handle exception during camera initialization', () async {
      when(mockController.initialize()).thenThrow(Exception('Camera error'));

      await pictureService.initializeCamera();

      expect(pictureService.isCameraInitialized, false);
      verify(mockController.initialize()).called(1);
    });
  });

  group('disposeCamera', () {
    test('should dispose the camera controller if initialized', () {
      pictureService.isCameraInitialized = true;

      pictureService.disposeCamera();

      verify(mockController.dispose()).called(1);
    });

    test('should not dispose the camera controller if not initialized', () {
      pictureService.isCameraInitialized = false;

      pictureService.disposeCamera();

      verifyNever(mockController.dispose());
    });
  });

  group('getCameraPreview', () {
    test('should return CameraPreview if camera is initialized', () {
      pictureService.isCameraInitialized = true;

      final preview = pictureService.getCameraPreview();

      expect(preview, isA<CameraPreview>());
    });

    test('should return CircularProgressIndicator if camera is not initialized',
        () {
      pictureService.isCameraInitialized = false;

      final preview = pictureService.getCameraPreview();

      expect(preview, isA<Center>());
    });
  });

  group('captureAndProcessImage', () {
    test('should capture and process image correctly', () async {
      final mockDirectory = Directory.systemTemp;
      final mockPicture = XFile('${mockDirectory.path}/test.jpg');
      final mockImage = img.Image(1024, 768);
      final testBytes = Uint8List.fromList([0, 1, 2, 3]);

      when(mockController.takePicture()).thenAnswer((_) async => mockPicture);
      when(File(mockPicture.path).readAsBytesSync()).thenReturn(testBytes);
      when(img.decodeImage(testBytes)).thenReturn(mockImage);
      when(img.copyResize(mockImage, width: 640, height: 480))
          .thenReturn(mockImage);

      final imagePath = await pictureService.captureAndProcessImage();

      expect(imagePath, contains(mockDirectory.path));
      verify(mockController.takePicture()).called(1);
      verify(() => img.decodeImage(testBytes)).called(1);
      verify(() => img.copyResize(mockImage, width: 640, height: 480))
          .called(1);
    });
  });

  group('sendImageAndHandleResponse', () {
    test('should handle successful response', () async {
      final mockResponseStream = Stream<List<int>>.fromIterable(
          [utf8.encode('{"detected_objects": ["object1", "object2"]}')]);
      final mockResponse = http.StreamedResponse(mockResponseStream, 200);

      when(mockMultipartRequest.send()).thenAnswer((_) async => mockResponse);

      final detectedObjects = <dynamic>[];
      final responseTimes = <Duration>[];

      await pictureService.sendImageAndHandleResponse(
        'test/path',
        (objects) => detectedObjects.addAll(objects),
        (duration) => responseTimes.add(duration),
      );

      expect(detectedObjects, ['object1', 'object2']);
      expect(responseTimes.isNotEmpty, true);
      verify(mockMultipartRequest.send()).called(1);
    });

    test('should handle failure response', () async {
      final mockResponseStream = Stream<List<int>>.fromIterable([]);
      final mockResponse = http.StreamedResponse(mockResponseStream, 500);

      when(mockMultipartRequest.send()).thenAnswer((_) async => mockResponse);

      final detectedObjects = <dynamic>[];
      final responseTimes = <Duration>[];

      await pictureService.sendImageAndHandleResponse(
        'test/path',
        (objects) => detectedObjects.addAll(objects),
        (duration) => responseTimes.add(duration),
      );

      expect(detectedObjects, isEmpty);
      expect(responseTimes.isNotEmpty, true);
      verify(mockMultipartRequest.send()).called(1);
    });
  });
}