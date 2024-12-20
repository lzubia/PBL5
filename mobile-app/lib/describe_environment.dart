import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'picture_service.dart';
import 'i_tts_service.dart';

class DescribeEnvironment extends StatelessWidget with Diagnosticable {
  /// The service used to take pictures.
  final PictureService pictureService;

  /// The service used to convert text to speech.
  final ITtsService ttsService;

  DescribeEnvironment(
      {super.key, required this.pictureService, required this.ttsService});

  Future<void> _takeAndSendImage(BuildContext context) async {
    await pictureService.takePicture(
      endpoint: 'http://192.168.1.2:1880/describe', // Pass the endpoint here
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Describe Environment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async => _takeAndSendImage(context),
          child: const Text('Take Picture'),
        ),
      ),
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
