import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PictureService {
  Future<void> takePicture({
    required CameraController controller,
    required Function(List<dynamic>) onLabelsDetected,
    required Function(Duration) onResponseTimeUpdated,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '_')
          .replaceAll('.', '_');
      final imagePath = '${directory.path}/$timestamp.jpg';

      XFile picture = await controller.takePicture();
      final originalImage = img.decodeImage(File(picture.path).readAsBytesSync());

      // Resize the image to 640x480
      final resizedImage = img.copyResize(originalImage!, width: 640, height: 480);

      // Save the resized image as JPEG
      File(imagePath).writeAsBytesSync(img.encodeJpg(resizedImage));

      // Send the image to the endpoint
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.1.2:1880/process'),
      );
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imagePath,
      ));

      final startTime = DateTime.now();
      final response = await request.send();
      final endTime = DateTime.now();

      // Update response time
      onResponseTimeUpdated(endTime.difference(startTime));

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);
        print('Image uploaded successfully: $jsonResponse');

        // Pass detected objects to the callback
        List<dynamic> detectedObjects = jsonResponse['detected_objects'];
        onLabelsDetected(detectedObjects);
      } else {
        print('Image upload failed');
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }
}