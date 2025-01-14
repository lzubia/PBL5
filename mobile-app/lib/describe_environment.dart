import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'picture_service.dart';
import 'i_tts_service.dart';

class DescribeEnvironment extends StatefulWidget {
  final PictureService pictureService;
  final ITtsService ttsService;
  final String sessionToken;

  const DescribeEnvironment({
    super.key,
    required this.pictureService,
    required this.ttsService,
    required this.sessionToken,
  });

  @override
  DescribeEnvironmentState createState() => DescribeEnvironmentState();
}

class DescribeEnvironmentState extends State<DescribeEnvironment> {
  Future<void> takeAndSendImage() async {
    await widget.pictureService.takePicture(
      endpoint:
          'https://192.168.1.5:1880/describe?session_id=${widget.sessionToken}',
      onLabelsDetected: (labels) {
        widget.ttsService.speakLabels(labels);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Description: $labels')),
        );
      },
      onResponseTimeUpdated: (duration) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Response time: $duration')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: widget.pictureService.getCameraPreview()),
        ElevatedButton(
          onPressed: () => takeAndSendImage(),
          child: const Text('Take and Send Image'),
        ),
      ],
    );
  }
}
