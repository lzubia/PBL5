import 'package:flutter/material.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../services/picture_service.dart';

class MoneyIdentifier extends StatefulWidget {
  const MoneyIdentifier({super.key});

  @override
  MoneyIdentifierState createState() => MoneyIdentifierState();
}

class MoneyIdentifierState extends State<MoneyIdentifier> {
  Timer? timer;
  Duration responseTime = Duration.zero;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Start the periodic picture-taking process here
    if (timer == null) {
      _startPeriodicPictureTaking();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void cancelTimer() {
    timer?.cancel();
  }

  void _startPeriodicPictureTaking() {
    final ttsService = context.read<ITtsService>();

    ttsService
        .speakLabels([AppLocalizations.of(context).translate("money-on")]);
    timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      takeAndSendImage();
    });
  }

  Future<void> takeAndSendImage() async {
    final pictureService = context.read<PictureService>();
    final ttsService = context.read<ITtsService>();
    final sessionToken = context.read<AppInitializer>().sessionToken;

    await pictureService.takePicture(
      endpoint:
          'https://begiapbl.duckdns.org:1880/money?session_id=${sessionToken}', // Pass the endpoint here
      onLabelsDetected: (labels) {
        print('Money Identified: $labels');
        ttsService.speakLabels(labels); // Use ttsService to speak the labels
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
