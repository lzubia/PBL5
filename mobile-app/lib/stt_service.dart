import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'i_stt_service.dart';

class SttService implements ISttService {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  Future<void> initializeStt() async {
    _speech = stt.SpeechToText();
    bool available = await _speech.initialize(onStatus: _handleStatus);
    print("INFO: STT disponible: $available");
    if (!available) {
      print('ERROR: STT no disponible');
    }
  }

  @override
  Future<void> startListening(Function(String) onResult) async {
    if (_isListening) return; // Evita que se inicie si ya está escuchando.
    // stopListening(); // If already listening, stop and toggle
    print('INFO: Iniciando STT');
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
      print('INFO: STT detenido');
      _isListening = false;
      _speech.stop();
    }
  }

  // void restartListening() {
  //   _speech.cancel();
  // }

  void restartListening(Function(String) onResult) async {
    if (_isListening) {
      print('INFO: Deteniendo la escucha para reiniciar...');
      _speech.stop(); // Detén la escucha actual
      _isListening = false; // Marca como no escuchando
    }

    // Esperamos un breve momento para asegurarnos de que la escucha se ha detenido
    await Future.delayed(Duration(milliseconds: 200));

    print('INFO: Reiniciando STT...');
    await startListening(onResult); // Reinicia la escucha
  }

  // void _handleStatus(String status) {
  //   print('INFO: Estado del STT: $status');
  //   // Si STT está en 'notListening', reiniciamos la escucha.
  //   if (status == 'notListening' && _isListening) {
  //     print('INFO: Reiniciando STT...');
  //     startListening((_) {});
  //   }
  // }

  void _handleStatus(String status) {
    // Si STT está en 'done' o 'notListening', reiniciamos la escucha
    if (status == 'done' || status == 'notListening') {
      restartListening((text) {});
    }
  }
}
