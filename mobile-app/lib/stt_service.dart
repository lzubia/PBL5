import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'i_stt_service.dart';

class SttService implements ISttService {
  late stt.SpeechToText _speech;

  @override
  Future<void> initializeStt() async {
    _speech = stt.SpeechToText();
    await _speech.initialize();
  }

  @override
  Future<void> startListening(Function(String) onResult) async {
    await _speech.listen(onResult: (result) {
      onResult(result.recognizedWords.toLowerCase());
    });
  }

  @override
  void stopListening() {
    _speech.stop();
  }
}