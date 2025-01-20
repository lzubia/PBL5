import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:provider/provider.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import '../services/picture_service.dart';

class RiskDetection extends StatefulWidget {
  const RiskDetection({super.key});

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
    Provider.of<PictureService>(context, listen: false).disposeCamera();
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
    final ttsService = Provider.of<ITtsService>(context, listen: false);

    setState(() {
      isRiskDetectionEnabled = true;
      _timer = Timer.periodic(
        const Duration(milliseconds: 1500),
        (timer) {
          _takePicture();
        },
      );
    });
    ttsService.speakLabels([
      AppLocalizations.of(context).translate("risk-on"),
    ]);
  }

  void disableRiskDetection() {
    final ttsService = Provider.of<ITtsService>(context, listen: false);

    setState(() {
      isRiskDetectionEnabled = false;
      _timer?.cancel();
    });
    ttsService.speakLabels([
      AppLocalizations.of(context).translate("risk-off"),
    ]);
  }

  Future<void> _takePicture() async {
    final pictureService = Provider.of<PictureService>(context, listen: false);
    final sessionToken = AppInitializer().sessionToken; // Shared globally

    final endpoint =
        'https://begiapbl.duckdns.org:1880/detect?session_id=$sessionToken';

    await pictureService.takePicture(
      endpoint: endpoint,
      onLabelsDetected: (labels) {
        Provider.of<ITtsService>(context, listen: false).speakLabels(labels);
      },
      onResponseTimeUpdated: (duration) {
        setState(() {
          responseTime = duration;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pictureService = Provider.of<PictureService>(context);

    if (!pictureService.isCameraInitialized) {
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
