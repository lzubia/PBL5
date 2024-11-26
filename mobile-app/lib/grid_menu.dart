import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'describe_environment.dart';
import 'dart:async';

class GridMenu extends StatefulWidget {
  const GridMenu({super.key});

  @override
  _GridMenuState createState() => _GridMenuState();
}

class _GridMenuState extends State<GridMenu> {
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  bool isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await cameraController.initialize();
    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _showBottomSheet(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                if (title == 'Describe Environment' && isCameraInitialized)
                  Container(
                    height: 550,
                    child: DescribeEnvironment(cameraController: cameraController),
                  ),
                if (title == 'GPS (Map)')
                  Container(
                    height: 550,
                    //child: MapWidget(),
                  ),
                if (title != 'Describe Environment' && title != 'GPS (Map)')
                  Text('Content for $title goes here.'),
                // Add more content here as needed
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuOptions = [
      {'title': 'Describe Environment', 'icon': Icons.description},
      {'title': 'GPS (Map)', 'icon': Icons.map},
      {'title': 'Scanner (Read Texts, QRs, ...)', 'icon': Icons.qr_code_scanner},
      {'title': 'Money Identifier', 'icon': Icons.attach_money},
    ];

    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(menuOptions.length, (index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              _showBottomSheet(context, menuOptions[index]['title']);
            },
            child: Container(
              height: 150,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(menuOptions[index]['icon'], size: 50),
                    SizedBox(height: 10),
                    Text(
                      menuOptions[index]['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}