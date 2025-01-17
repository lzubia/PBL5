import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/describe_environment.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:pbl5_menu/services/picture_service.dart';

class AppInitializer {
  static late final PictureService pictureService;
  static late final DatabaseHelper databaseHelper;
  static late final TtsServiceGoogle ttsServiceGoogle;
  static late final SttService sttService;
  static late final GlobalKey<RiskDetectionState> riskDetectionKey;
  static late final GlobalKey<GridMenuState> gridMenuKey;
  static late final GlobalKey<MoneyIdentifierState> moneyIdentifierKey;
  static late final GlobalKey<DescribeEnvironmentState> describeEnvironmentKey;
  static late final GlobalKey<OcrWidgetState> ocrWidgetKey;
  static late final GlobalKey<MapWidgetState> mapKey;
  static late final VoiceCommands voiceCommands;

  static String sessionToken = ''; // Add sessionToken as a static field
  static Locale locale = Locale('en', 'US');

  static const MethodChannel platform =
      MethodChannel('com.example.pbl5_menu/endSession');

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = MyHttpOverrides();

    // Configure MethodChannel for session management
    platform.setMethodCallHandler((call) async {
      if (call.method == 'endSession') {
        await endSession(sessionToken); // Pass sessionToken to endSession
      } else if (call.method == 'startSession') {
        await startSession();
      }
    });

    // Initialize services and dependencies
    pictureService = PictureService();
    databaseHelper = DatabaseHelper();
    ttsServiceGoogle = TtsServiceGoogle(databaseHelper);
    sttService = SttService();

    await pictureService.setupCamera();
    await pictureService.initializeCamera();
    ttsServiceGoogle.initializeTts();
    await dotenv.load(fileName: "./.env");
    await sttService.initializeStt();

    // Initialize global keys
    riskDetectionKey = GlobalKey<RiskDetectionState>();
    gridMenuKey = GlobalKey<GridMenuState>();
    moneyIdentifierKey = GlobalKey<MoneyIdentifierState>();
    describeEnvironmentKey = GlobalKey<DescribeEnvironmentState>();
    ocrWidgetKey = GlobalKey<OcrWidgetState>();
    mapKey = GlobalKey<MapWidgetState>();

    // Initialize VoiceCommands
    voiceCommands = VoiceCommands(
        sttService,
        ttsServiceGoogle,
        riskDetectionKey,
        gridMenuKey,
        moneyIdentifierKey,
        describeEnvironmentKey,
        ocrWidgetKey,
        mapKey,
        locale);

    // Start a session and set the sessionToken
    await startSession();
  }

  static Future<void> startSession({http.Client? client}) async {
    final url = Uri.parse('https://begiapbl.duckdns.org:1880/start-session');
    client ??= http.Client();
    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        sessionToken = jsonDecode(response.body)['session_id'];
        print('Session started successfully. Token: $sessionToken');
      } else {
        sessionToken = ''; // Reset sessionToken on failure
        print('Failed to start session: ${response.statusCode}');
      }
    } catch (e) {
      sessionToken = ''; // Reset sessionToken on error
      print('Error starting session: $e');
    }
  }

  static Future<void> endSession(String sessionId,
      {http.Client? client}) async {
    final url = Uri.parse(
        'https://begiapbl.duckdns.org:1880/end-session?session_id=$sessionId');
    client ??= http.Client();
    try {
      final response = await client.delete(url);
      if (response.statusCode == 200) {
        print('Session ended successfully');
        sessionToken = ''; // Reset sessionToken after session ends
      } else if (response.statusCode == 404) {
        print('Session ID not found');
      } else {
        print('Failed to end session: ${response.statusCode}');
      }
    } catch (e) {
      print('Error ending session: $e');
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
