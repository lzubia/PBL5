import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  late FlutterTts flutterTts;

  TtsService() {
    WidgetsFlutterBinding.ensureInitialized();
    flutterTts = FlutterTts();
  }

  void initializeTts() {
    flutterTts.setStartHandler(() {
      print("TTS started");
    });

    flutterTts.setCompletionHandler(() {
      print("TTS completed");
    });

    flutterTts.setErrorHandler((msg) {
      print("TTS error: $msg");
    });

    setTtsLanguage();
    checkTtsAvailability();
  }

  Future<void> setTtsLanguage() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(1);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> checkTtsAvailability() async {
    var languages = await flutterTts.getLanguages;
    print("Available languages: $languages");

    var isLanguageAvailable = await flutterTts.isLanguageAvailable("en-US");
    print("Is 'en-US' language available: $isLanguageAvailable");

    var engines = await flutterTts.getEngines;
    print("Available TTS engines: $engines");
  }

  Future<void> speakLabels(List<dynamic> detectedObjects) async {
    for (var obj in detectedObjects) {
      String label = obj; //['message'];
      try {
        print("Speaking label: $label");
        await flutterTts.speak(label);
        await flutterTts
            .awaitSpeakCompletion(true); // Ensure it finishes speaking
      } catch (e) {
        print("TTS error: $e");
      }
    }
  }
}