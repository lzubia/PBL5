import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbl5_menu/i_stt_service.dart';
import 'package:pbl5_menu/i_tts_service.dart';
import 'package:pbl5_menu/main.dart';
import 'picture_service.dart';

class RiskDetection extends StatefulWidget {
  final PictureService pictureService;
  final ITtsService ttsService; // Accepts either TtsService or TtsServiceGoogle
  final ISttService sttService; // Accepts either SttService or SttServiceGoogle

  const RiskDetection({
    super.key,
    required this.pictureService,
    required this.ttsService,
    required this.sttService,
  });

  @override
  RiskDetectionState createState() => RiskDetectionState();
}

class RiskDetectionState extends State<RiskDetection> {
  bool isRiskDetectionEnabled = false;
  Duration responseTime = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    widget.pictureService.disposeCamera();
    super.dispose();
  }

  void enableRiskDetection() {
    setState(() {
      isRiskDetectionEnabled = true;
      _timer = Timer.periodic(
        Duration(milliseconds: 1500),
        (timer) {
          _takePicture();
        },
      );
    });
    widget.ttsService.speakLabels(["Risk detection on"]);
  }

  void disableRiskDetection() {
    setState(() {
      isRiskDetectionEnabled = false;
      _timer?.cancel();
    });
    widget.ttsService.speakLabels(["Risk detection off"]);
  }

  Future<void> _takePicture() async {
  final endpoint = 'http://192.168.1.2:1880/detect?session_id=7f3a0340-9cfb-4aa4-a03a-1083203d257e'; // Incluye el sessionToken en la URL

  await widget.pictureService.takePicture(
    endpoint: endpoint, // Usa el endpoint con el sessionToken
    onLabelsDetected: (labels) => widget.ttsService.speakLabels(labels),
    onResponseTimeUpdated: (duration) {
      setState(() {
        responseTime = duration;
      });
    },
  );
}

  @override
  Widget build(BuildContext context) {
    if (!widget.pictureService.isCameraInitialized) {
      return Container();
    }

    return Material(
      child: Column(
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 40.0),
                          Switch(
                            value: isRiskDetectionEnabled,
                            onChanged: (value) {
                              if (value) {
                                enableRiskDetection();
                              } else {
                                disableRiskDetection();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}