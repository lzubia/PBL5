import 'package:flutter/material.dart';
import 'package:googleapis/apigeeregistry/v1.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'dart:async';
import '../services/picture_service.dart';

class MoneyIdentifier extends StatefulWidget {
  final PictureService pictureService;
  final ITtsService ttsService;
  final String sessionToken;

  BuildContext context;

  MoneyIdentifier(
      {super.key,
      required this.pictureService,
      required this.ttsService,
      required this.sessionToken,
      required this.context});

  @override
  MoneyIdentifierState createState() => MoneyIdentifierState(this.context);
}

class MoneyIdentifierState extends State<MoneyIdentifier> {
  Timer? _timer;
  Duration responseTime = Duration.zero;
  BuildContext context;

  MoneyIdentifierState(this.context);

  @override
  void initState() {
    super.initState();
    _startPeriodicPictureTaking();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setContext(BuildContext context) {
    this.context = context;
  }

  void _startPeriodicPictureTaking() {
    widget.ttsService
        .speakLabels([AppLocalizations.of(context).translate("money-on")]);
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _takeAndSendImage();
    });
  }

  Future<void> _takeAndSendImage() async {
    await widget.pictureService.takePicture(
      endpoint:
          'https://begiapbl.duckdns.org:1880/money?session_id=${widget.sessionToken}', // Pass the endpoint here
      onLabelsDetected: (labels) {
        print('Money Identified: $labels');
        widget.ttsService
            .speakLabels(labels); // Use ttsService to speak the labels
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Money Identified: $labels')),
        );
      },
      onResponseTimeUpdated: (duration) {
        setState(() {
          responseTime = duration;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Response time: $duration')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pictureService.isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(child: widget.pictureService.getCameraPreview()),
        if (responseTime != Duration.zero)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Response Time: ${responseTime.inMilliseconds} ms'),
          ),
      ],
    );
  }
}
