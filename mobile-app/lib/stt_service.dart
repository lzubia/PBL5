import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'i_stt_service.dart';

class SttService implements ISttService {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  Future<void> initializeStt() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize();
    if (!available) {
      print('ERROR: STT no disponible');
    }
  }

  @override
  Future<void> startListening(Function(String) onResult) async {
    if (!_speech.isListening) {
      print('INFO: Iniciando STT');
      try {
        _isListening = true;
        await _speech.listen(onResult: (result) {
          onResult(result.recognizedWords.toLowerCase());
        });
      } catch (error) {
        print('ERROR: Error al iniciar STT: $error');
      }
    } else {
      print('INFO: STT ya está escuchando');
    }
  }

  @override
  void stopListening() {
    if (_isListening) {
      print('INFO: STT detenido');
      _isListening = false;
      _speech.stop();
    }
  }
}
