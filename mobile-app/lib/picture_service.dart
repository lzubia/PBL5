import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageDecoder {
  img.Image? decodeImage(Uint8List bytes) {
    return img.decodeImage(bytes);
  }

  img.Image copyResize(img.Image image,
      {required int width, required int height}) {
    return img.copyResize(image, width: width, height: height);
  }
}

class MultipartFileWrapper {
  Future<http.MultipartFile> fromPath(String field, String filePath) {
    return http.MultipartFile.fromPath(field, filePath);
  }
}

typedef MultipartRequestFactory = http.MultipartRequest Function(
    String method, Uri url);

class PictureService {
  late CameraController controller;
  late http.Client httpClient;
  bool isCameraInitialized = false;
  late ImageDecoder imageDecoder; // Inject the decoder
  late MultipartFileWrapper multipartFileWrapper;

  PictureService({
    http.Client? httpClient,
    ImageDecoder? imageDecoder,
    MultipartFileWrapper? multipartFileWrapper,
    MultipartRequestFactory? multipartRequestFactory,
  }) {
    this.httpClient = httpClient ?? http.Client();
    this.imageDecoder = imageDecoder ?? ImageDecoder();
    this.multipartFileWrapper = multipartFileWrapper ?? MultipartFileWrapper();
    this.multipartRequestFactory = multipartRequestFactory ??
        (method, url) => http.MultipartRequest(method, url);
  }

  Future<void> setupCamera() async {
    try {
      final cameras = await availableCameras();
      controller = CameraController(cameras[0], ResolutionPreset.high);
    } catch (e) {
      print('Error setting up camera: $e');
    }
  }

  Future<void> initializeCamera() async {
    try {
      await controller.initialize();
      isCameraInitialized = true;
    } catch (e) {
      print('Error initializing camera: $e');
      isCameraInitialized = false;
    }
  }

  void disposeCamera() {
    if (isCameraInitialized) {
      controller.dispose();
      isCameraInitialized = false;
    }
  }

  Widget getCameraPreview() {
    if (isCameraInitialized) {
      return CameraPreview(controller);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Future<void> takePicture({
    required String endpoint,
    required Function(List<dynamic>) onLabelsDetected,
    required Function(Duration) onResponseTimeUpdated,
  }) async {
    try {
      final imagePath = await captureAndProcessImage();
      await sendImageAndHandleResponse(
          imagePath, endpoint, onLabelsDetected, onResponseTimeUpdated);
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  File Function(String path) fileFactory = (path) => File(path);

  Future<String> captureAndProcessImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '_')
        .replaceAll('.', '_');
    final imagePath = '${directory.path}/$timestamp.jpg';

    XFile picture = await controller.takePicture();
    final originalImage =
        imageDecoder.decodeImage(fileFactory(picture.path).readAsBytesSync())!;

    // Resize the image to 640x480
    final resizedImage =
        imageDecoder.copyResize(originalImage, width: 640, height: 480);

    // Save the resized image as JPEG
    fileFactory(imagePath).writeAsBytesSync(img.encodeJpg(resizedImage));

    return imagePath;
  }

  late MultipartRequestFactory multipartRequestFactory;

  Future<void> sendImageAndHandleResponse(
      String filePath,
      String endpoint,
      Function(List<String>) onDetectedObjects,
      Function(Duration) onResponseTime) async {
    print("sendImageAndHandleResponse called"); // Debug print
    final request = multipartRequestFactory('POST', Uri.parse(endpoint));

    // Add the image file to the request
    final file = await multipartFileWrapper.fromPath('file', filePath);
    request.files.add(file);

    final startTime = DateTime.now();
    final response =
        await httpClient.send(request); // Ensure this uses the mock httpClient
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    onResponseTime(duration);

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final detectedObjects = parseLabelsFromResponse(responseData);
      onDetectedObjects(detectedObjects);
    }
  }

  List<String> parseLabelsFromResponse(String responseBody) {
    // Parse the response body to extract labels
    final decodedJson = jsonDecode(responseBody);
    dynamic message;
    try {
      final result = decodedJson['results'];
      message = result['message'];
    } catch (e) {
      message = decodedJson['error'];
      print(message);
    }

    if (message is String) {
      // If the message is a single string, return it as a list with one element
      return [message];
    } else if (message is List) {
      // If the message is a list, return it as a list of strings
      return List<String>.from(message);
    } else {
      throw Exception('Unexpected response format');
    }
  }
}
