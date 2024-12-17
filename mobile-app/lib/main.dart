import 'package:flutter/material.dart';
import 'package:pbl5_menu/stt_service_google.dart';
import 'package:pbl5_menu/tts_service_google.dart';
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
  
  ttsServiceGoogle.initializeTts();
  ttsService.initializeTts();

  runApp(MyApp(
    pictureService: pictureService,
    ttsServiceGoogle: ttsServiceGoogle,
    ttsService: ttsService,
    databaseHelper: databaseHelper,
    sttServiceGoogle: sttServiceGoogle, // Pass the STT service
  ));
}

class MyApp extends StatelessWidget {
  final PictureService pictureService;
  final TtsServiceGoogle ttsServiceGoogle;
  final TtsService ttsService;
  final DatabaseHelper databaseHelper;
  final SttServiceGoogle sttServiceGoogle;

  const MyApp({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.ttsService,
    required this.databaseHelper,
    required this.sttServiceGoogle, // Add STT service
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
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final PictureService pictureService;
  final TtsServiceGoogle ttsServiceGoogle;
  final TtsService ttsService;
  final DatabaseHelper databaseHelper;
  final SttServiceGoogle sttServiceGoogle;

  const MyHomePage({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.ttsService,
    required this.databaseHelper,
    required this.sttServiceGoogle, // Add STT service
  });

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool useGoogleTts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CIEGOTRON 3000', style: TextStyle(fontSize: 24)),
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
              pictureService: widget.pictureService,
              ttsService: useGoogleTts
                  ? widget.ttsServiceGoogle
                  : widget.ttsService,
              sttServiceGoogle: widget.sttServiceGoogle, // Pass the STT service
            ),
          ),
          Expanded(
            child: GridMenu(pictureService: widget.pictureService),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
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
          ),
        ],
      ),
    );
  }
}