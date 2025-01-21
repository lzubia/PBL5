import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final voiceCommands = context.watch<VoiceCommands>();

    if (voiceCommands.riskTrigger && !isRiskDetectionEnabled) {
      enableRiskDetection();
    } else if (!voiceCommands.riskTrigger && isRiskDetectionEnabled) {
      disableRiskDetection();
    }
  }

  void enableRiskDetection() {
    final ttsService = Provider.of<ITtsService>(context, listen: false);

    setState(() {
      isRiskDetectionEnabled = true;
      _timer = Timer.periodic(
        const Duration(milliseconds: 1500),
        (_) => _takePicture(),
      );
    });

    ttsService.speakLabels(['Risk detection enabled']);
  }

  void disableRiskDetection() {
    final ttsService = Provider.of<ITtsService>(context, listen: false);

    setState(() {
      isRiskDetectionEnabled = false;
      _timer?.cancel();
    });

    ttsService.speakLabels(['Risk detection disabled']);
  }

  Future<void> _takePicture() async {
    final pictureService = Provider.of<PictureService>(context, listen: false);
    final sessionToken = AppInitializer().sessionToken;

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
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.warning, color: Colors.red, size: 40.0),
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
