import 'package:flutter/material.dart';
import 'risk_detection.dart';
import 'grid_menu.dart';
import 'settings_screen.dart';
import 'picture_service.dart';
import 'tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pictureService = PictureService();
  await pictureService.setupCamera();
  await pictureService.initializeCamera();
  final ttsService = TtsService();
  ttsService.initializeTts();

  runApp(MyApp(pictureService: pictureService, ttsService: ttsService));
}

class MyApp extends StatelessWidget {
  final PictureService pictureService;
  final TtsService ttsService;

  const MyApp({super.key, required this.pictureService, required this.ttsService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Risk Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(pictureService: pictureService, ttsService: ttsService),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final PictureService pictureService;
  final TtsService ttsService;

  const MyHomePage({super.key, required this.pictureService, required this.ttsService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CIEGOTRON 3000',
          style: TextStyle(fontSize: 24.0), // Increase font size
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 50.0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RiskDetection(pictureService: pictureService, ttsService: ttsService),
          ),
          Expanded(
            child: GridMenu(pictureService: pictureService),
          ),
        ],
      ),
    );
  }
}
