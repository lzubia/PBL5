import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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

  Future<void> takeAndSendImage({http.Client? client}) async {
    final pictureService = context.read<PictureService>();
    final ttsService = context.read<ITtsService>();
    final sessionToken = context.read<AppInitializer>().sessionToken;

    await pictureService.takePicture(
      httpClient: client,
      endpoint: dotenv.env["API_URL"]! + '4&session_id=${sessionToken}',
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
