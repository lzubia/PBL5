import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_stt_service.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import '../services/picture_service.dart';

class RiskDetection extends StatefulWidget {
  final PictureService pictureService;
  final ITtsService ttsService; // Accepts either TtsService or TtsServiceGoogle
  final ISttService sttService; // Accepts either SttService or SttServiceGoogle
  final String sessionToken;

  const RiskDetection({
    super.key,
    required this.pictureService,
    required this.ttsService,
    required this.sttService,
    required this.sessionToken,
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

  void toggleRiskDetection() {
    if (isRiskDetectionEnabled) {
      disableRiskDetection();
    } else {
      enableRiskDetection();
    }
  }

  void enableRiskDetection() {
    setState(() {
      isRiskDetectionEnabled = true;
      _timer = Timer.periodic(
        const Duration(milliseconds: 1500),
        (timer) {
          _takePicture();
        },
      );
    });
    widget.ttsService
        .speakLabels([AppLocalizations.of(context).translate("risk-on")]);
  }

  void disableRiskDetection() {
    setState(() {
      isRiskDetectionEnabled = false;
      _timer?.cancel();
    });
    widget.ttsService
        .speakLabels([AppLocalizations.of(context).translate("risk-off")]);
  }

  Future<void> _takePicture() async {
    final endpoint =
        'https://192.168.1.5:1880/detect?session_id=${widget.sessionToken}';
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
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.warning,
                              color: Colors.red, size: 40.0),
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
