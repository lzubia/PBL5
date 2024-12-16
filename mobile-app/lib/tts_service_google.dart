import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'database_helper.dart';

class TtsServiceGoogle {
  late AudioPlayer audioPlayer;
  final String _authFilePath = 'assets/tts-english.json';
  String languageCode = 'en-US';
  String voiceName = 'en-US-Wavenet-D';
  double speechRate = 1.0; // Default speech rate
  final DatabaseHelper _dbHelper;

  TtsServiceGoogle(this._dbHelper) {
    WidgetsFlutterBinding.ensureInitialized();
    audioPlayer = AudioPlayer();
    _loadSettings();
  }

  /// Initializes the service (if needed for additional setup)
  void initializeTts() {
    print("Google TTS Service Initialized");
  }

  /// Loads the language and voice settings from the database
  Future<void> _loadSettings() async {
    final settings = await _dbHelper.getTtsSettings();
    languageCode = settings['languageCode']!;
    voiceName = settings['voiceName']!;
    print("Loaded settings: languageCode=$languageCode, voiceName=$voiceName");
  }

  /// Updates the language and voice
  void updateLanguage(String newLanguageCode, String newVoiceName) {
    languageCode = newLanguageCode;
    voiceName = newVoiceName;
    print("Language updated to $languageCode with voice $voiceName");
  }

  /// Updates the speech rate
  void updateSpeechRate(double newSpeechRate) {
    speechRate = newSpeechRate;
    print("Speech rate updated to $speechRate");
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

  /// Sends text to Google TTS API and plays the generated audio
  Future<void> speakLabels(List<dynamic> detectedObjects) async {
    final token = await _getAccessToken();

    for (var obj in detectedObjects) {
      String label = obj;
      try {
        print("Speaking label: $label");

        // Generate audio using Google TTS API
        final response = await http.post(
          Uri.parse("https://texttospeech.googleapis.com/v1/text:synthesize"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          body: json.encode({
            "input": {"text": label},
            "voice": {"languageCode": languageCode, "name": voiceName},
            "audioConfig": {"audioEncoding": "MP3", "speakingRate": speechRate},
          }),
        );

        if (response.statusCode == 200) {
          final audioContent = json.decode(response.body)['audioContent'];
          final bytes = base64.decode(audioContent);

          // Save MP3 file locally
          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/output.mp3');
          await file.writeAsBytes(bytes);

          // Play the audio
          await audioPlayer.play(DeviceFileSource(file.path));
        } else {
          print("Error from TTS API: ${response.body}");
        }
      } catch (e) {
        print("TTS error: $e");
      }
    }
  }
}
