import 'package:flutter/material.dart';
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
  ttsServiceGoogle.initializeTts();

  runApp(MyApp(
    pictureService: pictureService,
    ttsServiceGoogle: ttsServiceGoogle,
    databaseHelper: databaseHelper,
  ));
}

class MyApp extends StatelessWidget {
  final PictureService pictureService;
  final TtsServiceGoogle ttsServiceGoogle;
  final DatabaseHelper databaseHelper;

  const MyApp({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.databaseHelper,
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
        databaseHelper: databaseHelper,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final PictureService pictureService;
  final TtsServiceGoogle ttsServiceGoogle;
  final DatabaseHelper databaseHelper;

  const MyHomePage({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.databaseHelper,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BEGIA',
          style: TextStyle(fontSize: 24.0), // Increase font size
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 50.0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    ttsService: ttsServiceGoogle,
                    databaseHelper: databaseHelper,
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
              pictureService: pictureService,
              ttsServiceGoogle: ttsServiceGoogle,
            ),
          ),
          Expanded(
            child: GridMenu(pictureService: pictureService),
          ),
        ],
      ),
    );
  }
}
