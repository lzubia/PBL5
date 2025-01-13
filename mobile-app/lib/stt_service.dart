import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'i_stt_service.dart';

class SttService implements ISttService {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  Function(String)? _onResultCallback;

  @override
  Future<void> initializeStt() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(onStatus: _handleStatus);
    if (!available) {
      print('ERROR: STT no disponible');
    }
  }

  @override
  Future<void> startListening(Function(String) onResult) async {
    if (_isListening) return; // Evita que se inicie si ya está escuchando.
    _onResultCallback =
        onResult; // Guarda la referencia de la función de callback
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords.toLowerCase());
      },
    );
    _isListening = true; // Marca como escuchando.
  }

  @override
  void stopListening() {
    if (_isListening) {
      _isListening = false;
      _speech.stop();
    }
  }

  void restartListening() async {
    if (_isListening) {
      _speech.stop(); // Detén la escucha actual
      _isListening = false; // Marca como no escuchando
    }

    // Esperamos un breve momento para asegurarnos de que la escucha se ha detenido
    await Future.delayed(Duration(milliseconds: 200));

    if (_onResultCallback != null) {
      await startListening(
          _onResultCallback!); // Reinicia la escucha con la función de callback guardada
    }
  }

  void _handleStatus(String status) {
    // Si STT está en 'done' o 'notListening', reiniciamos la escucha
    if (status == 'done' || status == 'notListening') {
      restartListening();
    }
  }
}
