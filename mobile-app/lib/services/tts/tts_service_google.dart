import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../../shared/database_helper.dart';
import '../stt/i_tts_service.dart';
import 'package:flutter/services.dart';

class TtsServiceGoogle implements ITtsService {
  late AudioPlayer audioPlayer;
  final String _authFilePath = 'assets/tts-english.json';
  final String _elhuyarFilePath = 'assets/tts-elhuyar.json';
  String languageCode = 'en-US';
  String voiceName = 'en-US-Wavenet-D';
  double speechRate = 1.6; // Default speech rate
  final DatabaseHelper _dbHelper;
  late String elhuyarApiId;
  late String elhuyarApiKey;
  final http.Client httpClient;
  final AssetBundle assetBundle;

  TtsServiceGoogle(this._dbHelper,
      {AudioPlayer? audioPlayer,
      http.Client? httpClient,
      AssetBundle? assetBundle})
      : httpClient = httpClient ?? http.Client(),
        assetBundle = assetBundle ?? rootBundle {
    WidgetsFlutterBinding.ensureInitialized();
    this.audioPlayer = audioPlayer ?? AudioPlayer(); // Allow mock injection
    loadSettings();
    _loadElhuyarCredentials();
  }

  @override
  Future<void> initializeTts() async {
    print("Google TTS Service Initialized");
  }

  Future<void> loadSettings() async {
    final settings = await _dbHelper.getTtsSettings();
    languageCode = settings['languageCode'] ?? 'en-US';
    voiceName = settings['voiceName'] ?? 'en-US-Wavenet-D';
    print("Loaded settings: languageCode=$languageCode, voiceName=$voiceName");
  }

  Future<void> _loadElhuyarCredentials() async {
    final String response = await rootBundle.loadString(_elhuyarFilePath);
    final data = json.decode(response);
    elhuyarApiId = data['api_id'];
    elhuyarApiKey = data['api_key'];
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
    if (newSpeechRate <= 0.0) {
      print("Invalid speech rate: $newSpeechRate. Using default value.");
      return; // Ignore invalid values
    }
    speechRate = newSpeechRate;
    print("Speech rate updated to $speechRate");
  }

  Future<String> getAccessToken() async {
    final serviceAccount =
        json.decode(await assetBundle.loadString(_authFilePath));
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

    final response = await httpClient.post(
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
  Future<void> speakLabels(
      List<dynamic> detectedObjects, BuildContext context) async {
    final token = await _getAccessToken();
    final locale = Localizations.localeOf(context).languageCode;

    for (var obj in detectedObjects) {
      String label = obj;
      try {
        print("Speaking label: $label");
        final response;
        if (locale == 'eu') {
          response = await http.post(
            Uri.parse("https://ttsneuronala.elhuyar.eus/api/standard"),
            headers: {
              "Content-Type": "application/json",
            },
            body: json.encode(
              {
                "text": label,
                "speaker": "female_low",
                "language": "eu",
                "extension": "mp3",
                "api_id": elhuyarApiId,
                "api_key": elhuyarApiKey
              },
            ),
          );
        } else {
          response = await http.post(
            Uri.parse("https://texttospeech.googleapis.com/v1/text:synthesize"),
            headers: {
              "Authorization": "Bearer $token",
              "Content-Type": "application/json",
            },
            body: json.encode({
              "input": {"text": label},
              "voice": {"languageCode": languageCode, "name": voiceName},
              "audioConfig": {
                "audioEncoding": "MP3",
                "speakingRate": speechRate
              },
            }),
          );
        }

        if (response.statusCode == 200) {
          final audioContent;
          final bytes;
          if (locale == 'eu') {
            bytes = response.bodyBytes;
          } else {
            audioContent = json.decode(response.body)['audioContent'];
            bytes = base64.decode(audioContent);
          }

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
