import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final pictureService = PictureService();
  await pictureService.setupCamera();
  await pictureService.initializeCamera();
  
  final databaseHelper = DatabaseHelper();
  final ttsServiceGoogle = TtsServiceGoogle(databaseHelper);
  final ttsService = TtsService(databaseHelper);
  final sttServiceGoogle = SttServiceGoogle(); // Initialize Speech-to-Text service
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
        sttServiceGoogle: sttServiceGoogle, // Pass the STT service to MyHomePage
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
  bool _isListening = false; // Indicates if speech recognition is active
  String detectedCommand = "";
  final GlobalKey<RiskDetectionState> _riskDetectionKey = GlobalKey<RiskDetectionState>();

  @override
  void initState() {
    super.initState();
    if (useVoiceControl) {
      _startListening();
    }
  }

  Future<void> _startListening() async {
    final sttService = useGoogleStt ? widget.sttServiceGoogle : widget.sttService;
    await sttService.startListening((transcript) {
      setState(() {
        detectedCommand = transcript;
      });
      _handleCommand(transcript);
    });

    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() {
    final sttService = useGoogleStt ? widget.sttServiceGoogle : widget.sttService;
    sttService.stopListening();
    setState(() {
      _isListening = false;
    });
  }

  void _handleCommand(String command) {
    if (command.contains('risk detection on')) {
      _riskDetectionKey.currentState?.enableRiskDetection();
    } else if (command.contains('risk detection off') || command.contains('risk detection of')) {
      _riskDetectionKey.currentState?.disableRiskDetection();
    } else if (command.contains('another command')) {
      // Handle another command
    } else {
      //widget.ttsService.speakLabels(["Command not recognized"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BEGIA', style: TextStyle(fontSize: 24)),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 50),
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
              ttsService: useGoogleTts
                  ? widget.ttsServiceGoogle
                  : widget.ttsService,
              sttService: useGoogleStt
                  ? widget.sttServiceGoogle
                  : widget.sttService, // Pass the appropriate STT service
            ),
          ),
          Expanded(
            child: GridMenu(
              pictureService: widget.pictureService,
              ttsService: useGoogleTts ? widget.ttsServiceGoogle : widget.ttsService,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  'Command: $detectedCommand',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Voice Control: ${useVoiceControl ? "Enabled" : "Disabled"}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Switch(
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
                      style: TextStyle(fontSize: 16),
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
                      style: TextStyle(fontSize: 16),
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