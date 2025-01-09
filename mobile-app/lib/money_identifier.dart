import 'package:flutter/material.dart';
import 'dart:async';
import 'picture_service.dart';

class MoneyIdentifier extends StatefulWidget {
  final PictureService pictureService;
  final dynamic ttsService;
  final String sessionToken;

  MoneyIdentifier({required this.pictureService, required this.ttsService, required this.sessionToken});

  @override
  _MoneyIdentifierState createState() => _MoneyIdentifierState();
}

class _MoneyIdentifierState extends State<MoneyIdentifier> {
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
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      _takeAndSendImage();
    });
  }

  Future<void> _takeAndSendImage() async {
    await widget.pictureService.takePicture(
      endpoint: 'https://192.168.1.5:1880/money?session_id=${widget.sessionToken}', // Pass the endpoint here
      onLabelsDetected: (labels) {
        print('Money Identified: $labels');
        widget.ttsService.speakLabels(labels); // Use ttsService to speak the labels
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
      return Center(child: CircularProgressIndicator());
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