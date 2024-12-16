import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbl5_menu/stt_service_google.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'picture_service.dart';

class RiskDetection extends StatefulWidget {
  final PictureService pictureService;
  final dynamic ttsService; // Accepts either TtsService or TtsServiceGoogle
  final SttServiceGoogle sttServiceGoogle; // Add STT service as a parameter

  const RiskDetection({
    super.key,
    required this.pictureService,
    required this.ttsService,
    required this.sttServiceGoogle,
  });

  @override
  _RiskDetectionState createState() => _RiskDetectionState();
}

class _RiskDetectionState extends State<RiskDetection> {
  late stt.SpeechToText _speech; // Speech-to-text instance
  bool _isListening = false; // Indicates if speech recognition is active
  String detectedCommand = "";
  bool isRiskDetectionEnabled = false;
  Duration responseTime = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.pictureService.disposeCamera();
    super.dispose();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      setState(() {
        _isListening = true;
      });

      _speech.listen(
        onResult: (result) {
          final transcript = result.recognizedWords.toLowerCase();

          setState(() {
            detectedCommand = transcript;
          });

          // Process the command
          if (transcript.contains('risk detection on')) {
            _enableRiskDetection();
          } else if (transcript.contains('risk detection off')) {
            _disableRiskDetection();
          } else {
            widget.ttsService.speak("Command not recognized");
          }
        },
        localeId: 'en_US', // Change locale if necessary
      );
    } else {
      widget.ttsService.speak("Speech recognition is not available.");
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _takePicture() async {
    await widget.pictureService.takePicture(
      onLabelsDetected: (labels) => widget.ttsService.speakLabels(labels),
      onResponseTimeUpdated: (duration) {
        setState(() {
          responseTime = duration;
        });
      },
    );
  }

  void _enableRiskDetection() {
    setState(() {
      isRiskDetectionEnabled = true;
      _timer = Timer.periodic(
        Duration(milliseconds: 1500),
        (timer) {
          _takePicture();
        },
      );
    });
    widget.ttsService.speak("Risk detection enabled");
  }

  void _disableRiskDetection() {
    setState(() {
      isRiskDetectionEnabled = false;
      _timer?.cancel();
    });
    widget.ttsService.speak("Risk detection disabled");
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
                                _enableRiskDetection();
                              } else {
                                _disableRiskDetection();
                              }
                            },
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _isListening ? _stopListening : _startListening,
                        child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                      ),
                      if (detectedCommand.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Detected Command: $detectedCommand',
                            style: TextStyle(fontSize: 16, color: Colors.green),
                          ),
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