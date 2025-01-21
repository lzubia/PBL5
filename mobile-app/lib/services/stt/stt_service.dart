// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'i_stt_service.dart';

// class SttService implements ISttService {
//   late stt.SpeechToText speech;
//   bool isListening = false;
//   Function(String)? _onResultCallback;

//   @override
//   Future<void> initializeStt() async {
//     speech = stt.SpeechToText();
//     bool available = await speech.initialize(onStatus: handleStatus);
//     if (!available) {
//       print('ERROR: STT no disponible');
//     }
//   }

//   @override
//   Future<void> startListening(Function(String) onResult) async {
//     if (isListening) return; // Evita que se inicie si ya está escuchando.
//     _onResultCallback =
//         onResult; // Guarda la referencia de la función de callback
//     await speech.listen(
//       onResult: (result) {
//         onResult(result.recognizedWords.toLowerCase());
//       },
//     );
//     isListening = true; // Marca como escuchando.
//   }

//   @override
//   Future<void> stopListening() async {
//     if (isListening) {
//       isListening = false;
//       speech.stop();
//     }
//   }

//   void restartListening() async {
//     if (isListening) {
//       speech.stop(); // Detén la escucha actual
//       isListening = false; // Marca como no escuchando
//     }

//     // Esperamos un breve momento para asegurarnos de que la escucha se ha detenido
//     await Future.delayed(Duration(milliseconds: 200));

//     if (_onResultCallback != null) {
//       await startListening(
//           _onResultCallback!); // Reinicia la escucha con la función de callback guardada
//     }
//   }

//   void handleStatus(String status) {
//     // Si STT está en 'done' o 'notListening', reiniciamos la escucha
//     if (status == 'done' || status == 'notListening') {
//       restartListening();
//     }
//   }
// }

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
