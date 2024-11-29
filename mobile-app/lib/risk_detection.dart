import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'picture_service.dart';
import 'tts_service.dart';

class RiskDetection extends StatefulWidget {
  final CameraDescription camera;

  const RiskDetection({super.key, required this.camera});

  @override
  _RiskDetectionState createState() => _RiskDetectionState();
}

class _RiskDetectionState extends State<RiskDetection> {
  late CameraController _controller;
  late TtsService _ttsService;
  Duration responseTime = Duration.zero;
  Timer? _timer;

  final PictureService _pictureService = PictureService();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _ttsService = TtsService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
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
      onLabelsDetected: _ttsService.speakLabels,
      onResponseTimeUpdated: (duration) {
        setState(() {
          responseTime = duration;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Container();
    }
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
  }
}