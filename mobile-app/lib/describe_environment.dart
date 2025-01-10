import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'picture_service.dart';
import 'i_tts_service.dart';

class DescribeEnvironment extends StatelessWidget with Diagnosticable {
  /// The service used to take pictures.
  final PictureService pictureService;

  /// The service used to convert text to speech.
  final ITtsService ttsService;
  final String sessionToken;

  DescribeEnvironment(
      {super.key, required this.pictureService, required this.ttsService, required this.sessionToken});

  Future<void> _takeAndSendImage(BuildContext context) async {
    await pictureService.takePicture(
      endpoint: 'https://192.168.1.5:1880/describe?session_id=$sessionToken', // Pass the endpoint here
      onLabelsDetected: (labels) {
        print('Description: $labels');
        ttsService.speakLabels(labels); // Use ttsService to speak the labels
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

  @override
  void debugFillProperties(final DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
          DiagnosticsProperty<PictureService>('pictureService', pictureService))
      ..add(DiagnosticsProperty<dynamic>('ttsService', ttsService));
  }
}
