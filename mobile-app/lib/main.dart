import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pbl5_menu/stt_service_google.dart';
import 'package:pbl5_menu/tts_service_google.dart';
import 'package:pbl5_menu/stt_service.dart';
import 'package:pbl5_menu/i_stt_service.dart';
import 'package:pbl5_menu/i_tts_service.dart';
import 'risk_detection.dart';
import 'grid_menu.dart';
import 'settings_screen.dart';
import 'picture_service.dart';
import 'tts_service.dart';
import 'database_helper.dart';

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

  //await startSession();

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

  runApp(MyApp(
    pictureService: pictureService,
    ttsServiceGoogle: ttsServiceGoogle,
    ttsService: ttsService,
    databaseHelper: databaseHelper,
    sttServiceGoogle: sttServiceGoogle, // Pass the STT service
    sttService: sttService, // Pass another STT service
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

  const MyApp({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.ttsService,
    required this.databaseHelper,
    required this.sttServiceGoogle, // Add STT service
    required this.sttService, // Add another STT service
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Risk Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        pictureService: pictureService,
        ttsServiceGoogle: ttsServiceGoogle,
        ttsService: ttsService,
        databaseHelper: databaseHelper,
        sttServiceGoogle:
            sttServiceGoogle, // Pass the STT service to MyHomePage
        sttService: sttService, // Pass another STT service to MyHomePage
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

  const MyHomePage({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.ttsService,
    required this.databaseHelper,
    required this.sttServiceGoogle, // Add STT service
    required this.sttService, // Add another STT service
  });

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool useGoogleTts = false; // Default to false
  bool useGoogleStt = false; // Default to false
  bool useVoiceControl = false; // Default to false
  String detectedCommand = "";
  final GlobalKey<RiskDetectionState> _riskDetectionKey =
      GlobalKey<RiskDetectionState>();

  @override
  void initState() {
    super.initState();
    if (useVoiceControl) {
      _startListening();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _startListening() async {
    final sttService =
        useGoogleStt ? widget.sttServiceGoogle : widget.sttService;
    await sttService.startListening((transcript) {
      setState(() {
        detectedCommand = transcript;
      });
      _handleCommand(transcript);
    });
  }

  void _stopListening() {
    final sttService =
        useGoogleStt ? widget.sttServiceGoogle : widget.sttService;
    sttService.stopListening();
  }

  void _handleCommand(String command) {
    if (command.contains('risk detection on')) {
      _riskDetectionKey.currentState?.enableRiskDetection();
    } else if (command.contains('risk detection off') ||
        command.contains('risk detection of')) {
      _riskDetectionKey.currentState?.disableRiskDetection();
    } else {
      //widget.ttsService.speakLabels(["Command not recognized"]);
    }
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
              key: _riskDetectionKey,
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
              pictureService: widget.pictureService,
              ttsService:
                  useGoogleTts ? widget.ttsServiceGoogle : widget.ttsService,
              sessionToken: sessionToken, // Pass sessionToken to GridMenu
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Command: $detectedCommand',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(sessionToken),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Voice Control: ${useVoiceControl ? "Enabled" : "Disabled"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Switch(
                      key: const Key('voiceControlSwitch'), // Add a unique Key
                      value: useVoiceControl,
                      onChanged: (value) {
                        setState(() {
                          useVoiceControl = value;
                          if (useVoiceControl) {
                            _startListening();
                          } else {
                            _stopListening();
                          }
                        });
                      },
                    ),
                  ],
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