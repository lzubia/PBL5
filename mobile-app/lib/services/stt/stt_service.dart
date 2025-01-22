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
    if (_isListening) return; // Avoid starting if already listening
    _onResultCallback = onResult;
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords.toLowerCase());
      },
    );
    _isListening = true;
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
      _speech.stop(); // Stop current listening
      _isListening = false;
    }

    await Future.delayed(Duration(milliseconds: 200)); // Brief delay to reset
    if (_onResultCallback != null) {
      await startListening(_onResultCallback!);
    }
  }

  void _handleStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      restartListening(); // Restart listening when done
    }
  }
}
