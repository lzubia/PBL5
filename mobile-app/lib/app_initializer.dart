import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../services/picture_service.dart';
import '../shared/database_helper.dart';
import '../services/tts/tts_service_google.dart';
import '../services/stt/stt_service.dart';
import '../features/voice_commands.dart';

class AppInitializer {
  // Services and dependencies
  late DatabaseHelper databaseHelper;
  late TtsServiceGoogle ttsServiceGoogle;
  late SttService sttService;
  late VoiceCommands voiceCommands;

  // External dependency
  late PictureService pictureService;

  // State variables
  bool isInitialized = false;
  String initializationError = '';
  String sessionToken = '';
  Locale locale = const Locale('en', 'US');

  // static const MethodChannel platform = MethodChannel('com.example.pbl5_menu/endSession');

  Future<void> initialize({required PictureService pictureService}) async {
    this.pictureService = pictureService; // Use the passed-in PictureService

    try {
      // Ensure Flutter bindings
      WidgetsFlutterBinding.ensureInitialized();
      HttpOverrides.global = MyHttpOverrides();

//esto komentau
      // MethodChannel setup
      // platform.setMethodCallHandler((call) async {
      //   if (call.method == 'endSession') {
      //     await endSession(sessionToken);
      //   } else if (call.method == 'startSession') {
      //     await startSession();
      //   }
      // }
      // );
//esto komentau

      // Load environment variables
      await dotenv.load(fileName: "./.env");

      // Initialize database helper
      databaseHelper ??= DatabaseHelper();

      // Initialize TTS service with the database helper
      ttsServiceGoogle ??= TtsServiceGoogle(databaseHelper!);
      ttsServiceGoogle.initializeTts();

      // Initialize dependencies
      await pictureService.setupCamera(); // Use the shared PictureService
      await pictureService
          .initializeCamera(); // Notify listeners on state change

      sttService ??= SttService();
      await sttService.initializeStt();

      // Initialize VoiceCommands
      voiceCommands ??= VoiceCommands(sttService!);

      isInitialized = true; // Mark as initialized
    } catch (e) {
      initializationError = 'Initialization failed: $e';
      isInitialized = false;
    }
  }

  Future<void> startSession({http.Client? client}) async {
    //esto komentau
    final url = Uri.parse('https://begiapbl.duckdns.org:1880/start-session');
    client ??= http.Client();
    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        sessionToken = jsonDecode(response.body)['session_id'];
        print('Session started successfully. Token: $sessionToken');
      } else {
        sessionToken = '';
        throw Exception('Failed to start session: ${response.statusCode}');
      }
    } catch (e) {
      sessionToken = '';
      throw Exception('Error starting session: $e');
    }
    //esto komentau
  }

  Future<void> endSession(String sessionId, {http.Client? client}) async {
    //esto komentau
    final url = Uri.parse(
        'https://begiapbl.duckdns.org:1880/end-session?session_id=$sessionId');
    client ??= http.Client();
    try {
      final response = await client.delete(url);
      if (response.statusCode == 200) {
        print('Session ended successfully');
        sessionToken = '';
      } else {
        throw Exception('Failed to end session: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error ending session: $e');
    }
    //esto komentau
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
