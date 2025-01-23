import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'i_stt_service.dart';

class SttService implements ISttService {
  late stt.SpeechToText speech;
  bool isListening = false;
  Function(String)? _onResultCallback;

  SttService({stt.SpeechToText? speech})
      : speech = speech ?? stt.SpeechToText();

  @override
  Future<void> initializeStt() async {
    bool available = await speech.initialize(onStatus: handleStatus);
    if (!available) {
      print('ERROR: STT no disponible');
    }
  }

  @override
  Future<void> startListening(Function(String) onResult) async {
    if (isListening) return; // Avoid starting if already listening
    _onResultCallback = onResult;
    await speech.listen(onResult: (result) {
      if (result.finalResult) {
        _onResultCallback?.call(result.recognizedWords);
      }
    });
    isListening = true;
  }

  @override
  void stopListening() {
    if (!isListening) return; // Avoid stopping if not listening
    speech.stop();
    isListening = false;
  }

  void restartListening() {
    if (isListening) {
      stopListening();
    }
    if (_onResultCallback != null) {
      startListening(_onResultCallback!);
    }
  }

  void handleStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      restartListening();
    }
  }
}
