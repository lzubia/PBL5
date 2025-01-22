import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../services/picture_service.dart';

class MoneyIdentifier extends StatefulWidget {
  const MoneyIdentifier({super.key});

  @override
  MoneyIdentifierState createState() => MoneyIdentifierState();
}

class MoneyIdentifierState extends State<MoneyIdentifier> {
  Timer? _timer;
  Duration responseTime = Duration.zero;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Start the periodic picture-taking process here
    if (_timer == null) {
      _startPeriodicPictureTaking();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicPictureTaking() {
    final ttsService = context.read<ITtsService>();

    ttsService.speakLabels(
        [AppLocalizations.of(context).translate("money-on")], context);
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _takeAndSendImage();
    });
  }

  Future<void> _takeAndSendImage({http.Client? client}) async {
    final pictureService = context.read<PictureService>();
    final ttsService = context.read<ITtsService>();
    final sessionToken = context.read<AppInitializer>().sessionToken;

    await pictureService.takePicture(
      httpClient: client,
      endpoint: dotenv.env["API_URL"]! + '5&session_id=${sessionToken}',
      onLabelsDetected: (labels) {
        ttsService.speakLabels(
            labels, context); // Use ttsService to speak the labels
      },
      onResponseTimeUpdated: (duration) {
        setState(() {
          responseTime = duration;
        });
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
        if (responseTime != Duration.zero)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Response Time: ${responseTime.inMilliseconds} ms'),
          ),
      ],
    );
  }
}
