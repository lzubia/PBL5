import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart';
import 'package:pbl5_menu/locale_provider.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:provider/provider.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';

class VoiceCommands extends ChangeNotifier {
  VoidCallback? onMenuCommand;
  ValueChanged<LatLng>? onMapSearchHome; // Updated to accept LatLng

  VoidCallback? onSosCommand;
  VoidCallback? onHomeCommand;
  bool _isActivated = false;
  bool riskTrigger = false; //state of risk detection
  int triggerVariable = 0; // trigger widget

  Timer? _commandTimer;
  Timer? get commandTimer => _commandTimer;
  set commandTimer(Timer? timer) {
    _commandTimer = timer;
    notifyListeners();
  }

  final SttService _sttService;
  late AudioPlayer player;

  final AppLocalizations? appLocalizations; // Injected for testing

  VoiceCommands(this._sttService,
      {AudioPlayer? audioPlayer, this.appLocalizations})
      : player = audioPlayer ?? AudioPlayer();

  bool get isActivated => _isActivated;

  void toggleActivation(bool value) {
    _isActivated = value;
    notifyListeners();

    if (_isActivated) {
      _sttService.startListening((result) {
        print("Voice command detected: $result");
      });
    } else {
      _sttService.stopListening();
    }
  }

  final Map<String, List<String>> voiceCommands = {};

  static final ValueNotifier<bool> useVoiceControlNotifier =
      ValueNotifier(false);

  String _command = '';
  String get command => _command;
  List<String> activationCommands = [];

  // Dependencies fetched from Provider
  late Locale locale;
  late SttService sttService;
  late ITtsService ttsServiceGoogle;

  // New dependency for managing widget states

  /// Initialize VoiceCommands with dependencies via Provider
  Future<void> initialize(BuildContext context) async {
    locale = Provider.of<LocaleProvider>(context, listen: false).currentLocale;
    sttService = Provider.of<SttService>(context, listen: false);
    ttsServiceGoogle = Provider.of<ITtsService>(context, listen: false);

    await loadActivationCommands();
    await loadVoiceCommands();
    startListening();
  }

  Future<void> loadVoiceCommands() async {
    final String fileName = 'assets/lang/${locale.languageCode}.json';
    final String fileContent = await rootBundle.loadString(fileName);
    final Map<String, dynamic> jsonContent = json.decode(fileContent);

    if (jsonContent.containsKey('voice_commands')) {
      final voiceCommandsMap = jsonContent['voice_commands'];
      if (voiceCommandsMap is Map) {
        voiceCommands.addAll(voiceCommandsMap.map(
          (key, value) => MapEntry(key,
              List<String>.from(value.map((cmd) => cmd.trim().toLowerCase()))),
        ));
      }
    }
  }

  Future<void> loadActivationCommands() async {
    final String fileContent =
        await rootBundle.loadString('assets/activation_commands.txt');
    activationCommands =
        fileContent.split('\n').map((cmd) => cmd.trim().toLowerCase()).toList();
  }

  void toggleVoiceControl() {
    useVoiceControlNotifier.value = !useVoiceControlNotifier.value;
    if (useVoiceControlNotifier.value) {
      _handleSpeechResult('begia');
    } else {
      _desactivateBegia();
      _playDesactivationSound();
      _sttService.stopListening();
      startListening();
    }
  }

  void startListening() async {
    await sttService.startListening(_handleSpeechResult);
  }

  void _handleSpeechResult(String recognizedText) {
    print('Texto reconocido: $recognizedText');
    if (_isActivated) {
      _command = recognizedText;
      handleCommand(_command);
    } else if (isActivationCommand(recognizedText)) {
      _isActivated = true;
      useVoiceControlNotifier.value = true;
      _command = '';
      playActivationSound();
      notifyListeners();
      _startCommandTimer();
      sttService.stopListening();
      startListening();
    } else {
      startListening();
    }
  }

  void _desactivateBegia() {
    _isActivated = false;
    useVoiceControlNotifier.value = false;
    _command = '';
    notifyListeners();
    sttService.stopListening();
  }

  void _startCommandTimer() {
    _cancelCommandTimer();
    _commandTimer = Timer(Duration(seconds: 10), () {
      _desactivateBegia();
    });
  }

  void _cancelCommandTimer() {
    if (_commandTimer != null && _commandTimer!.isActive) {
      _commandTimer!.cancel();
    }
  }

  bool isActivationCommand(String transcript) {
    return activationCommands.any((command) => transcript.contains(command));
  }

  Future<void> playActivationSound() async {
    await player.play(AssetSource('sounds/Begia-on.mp3'));
  }

  Future<void> _playDesactivationSound() async {
    await player.play(AssetSource('sounds/Begia-off.mp3'));
  }

  Future<void> handleCommand(String command) async {
    print('Activated command: $command');

    bool matched = false;
    bool matchedRisk = false;
    const double similarityThreshold = 80.0;

    for (var commandGroup in voiceCommands.entries) {
      final similarity = calculateSimilarity(command, commandGroup.value.first);

      if (similarity >= similarityThreshold ||
          commandGroup.value.any((synonym) => command.contains(synonym))) {
        final primaryCommand = commandGroup.key;

        switch (primaryCommand) {
          case 'risk_detection_command':
            riskTrigger = true;
            notifyListeners();
            _isActivated = false;
            useVoiceControlNotifier.value = false;
            _command = '';
            notifyListeners();
            sttService.stopListening();
            startListening();
            Future.delayed(Duration(seconds: 2), () {
              riskTrigger = false;
            });

            break;

          case 'money_identifier_command':
            matched = _executeCommand(1);
            break;

          case 'map_command':
            matched = _executeCommand(2);
            break;

          case 'menu_command':
            matched = true;
            if (onMenuCommand != null) {
              onMenuCommand!(); // Trigger the callback
            }
            // _cancelCommandTimer();
            // _desactivateBegia();
            break;

          case 'text_command':
            matched = _executeCommand(3);
            break;

          case 'photo_command':
            matched = _executeCommand(4);
            break;
          case 'sos_command':
            matched = true;
            if (onSosCommand != null) {
              onSosCommand!(); // Trigger the callback
            }
            break;
          case 'home_command':
            matched = true;
            if (onHomeCommand != null) {
              onHomeCommand!(); // Trigger the callback
            }
            break;
          default:
            break;
        }

        break;
      }
    }

    if (matched) {
      _cancelCommandTimer();
      _desactivateBegia();
    }
    startListening();
  }

  bool _executeCommand(int triggerVariable) {
    this.triggerVariable = triggerVariable;
    notifyListeners();
    _cancelCommandTimer();
    Future.delayed(Duration(seconds: 2), () {
      triggerVariable = 0; // Reset Trigger after the delay
    });

    return true;
  }

  double calculateSimilarity(String s1, String s2) {
    final words1 = s1.split(' ');
    final words2 = s2.split(' ');
    double highestSimilarity = 0.0;

    for (var word1 in words1) {
      for (var word2 in words2) {
        final distance = levenshteinDistance(word1, word2);
        final maxLength =
            word1.length > word2.length ? word1.length : word2.length;
        final similarity = 100.0 * (1 - distance / maxLength);
        if (similarity > highestSimilarity) {
          highestSimilarity = similarity;
        }
      }
    }

    return highestSimilarity;
  }

  int levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;
    final dp = List.generate(len1 + 1, (_) => List.filled(len2 + 1, 0));

    for (var i = 0; i <= len1; i++) {
      for (var j = 0; j <= len2; j++) {
        if (i == 0) {
          dp[i][j] = j;
        } else if (j == 0) {
          dp[i][j] = i;
        } else if (s1[i - 1] == s2[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 +
              [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]]
                  .reduce((a, b) => a < b ? a : b);
        }
      }
    }

    return dp[len1][len2];
  }
}
