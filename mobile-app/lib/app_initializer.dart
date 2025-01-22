import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pbl5_menu/services/sos.dart';
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

  List<String> _widgetStates = [];

  List<String> get widgetStates => _widgetStates;
  late SosService sosService;

  // External dependency
  late PictureService pictureService;

  // State variables
  bool isInitialized = false;
  String initializationError = '';
  String sessionToken = '';
  Locale locale = const Locale('en', 'US');

  static const MethodChannel platform =
      MethodChannel('com.example.pbl5_menu/endSession');

  Future<void> initialize({required PictureService pictureService}) async {
    this.pictureService = pictureService; // Use the passed-in PictureService´

    try {
      // Ensure Flutter bindings
      WidgetsFlutterBinding.ensureInitialized();
      HttpOverrides.global = MyHttpOverrides();

      // Load environment variables
      await dotenv.load(fileName: "./.env");

      // MethodChannel setup
      platform.setMethodCallHandler((call) async {
        print("Method call received: ${call.method}");
        if (call.method == 'endSession') {
          await endSession(sessionToken);
        } else if (call.method == 'startSession') {
          await startSession();
        }
      });

      // Initialize database helper
      databaseHelper = DatabaseHelper();
      await databaseHelper
          .resetDatabase(); // Clear and reinitialize the database

      // Initialize TTS service with the database helper
      ttsServiceGoogle = TtsServiceGoogle(databaseHelper);
      ttsServiceGoogle.initializeTts();

      // Initialize dependencies
      await pictureService.setupCamera(); // Use the shared PictureService
      await pictureService
          .initializeCamera(); // Notify listeners on state change

      sttService = SttService();
      await sttService.initializeStt();

      // Initialize VoiceCommands
      voiceCommands = VoiceCommands(sttService);

      sosService = SosService(ttsServiceGoogle: ttsServiceGoogle);

      isInitialized = true; // Mark as initialized
    } catch (e) {
      initializationError = 'Initialization failed: $e';
      isInitialized = false;
    }
  }

  Future<void> startSession({http.Client? client}) async {
    final url = Uri.parse(dotenv.env["API_URL"]! + '1');
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
  }

  Future<void> endSession(String sessionId, {http.Client? client}) async {
    final url = Uri.parse(dotenv.env["API_URL"]! + '2&session_id=$sessionId');
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
