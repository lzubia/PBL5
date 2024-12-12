import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbl5_menu/tts_service_google.dart';
import 'picture_service.dart';
import 'tts_service.dart';

class RiskDetection extends StatefulWidget {
  final PictureService pictureService;
  final TtsServiceGoogle ttsServiceGoogle;
  final TtsService ttsService;

  const RiskDetection({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.ttsService,
  });

  @override
  _RiskDetectionState createState() => _RiskDetectionState();
}

class _RiskDetectionState extends State<RiskDetection> {
  Duration responseTime = Duration.zero;
  Timer? _timer;
  String selectedLanguageCode = 'en-US'; // Default to English
  String selectedVoiceName = 'en-US-Wavenet-D'; // Default voice for English

  @override
  void dispose() {
    _timer?.cancel();
    widget.pictureService.disposeCamera();
    super.dispose();
  }

  Future<void> _takePicture() async {
    await widget.pictureService.takePicture(
      onLabelsDetected: (labels) => widget.ttsServiceGoogle.speakLabels(
        labels,
      ),
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
                            value: _timer?.isActive ?? false,
                            onChanged: (value) {
                              setState(() {
                                if (value) {
                                  _timer = Timer.periodic(
                                    Duration(milliseconds: 1500),
                                    (timer) {
                                      widget.ttsServiceGoogle.speakLabels(
                                        ['Risk Detected'],
                                      );
                                      //_takePicture();
                                    },
                                  );
                                } else {
                                  _timer?.cancel();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      // SizedBox(height: 16.0),
                      // Text('Select Language:', style: TextStyle(fontSize: 16)),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //   children: [
                      //     ElevatedButton(
                      //       onPressed: () {
                      //         setState(() {
                      //           selectedLanguageCode = 'en-US';
                      //           selectedVoiceName = 'en-US-Wavenet-D';
                      //         });
                      //       },
                      //       child: Text('English'),
                      //     ),
                      //     ElevatedButton(
                      //       onPressed: () {
                      //         setState(() {
                      //           selectedLanguageCode = 'es-ES';
                      //           selectedVoiceName = 'es-ES-Wavenet-B';
                      //         });
                      //       },
                      //       child: Text('Spanish'),
                      //     ),
                      //     ElevatedButton(
                      //       onPressed: () {
                      //         setState(() {
                      //           selectedLanguageCode = 'eu-ES';
                      //           selectedVoiceName = 'eu-ES-Wavenet-A';
                      //         });
                      //       },
                      //       child: Text('Basque'),
                      //     ),
                      //   ],
                      // ),
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