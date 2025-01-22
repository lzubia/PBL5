import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

import 'picture_service_test.mocks.dart';

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
    return Stream.empty();
  }

  @override
  Future<int> createCamera(
    CameraDescription cameraDescription,
    ResolutionPreset? resolutionPreset, {
    bool enableAudio = false,
  }) async {
    return 0; // Return a valid camera ID
  }

  @override
  Stream<CameraInitializedEvent> onCameraInitialized(int cameraId) {
    return Stream.value(CameraInitializedEvent(
      cameraId,
      1920,
      1080,
      ExposureMode.auto,
      true,
      FocusMode.auto,
      true,
    ));
  }

  @override
  Future<void> initializeCamera(int cameraId,
      {ImageFormatGroup imageFormatGroup = ImageFormatGroup.unknown}) async {}
}

@GenerateMocks([
  CameraController,
  http.Client,
  http.MultipartRequest,
  http.MultipartFile,
  MultipartFileWrapper,
  File,
  ImageDecoder
])
void main() {
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/path_provider');
  late PictureService pictureService;
  late MockCameraController mockController;
  late MockClient mockHttpClient;
  late MockMultipartRequest mockMultipartRequest;
  late MockFile mockFile;
  late MockImageDecoder mockImageDecoder;
  late MockMultipartFileWrapper mockMultipartFileWrapper;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    CameraPlatform.instance = MockCameraPlatform();
    mockController = MockCameraController();
    mockHttpClient = MockClient();
    mockMultipartRequest = MockMultipartRequest();
    mockImageDecoder = MockImageDecoder();
    mockFile = MockFile();
    mockMultipartFileWrapper = MockMultipartFileWrapper();

    pictureService = PictureService(
      httpClient: mockHttpClient,
      imageDecoder: mockImageDecoder,
      multipartFileWrapper: mockMultipartFileWrapper,
      multipartRequestFactory: (method, url) => mockMultipartRequest,
    );

    pictureService.controller = mockController;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel.name, (ByteData? message) async {
      final MethodCall methodCall =
          StandardMethodCodec().decodeMethodCall(message);
      if (methodCall.method == 'getApplicationDocumentsDirectory') {
        return const StandardMethodCodec()
            .encodeSuccessEnvelope('/mock/directory');
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel.name, null);
  });

  test(
      'should return mock directory path from getApplicationDocumentsDirectory',
      () async {
    final directory = await getApplicationDocumentsDirectory();
    expect(directory.path, '/mock/directory');
  });

  group('initializeCamera', () {
    test('should initialize the camera successfully', () async {
      when(mockController.initialize()).thenAnswer((_) async {});

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
      final Uint8List testBytes = Uint8List.fromList([0, 1, 2, 3]);
      final mockImage = img.Image(width: 1024, height: 768);

      // Stub file behavior
      when(mockFile.readAsBytesSync()).thenReturn(testBytes);
      when(mockFile.writeAsBytesSync(any)).thenReturn(null);
      when(mockFile.path)
          .thenReturn('/mock/directory/mock_image.jpg'); // Stub `path`

      // Mock image decoding and resizing
      when(mockImageDecoder.decodeImage(testBytes)).thenReturn(mockImage);
      when(mockImageDecoder.copyResize(mockImage, width: 640, height: 480))
          .thenReturn(mockImage);

      // Mock controller behavior
      final mockPicturePath = '/mock/directory/captured_image.jpg';
      final mockPicture = XFile(mockPicturePath);
      when(mockController.takePicture()).thenAnswer((_) async => mockPicture);

      // Inject mocks
      pictureService.fileFactory = (_) => mockFile;

      // Call the method under test
      final imagePath = await pictureService.captureAndProcessImage();

      // Flexible expectation to handle dynamic filenames
      expect(imagePath, allOf(contains('/mock/directory/'), endsWith('.jpg')));

      // Verify interactions
      verify(mockController.takePicture()).called(1);
      verify(mockFile.readAsBytesSync()).called(1);
      verify(mockFile.writeAsBytesSync(any)).called(1);
      verify(mockImageDecoder.decodeImage(testBytes)).called(1);
      verify(mockImageDecoder.copyResize(mockImage, width: 640, height: 480))
          .called(1);
    });
  });

  group('sendImageAndHandleResponse', () {
    test('should handle successful response', () async {
      final mockFilePath = '/mock/directory/image.jpg'; // Mock file path
      final mockEndpoint = 'http://mock.endpoint'; // Mock endpoint

      // Create a mock MultipartFile
      final mockMultipartFile = MockMultipartFile();

      // Mock the behavior of MultipartFile
      when(mockMultipartFile.contentType)
          .thenReturn(MediaType('image', 'jpeg'));
      when(mockMultipartFile.filename).thenReturn('image.jpg');
      when(mockMultipartFile.field).thenReturn('file');
      when(mockMultipartFile.length).thenReturn(1024); // Mock file length here

      // Mock the HTTP client behavior to return a mock response
      final mockResponseStream = Stream<List<int>>.fromIterable(
          [utf8.encode('{"results": {"message": ["object1", "object2"]}}')]);
      final mockResponse = http.StreamedResponse(mockResponseStream, 200);

      // Mock sending the request
      when(mockHttpClient.send(any)).thenAnswer((_) async => mockResponse);

      // Mock the File class methods
      final mockFile = MockFile();
      when(mockFile.lengthSync()).thenReturn(1024); // Mock file length
      when(mockFile.path).thenReturn(mockFilePath); // Mock the file path

      // Mock the MultipartFileWrapper fromPath behavior to return a mock MultipartFile
      when(mockMultipartFileWrapper.fromPath('file', mockFilePath))
          .thenAnswer((_) async => mockMultipartFile);

      // Mock the files property of MockMultipartRequest
      when(mockMultipartRequest.files).thenReturn([mockMultipartFile]);

      // Inject the mock File into the picture service if needed (ensure mockFile is used)
      pictureService.fileFactory = (path) => mockFile;

      // Call the function
      await pictureService.sendImageAndHandleResponse(
        mockFilePath,
        mockEndpoint,
        (labels) {
          expect(labels, ['object1', 'object2']);
        },
        (responseTime) {
          // You can add assertions for response time if needed
        },
        mockHttpClient,
      );

      // Verify the expected interactions
      verify(mockHttpClient.send(any))
          .called(1); // Ensure `send` is called once
    });

    test('should handle failed response', () async {
      // Create a mock failed response stream
      final mockResponseStream = Stream<List<int>>.empty();
      final mockResponse = http.StreamedResponse(mockResponseStream, 500);

      // Stub the 'send' method of MockClient to return the mock response
      when(mockHttpClient.send(any)).thenAnswer((_) async => mockResponse);

      // Create a mock MultipartFile
      final mockMultipartFile = MockMultipartFile();

      // Mock the behavior of MultipartFile
      when(mockMultipartFile.contentType)
          .thenReturn(MediaType('image', 'jpeg'));
      when(mockMultipartFile.filename).thenReturn('image.jpg');
      when(mockMultipartFile.field).thenReturn('file');
      when(mockMultipartFile.length).thenReturn(1024); // Mock file length here

      // Mock the files property of MockMultipartRequest
      when(mockMultipartRequest.files).thenReturn([mockMultipartFile]);

      // Stub the 'fromPath' method in MultipartFileWrapper to return a mocked MultipartFile
      when(mockMultipartFileWrapper.fromPath('file', any))
          .thenAnswer((_) async {
        return mockMultipartFile;
      });

      // Ensure the path and file behavior are set up
      final mockFile = MockFile();
      when(mockFile.lengthSync()).thenReturn(1024); // Mock file length
      when(mockFile.path)
          .thenReturn('/mock/directory/mock_image.jpg'); // Stub for path

      // Ensure fileFactory is mocked correctly
      pictureService.fileFactory = (path) => mockFile;

      // Inject the mock HTTP client into the pictureService instance
      pictureService.httpClient = mockHttpClient; // Set the mock client here

      // Add debugging print statements here to confirm the method call
      final detectedObjects = <dynamic>[];
      final responseTimes = <Duration>[];

      // Call the method you're testing
      await pictureService.sendImageAndHandleResponse(
        mockFile.path,
        'http://mock.endpoint', // Mock endpoint
        (objects) => detectedObjects.addAll(objects),
        (duration) => responseTimes.add(duration),
        mockHttpClient,
      );

      // Check that the HTTP client send method was actually called
      verify(mockHttpClient.send(any)).called(1); // Verify send is called once

      // Assert that no objects are detected and no durations are added
      expect(detectedObjects, isEmpty);
      expect(responseTimes.length, 1);
      expect(responseTimes.first, isA<Duration>());
    });
  });
}
