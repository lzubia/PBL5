import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'i_stt_service.dart';

class SttService implements ISttService {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  Future<void> initializeStt() async {
    _speech = stt.SpeechToText();
    await _speech.initialize();
  }

  @override
  Future<void> startListening(Function(String) onResult) async {
    if (!_isListening) {
      _isListening = true;
      await _speech.listen(onResult: (result) {
        onResult(result.recognizedWords.toLowerCase());
      });
    }
  }

  @override
  void stopListening() {
    if (_isListening) {
      _isListening = false;
      _speech.stop();
    }
  }

  void restartListening() {
    stopListening();
    startListening((_) {});
  }

  /// Método para verificar si el sistema está escuchando actualmente
  @override
  bool isListening() {
    return _isListening;
  }
}
