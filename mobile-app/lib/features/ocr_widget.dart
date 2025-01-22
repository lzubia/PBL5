import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/translation_provider.dart';
import 'package:provider/provider.dart';
import '../services/picture_service.dart';
import '../services/stt/i_tts_service.dart';
import 'package:http/http.dart' as http;

class OcrWidget extends StatefulWidget {
  const OcrWidget({super.key});

  @override
  OcrWidgetState createState() => OcrWidgetState();
}

class OcrWidgetState extends State<OcrWidget> {
  Future<void> takeAndSendImage({http.Client? client}) async {
    final pictureService = context.read<PictureService>();
    final ttsService = context.read<ITtsService>();
    final sessionToken = context.read<AppInitializer>().sessionToken;

    await pictureService.takePicture(
      httpClient: client,
      endpoint: dotenv.env["API_URL"]! + '6&session_id=${sessionToken}',
      onLabelsDetected: (labels) {
        Provider.of<TranslationProvider>(context, listen: false)
            .translateText(labels.first as String,
                Localizations.localeOf(context).languageCode)
            .then((translatedText) {
          ttsService.speakLabels([translatedText], context);
        });
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
