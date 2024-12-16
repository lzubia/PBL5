import 'package:flutter/material.dart';
import 'picture_service.dart';

class DescribeEnvironment extends StatelessWidget {
  final PictureService pictureService;

  DescribeEnvironment({required this.pictureService});

  Future<void> _takeAndSendImage(BuildContext context) async {
    await pictureService.takePicture(
      endpoint: 'http://192.168.1.2:1880/describe', // Pass the endpoint here
      onLabelsDetected: (labels) {
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
        Expanded(child: pictureService.getCameraPreview()),
        ElevatedButton(
          onPressed: () => _takeAndSendImage(context),
          child: Text('Take and Send Image'),
        ),
      ],
    );
  }
}