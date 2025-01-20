import 'package:flutter/material.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:provider/provider.dart';
import '../services/picture_service.dart';
import '../services/stt/i_tts_service.dart';

class DescribeEnvironment extends StatefulWidget {

  const DescribeEnvironment({super.key});

  @override
  DescribeEnvironmentState createState() => DescribeEnvironmentState();
}

class DescribeEnvironmentState extends State<DescribeEnvironment> {
  @override
  void initState() {
    super.initState();
  }


  Future<void> takeAndSendImage() async {
    final pictureService = context.read<PictureService>();
    final ttsService = context.read<ITtsService>();
    final sessionToken = context.read<AppInitializer>().sessionToken;
  
    await pictureService.takePicture(
      endpoint:
          'https://begiapbl.duckdns.org:1880/describe?session_id=${sessionToken}',
      onLabelsDetected: (labels) {
        ttsService.speakLabels(labels);
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
    final pictureService = Provider.of<PictureService>(context);

    if (!pictureService.isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Expanded(child: pictureService.getCameraPreview()),
        ElevatedButton(
          onPressed: () => takeAndSendImage(),
          child: const Text('Take and Send Image'),
        ),
      ],
    );
  }
}
