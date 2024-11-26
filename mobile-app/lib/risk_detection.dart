import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'picture_service.dart';

class RiskDetection extends StatefulWidget {
  final CameraDescription camera;

  const RiskDetection({super.key, required this.camera});

  @override
  RiskDetectionState createState() => RiskDetectionState();
}

class RiskDetectionState extends State<RiskDetection> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  Duration responseTime = Duration.zero;
  FlutterTts flutterTts = FlutterTts();
  Timer? _timer;

  final PictureService _pictureService = PictureService();

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _controller = CameraController(
        widget.camera,
        ResolutionPreset.high,
      );

      await _controller.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    await _pictureService.takePicture(
      controller: _controller,
      onLabelsDetected: _speakLabels,
      onResponseTimeUpdated: (duration) {
        setState(() {
          responseTime = duration;
        });
      },
    );
  }

  Future<void> _speakLabels(List<dynamic> detectedObjects) async {
    for (var obj in detectedObjects) {
      String label = obj['label'];
      try {
        print("Speaking label: $label");
        await flutterTts.speak(label);
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print("TTS error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Column(
            children: [
              if (responseTime != Duration.zero)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Response Time: ${responseTime.inMilliseconds} ms'),
                ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 2.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 40.0),
                          Switch(
                            value: _timer?.isActive ?? false,
                            onChanged: (value) {
                              setState(() {
                                if (value) {
                                  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
                                    _takePicture();
                                  });
                                } else {
                                  _timer?.cancel();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}