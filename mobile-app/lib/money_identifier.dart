import 'package:flutter/material.dart';
import 'package:pbl5_menu/i_tts_service.dart';
import 'package:pbl5_menu/tts_service.dart';
import 'dart:async';
import 'picture_service.dart';

class MoneyIdentifier extends StatefulWidget {
  final PictureService pictureService;
  final ITtsService ttsService;
  final String sessionToken;

  const MoneyIdentifier(
      {super.key, required this.pictureService, required this.ttsService, required this.sessionToken});
      
  @override
  MoneyIdentifierState createState() => MoneyIdentifierState();
}

class MoneyIdentifierState extends State<MoneyIdentifier> {
  Timer? _timer;
  Duration responseTime = Duration.zero;

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

  void _startPeriodicPictureTaking() {
    widget.ttsService.speakLabels(['Money Identifier on']);
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _takeAndSendImage();
    });
  }

  Future<void> _takeAndSendImage() async {
    await widget.pictureService.takePicture(
      endpoint: 'https://192.168.1.5:1880/money?session_id=${widget.sessionToken}', // Pass the endpoint here
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
