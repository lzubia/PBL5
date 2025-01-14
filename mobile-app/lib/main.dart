import 'dart:convert';
import 'dart:io';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/describe_environment.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/services/stt/stt_service_google.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/services/stt/i_stt_service.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/settings_screen.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/tts/tts_service.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:audioplayers/audioplayers.dart'; // For audio playback

String sessionToken = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //txapar
  HttpOverrides.global = MyHttpOverrides();

  const platform = MethodChannel('com.example.pbl5_menu/endSession');
  platform.setMethodCallHandler((call) async {
    if (call.method == 'endSession') {
      await endSession(sessionToken);
    } else if (call.method == 'startSession') {
      await startSession();
    }
  });

  final pictureService = PictureService();
  await pictureService.setupCamera();
  await pictureService.initializeCamera();

  final databaseHelper = DatabaseHelper();
  final ttsServiceGoogle = TtsServiceGoogle(databaseHelper);
  final ttsService = TtsService(databaseHelper);
  final sttServiceGoogle =
      SttServiceGoogle(); // Initialize Speech-to-Text service
  final sttService = SttService(); // Initialize another Speech-to-Text service

  ttsServiceGoogle.initializeTts();
  ttsService.initializeTts();
  await sttServiceGoogle.initializeStt(); // Initialize STT service
  await sttService.initializeStt(); // Initialize another STT service
  await dotenv.load(fileName: "./.env");

  final GlobalKey<RiskDetectionState> _riskDetectionKey =
      GlobalKey<RiskDetectionState>();
  final GlobalKey<GridMenuState> _gridMenuKey = GlobalKey<GridMenuState>();
  final GlobalKey<MoneyIdentifierState> _moneyIdentifierKey =
      GlobalKey<MoneyIdentifierState>();
  final GlobalKey<DescribeEnvironmentState> _describeEnvironmentKey =
      GlobalKey<DescribeEnvironmentState>();
  final GlobalKey<OcrWidgetState> _ocrWidgetKey = GlobalKey<OcrWidgetState>();
  final GlobalKey<MapWidgetState> _mapKey = GlobalKey<MapWidgetState>();

  final voiceCommands = VoiceCommands(
      sttService,
      ttsService,
      _riskDetectionKey,
      _gridMenuKey,
      _moneyIdentifierKey,
      _describeEnvironmentKey,
      _ocrWidgetKey,
      _mapKey);

  runApp(MyApp(
    pictureService: pictureService,
    ttsServiceGoogle: ttsServiceGoogle,
    ttsService: ttsService,
    databaseHelper: databaseHelper,
    sttServiceGoogle: sttServiceGoogle, // Pass the STT service
    sttService: sttService, // Pass another STT service
    voiceCommands: voiceCommands,
    riskDetectionKey: _riskDetectionKey,
    gridMenuKey: _gridMenuKey,
    moneyIdentifierKey: _moneyIdentifierKey,
    describeEnvironmentKey: _describeEnvironmentKey,
    ocrWidgetKey: _ocrWidgetKey,
    mapKey: _mapKey,
  ));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> startSession({http.Client? client}) async {
  final url = Uri.parse('https://192.168.1.5:1880/start-session');
  client ??= http.Client();
  try {
    final response = await client.get(url);
    if (response.statusCode == 200) {
      sessionToken = jsonDecode(response.body)['session_id'];
      print('Session started successfully');
    } else {
      sessionToken = ''; // Reset sessionToken on failure
      print('Failed to start session: ${response.statusCode}');
    }
  } catch (e) {
    sessionToken = ''; // Reset sessionToken on error
    print('Error starting session: $e');
  }
}

Future<void> endSession(String sessionId, {http.Client? client}) async {
  final url =
      Uri.parse('https://192.168.1.5:1880/end-session?session_id=$sessionId');
  client ??= http.Client();
  try {
    final response = await client.delete(url);
    if (response.statusCode == 200) {
      print('Session ended successfully');
      print('Response: ${response.body}');
    } else if (response.statusCode == 404) {
      print('Session ID not found');
    } else {
      print('Failed to end session: ${response.statusCode}');
    }
  } catch (e) {
    print('Error ending session: $e');
  }
}

class MyApp extends StatelessWidget {
  final PictureService pictureService;
  final ITtsService ttsServiceGoogle;
  final ITtsService ttsService;
  final DatabaseHelper databaseHelper;
  final ISttService sttServiceGoogle;
  final ISttService sttService;
  final GlobalKey<RiskDetectionState> riskDetectionKey;
  final GlobalKey<GridMenuState> gridMenuKey;
  final GlobalKey<MoneyIdentifierState> moneyIdentifierKey;
  final GlobalKey<DescribeEnvironmentState> describeEnvironmentKey;
  final GlobalKey<OcrWidgetState> ocrWidgetKey;
  final GlobalKey<MapWidgetState> mapKey;
  final VoiceCommands voiceCommands;

  const MyApp({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.ttsService,
    required this.databaseHelper,
    required this.sttServiceGoogle,
    required this.sttService,
    required this.voiceCommands,
    required this.riskDetectionKey,
    required this.gridMenuKey,
    required this.moneyIdentifierKey,
    required this.describeEnvironmentKey,
    required this.ocrWidgetKey,
    required this.mapKey,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Risk Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        pictureService: pictureService,
        ttsServiceGoogle: ttsServiceGoogle,
        ttsService: ttsService,
        databaseHelper: databaseHelper,
        sttServiceGoogle: sttServiceGoogle,
        sttService: sttService,
        voiceCommands: voiceCommands,
        riskDetectionKey: riskDetectionKey,
        gridMenuKey: gridMenuKey,
        moneyIdentifierKey: moneyIdentifierKey,
        describeEnvironmentKey: describeEnvironmentKey,
        ocrWidgetKey: ocrWidgetKey,
        mapKey: mapKey,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final PictureService pictureService;
  final ITtsService ttsServiceGoogle;
  final ITtsService ttsService;
  final DatabaseHelper databaseHelper;
  final ISttService sttServiceGoogle;
  final ISttService sttService;
  final VoiceCommands voiceCommands;

  final GlobalKey<RiskDetectionState> riskDetectionKey;
  final GlobalKey<GridMenuState> gridMenuKey;
  final GlobalKey<MoneyIdentifierState> moneyIdentifierKey;
  final GlobalKey<DescribeEnvironmentState> describeEnvironmentKey;
  final GlobalKey<OcrWidgetState> ocrWidgetKey;
  final GlobalKey<MapWidgetState> mapKey;

  const MyHomePage({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.ttsService,
    required this.databaseHelper,
    required this.sttServiceGoogle,
    required this.sttService,
    required this.voiceCommands,
    required this.riskDetectionKey,
    required this.gridMenuKey,
    required this.moneyIdentifierKey,
    required this.describeEnvironmentKey,
    required this.ocrWidgetKey,
    required this.mapKey,
  });

  @override
  MyHomePageState createState() => MyHomePageState(
      riskDetectionKey: riskDetectionKey,
      gridMenuKey: gridMenuKey,
      moneyIdentifierKey: moneyIdentifierKey,
      describeEnvironmentKey: describeEnvironmentKey,
      ocrWidgetKey: ocrWidgetKey,
      mapKey: mapKey);
}

class MyHomePageState extends State<MyHomePage> {
  bool useGoogleStt = false;
  bool useGoogleTts = false;
  bool _isActivated =
      false; // Para verificar si el control de voz está activado
  final GlobalKey<RiskDetectionState> riskDetectionKey;
  final GlobalKey<GridMenuState> gridMenuKey;
  final GlobalKey<MoneyIdentifierState> moneyIdentifierKey;
  final GlobalKey<DescribeEnvironmentState> describeEnvironmentKey;
  final GlobalKey<OcrWidgetState> ocrWidgetKey;
  final GlobalKey<MapWidgetState> mapKey;

  MyHomePageState({
    required this.riskDetectionKey,
    required this.gridMenuKey,
    required this.moneyIdentifierKey,
    required this.describeEnvironmentKey,
    required this.ocrWidgetKey,
    required this.mapKey,
  });

  final player = AudioPlayer(); // Para reproducir sonidos de notificación

  @override
  void initState() {
    super.initState();
    widget.voiceCommands.setContext(context);
    widget.voiceCommands.loadVoiceCommands();
    widget.voiceCommands.startListening();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BEGIA', style: TextStyle(fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 50),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    ttsServiceGoogle: widget.ttsServiceGoogle,
                    ttsService: widget.ttsService,
                    databaseHelper: widget.databaseHelper,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RiskDetection(
              key: riskDetectionKey,
              pictureService: widget.pictureService,
              ttsService:
                  useGoogleTts ? widget.ttsServiceGoogle : widget.ttsService,
              sttService:
                  useGoogleStt ? widget.sttServiceGoogle : widget.sttService,
              sessionToken: sessionToken, // Pass sessionToken to RiskDetection
            ),
          ),
          Expanded(
            child: GridMenu(
              key: gridMenuKey,
              pictureService: widget.pictureService,
              ttsService:
                  useGoogleTts ? widget.ttsServiceGoogle : widget.ttsService,
              sessionToken: sessionToken, // Pass sessionToken to GridMenu
              moneyIdentifierKey: moneyIdentifierKey,
              describeEnvironmentKey: describeEnvironmentKey,
              ocrWidgetKey: ocrWidgetKey,
              mapKey: mapKey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: VoiceCommands.useVoiceControlNotifier,
                  builder: (context, useVoiceControl, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Voice Control: ${useVoiceControl ? "Enabled" : "Disabled"}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Switch(
                          key: const Key(
                              'voiceControlSwitch'), // Add a unique Key
                          value: useVoiceControl,
                          onChanged: (value) {
                            setState(() {
                              VoiceCommands.useVoiceControlNotifier.value =
                                  value;
                              if (value) {
                                _isActivated = true;
                                widget.voiceCommands.startListening();
                              } else {
                                _isActivated = false;
                                widget.voiceCommands.startListening();
                              }
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TTS Service: ${useGoogleTts ? "Google TTS" : "Demo TTS"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: useGoogleTts,
                      onChanged: (value) {
                        setState(() {
                          useGoogleTts = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STT Service: ${useGoogleStt ? "Google STT" : "Demo STT"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: useGoogleStt,
                      onChanged: (value) {
                        setState(() {
                          useGoogleStt = value;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
