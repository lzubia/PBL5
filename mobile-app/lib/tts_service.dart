import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _initializeTts();
  }

  void _initializeTts() {
    _flutterTts.setStartHandler(() {
      print("TTS started");
    });

    _flutterTts.setCompletionHandler(() {
      print("TTS completed");
    });

    _flutterTts.setErrorHandler((msg) {
      print("TTS error: $msg");
    });

    _setTtsLanguage();
    _checkTtsAvailability();
  }

  Future<void> _setTtsLanguage() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _checkTtsAvailability() async {
    var languages = await _flutterTts.getLanguages;
    print("Available languages: $languages");

    var isLanguageAvailable = await _flutterTts.isLanguageAvailable("en-US");
    print("Is 'en-US' language available: $isLanguageAvailable");

    var engines = await _flutterTts.getEngines;
    print("Available TTS engines: $engines");
  }

  Future<void> speakLabels(List<dynamic> detectedObjects) async {
    for (var obj in detectedObjects) {
      String label = obj['label'];
      try {
        print("Speaking label: $label");
        await _flutterTts.speak(label);
        await Future.delayed(const Duration(seconds: 1));
      } catch (e) {
        print("TTS error: $e");
      }
    }
  }
}
