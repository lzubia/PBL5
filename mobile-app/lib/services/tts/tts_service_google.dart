import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../shared/database_helper.dart';
import '../stt/i_tts_service.dart';

class TtsServiceGoogle implements ITtsService {
  late AudioPlayer audioPlayer;
  final String _authFilePath = 'assets/tts-english.json';
  String languageCode = 'en-US';
  String voiceName = 'en-US-Wavenet-D';
  double speechRate = 1.6; // Default speech rate
  final DatabaseHelper _dbHelper;

  TtsServiceGoogle(this._dbHelper) {
    WidgetsFlutterBinding.ensureInitialized();
    audioPlayer = AudioPlayer();
    loadSettings();
  }

  @override
  Future<void> initializeTts() async {
    print("Google TTS Service Initialized");
  }

  Future<void> loadSettings() async {
    final settings = await _dbHelper.getTtsSettings();
    languageCode = settings['languageCode']!;
    voiceName = settings['voiceName']!;
    print("Loaded settings: languageCode=$languageCode, voiceName=$voiceName");
  }

  @override
  Future<void> updateLanguage(
      String newLanguageCode, String newVoiceName) async {
    languageCode = newLanguageCode;
    voiceName = newVoiceName;
    print("Language updated to $languageCode with voice $voiceName");
  }

  @override
  Future<void> updateSpeechRate(double newSpeechRate) async {
    speechRate = newSpeechRate;
    print("Speech rate updated to $speechRate");
  }

  Future<String> getAccessToken() async {
    final serviceAccount =
        json.decode(await rootBundle.loadString(_authFilePath));
    final now = DateTime.now();
    final expiry = now.add(const Duration(hours: 1));

    final jwt = JWT(
      {
        "iss": serviceAccount['client_email'],
        "scope": "https://www.googleapis.com/auth/cloud-platform",
        "aud": "https://oauth2.googleapis.com/token",
        "iat": now.millisecondsSinceEpoch ~/ 1000,
        "exp": expiry.millisecondsSinceEpoch ~/ 1000,
      },
    );

    final privateKey = RSAPrivateKey(serviceAccount['private_key']);
    final token = jwt.sign(privateKey, algorithm: JWTAlgorithm.RS256);

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

  @override
  Future<void> speakLabels(List<dynamic> detectedObjects) async {
    final token = await getAccessToken();

    for (var obj in detectedObjects) {
      String label = obj;
      try {
        print("Speaking label: $label");

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

          final tempDir = await getTemporaryDirectory();
          final file = File('${tempDir.path}/output.mp3');
          await file.writeAsBytes(bytes);

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
