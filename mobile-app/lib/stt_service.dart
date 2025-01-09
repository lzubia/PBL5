import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'i_stt_service.dart';

class SttService implements ISttService {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  Future<void> initializeStt() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize();
    print("INFO: STT disponible: $available");
    if (!available) {
      print('ERROR: STT no disponible');
    }
  }

  @override
  Future<void> startListening(Function(String) onResult) async {
    stopListening(); // If already listening, stop and toggle
    print('INFO: Iniciando STT');
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords.toLowerCase());
      },
    );
  }

  void restartListening() {
    _speech.cancel();
  }

  @override
  void stopListening() {
    if (_isListening) {
      print('INFO: STT detenido');
      _isListening = false;
      _speech.stop();
    }
  }

  void _handleStatus(String status) {
    print('INFO: Estado del STT: $status');
    if (status == 'notListening' && _isListening) {
      // print('INFO: STT reiniciando...');
      startListening((_) {});
    }
  }
}
