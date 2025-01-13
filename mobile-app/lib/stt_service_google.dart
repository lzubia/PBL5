import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'i_stt_service.dart';

class SttServiceGoogle implements ISttService {
  final String languageCode;
  late String _accessToken;

  SttServiceGoogle({this.languageCode = 'en-US'});

  Future<String> _getAccessToken() async {
    // Implement your logic to get the access token
    return _accessToken;
  }

  @override
  Future<void> initializeStt() async {
    // Initialize the service if needed
  }

  @override
  Future<void> startListening(Function(String) onResult) async {
    // Implement your logic to start listening and transcribe audio
  }

  @override
  void stopListening() {
    // Implement your logic to stop listening
  }

  @override
  void restartListening() {
    // Implement your logic to restart listening
  }

  Future<String> transcribeAudio(File audioFile) async {
    final token = await _getAccessToken();
    final bytes = await audioFile.readAsBytes();
    final base64Audio = base64Encode(bytes);

    final response = await http.post(
      Uri.parse("https://speech.googleapis.com/v1/speech:recognize"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "config": {
          "encoding": "LINEAR16",
          "sampleRateHertz": 16000,
          "languageCode": languageCode,
        },
        "audio": {
          "content": base64Audio,
        },
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final transcript =
          jsonResponse['results'][0]['alternatives'][0]['transcript'];
      return transcript;
    } else {
      throw Exception('Failed to transcribe audio');
    }
  }

  @override
  bool isListening() {
    // TODO: implement isListening
    throw UnimplementedError();
  }
}
