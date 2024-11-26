import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'risk_detection.dart';
import 'grid_menu.dart';
import 'settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MyApp(camera: firstCamera));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      title: 'Risk Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(camera: camera),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final CameraDescription camera;

  const MyHomePage({super.key, required this.camera});

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
            child: RiskDetection(camera: camera),
          ),
          Expanded(
            child: GridMenu(),
          ),
        ],
      ),
    );
  }
}
