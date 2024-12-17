import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/services.dart' show rootBundle;

class SttServiceGoogle {
  final String _authFilePath = 'assets/tts-english.json';
  String languageCode = 'en-US';

  SttServiceGoogle() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  /// Initializes the service (if needed for additional setup)
  void initializeStt() {
    // print("Google Speech-to-Text Service Initialized");
  }

  /// Reads the service account JSON file and gets the access token
  Future<String> _getAccessToken() async {
    final serviceAccount =
        json.decode(await rootBundle.loadString(_authFilePath));
    final now = DateTime.now();
    final expiry = now.add(Duration(hours: 1));

    // Create the JWT
    final jwt = JWT(
      {
        "iss": serviceAccount['client_email'],
        "scope": "https://www.googleapis.com/auth/cloud-platform",
        "aud": "https://oauth2.googleapis.com/token",
        "iat": now.millisecondsSinceEpoch ~/ 1000,
        "exp": expiry.millisecondsSinceEpoch ~/ 1000,
      },
    );

    // Sign the JWT using the service account private key
    final privateKey = RSAPrivateKey(serviceAccount['private_key']);
    final token = jwt.sign(privateKey, algorithm: JWTAlgorithm.RS256);

    // Exchange JWT for Access Token
    final response = await http.post(
      Uri.parse("https://oauth2.googleapis.com/token"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
        "assertion": token,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch access token: ${response.body}");
    }

    return json.decode(response.body)['access_token'];
  }

  /// Sends audio to Google Speech-to-Text API and returns the transcribed text
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

    if (response.statusCode != 200) {
      throw Exception("Error from Speech-to-Text API: ${response.body}");
    }

    final transcript = json.decode(response.body)['results'][0]['alternatives'][0]['transcript'];
    return transcript;
  }
}