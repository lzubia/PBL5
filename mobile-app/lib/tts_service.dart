import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'database_helper.dart';

class TtsService {
  late FlutterTts flutterTts;
  String languageCode = 'en-US';
  double speechRate = 1.0;
  double pitch = 1.0;
  double volume = 1.0;
  final DatabaseHelper _dbHelper;

  TtsService(this._dbHelper) {
    WidgetsFlutterBinding.ensureInitialized();
    flutterTts = FlutterTts();
  }

  Future<void> initialize() async {
    await _loadSettings();
  }

  /// Initialize TTS with default or loaded settings
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

  /// Loads the language and TTS settings from the database
  Future<void> _loadSettings() async {
    final settings = await _dbHelper.getTtsSettings();
    languageCode = (settings['languageCode']?.isNotEmpty ?? false) ? settings['languageCode']! : 'en-US';
    speechRate = (settings['speechRate']?.isNotEmpty ?? false) ? double.tryParse(settings['speechRate']!) ?? 1.0 : 1.0;
    pitch = (settings['pitch']?.isNotEmpty ?? false) ? double.tryParse(settings['pitch']!) ?? 1.0 : 1.0;
    volume = (settings['volume']?.isNotEmpty ?? false) ? double.tryParse(settings['volume']!) ?? 1.0 : 1.0;

    print(
        "Loaded settings: languageCode=$languageCode, speechRate=$speechRate, pitch=$pitch, volume=$volume");

    await setTtsLanguage();
  }

  /// Updates the language and voice
  Future<void> updateLanguage(
      String newLanguageCode, String newVoiceName) async {
    bool isAvailable = await flutterTts.isLanguageAvailable(newLanguageCode);
    if (isAvailable) {
      languageCode = newLanguageCode;
      await _dbHelper.updateTtsSettings('languageCode', newLanguageCode);
      await _dbHelper.updateTtsSettings('voiceName', newVoiceName);
      await setTtsLanguage();
      print("Language updated to $languageCode with voice $newVoiceName");
    } else {
      print("Language $newLanguageCode is not available");
    }
  }

  /// Updates the speech rate
  Future<void> updateSpeechRate(double newSpeechRate) async {
    speechRate = newSpeechRate;
    await flutterTts.setSpeechRate(speechRate);
    await _dbHelper.updateTtsSettings('speechRate', newSpeechRate.toString());
    print("Speech rate updated to $speechRate");
  }

  /// Sets TTS language and other configurations
  Future<void> setTtsLanguage() async {
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setVolume(volume);
    await flutterTts.setPitch(pitch);
  }

  /// Checks TTS availability
  Future<void> checkTtsAvailability() async {
    var languages = await flutterTts.getLanguages;
    print("Available languages: $languages");

    var isLanguageAvailable =
        await flutterTts.isLanguageAvailable(languageCode);
    print("Is '$languageCode' language available: $isLanguageAvailable");

    var engines = await flutterTts.getEngines;
    print("Available TTS engines: $engines");
  }

  /// Speaks out detected labels
  Future<void> speakLabels(List<dynamic> detectedObjects) async {
    for (var obj in detectedObjects) {
      String label = obj; // Assuming obj is a string representing the label
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
