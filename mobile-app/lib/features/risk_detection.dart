import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:provider/provider.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import '../services/picture_service.dart';
import 'package:http/http.dart' as http;

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

    // Directly use the riskTrigger to enable/disable risk detection
    if (voiceCommands.riskTrigger && !isRiskDetectionEnabled) {
      enableRiskDetection();
    } else if (voiceCommands.riskTrigger && isRiskDetectionEnabled) {
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

    ttsService.speakLabels([AppLocalizations.of(context).translate("risk-on")]);
  }

  void disableRiskDetection() {
    final ttsService = Provider.of<ITtsService>(context, listen: false);

    setState(() {
      isRiskDetectionEnabled = false;
      _timer?.cancel();
    });
    ttsService
        .speakLabels([AppLocalizations.of(context).translate("risk-off")]);
  }

  Future<void> _takePicture({http.Client? client}) async {
    final pictureService = Provider.of<PictureService>(context, listen: false);
    final appInitializer = Provider.of<AppInitializer>(context, listen: false);

    final sessionToken = appInitializer.sessionToken;

    final endpoint = dotenv.env["API_URL"]! + '3&session_id=${sessionToken}';

    await pictureService.takePicture(
      httpClient: client,
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
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 4.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 70.0),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 16.0), // Adjust the padding value as needed
                      child: Transform.scale(
                        scale: 1.5,
                        child: Switch(
                          value: isRiskDetectionEnabled,
                          onChanged: (value) {
                            if (value) {
                              enableRiskDetection();
                            } else {
                              disableRiskDetection();
                            }
                          },
                        ),
                      ),
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
