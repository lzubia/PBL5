import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:pbl5_menu/features/describe_environment.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/services/l10n.dart';

class VoiceCommands extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();
  final Map<String, List<String>> voiceCommands = {};
  final Map<String, bool> widgetStates = {
    'map_command': false,
    'money_identifier_command': false,
    'text_command': false,
    'photo_command': false,
  };
  void toggleActivation(bool value) {
    isActivated = value;
    notifyListeners(); // Notify widgets to rebuild
  }

  bool isActivated = false;
  static final ValueNotifier<bool> useVoiceControlNotifier =
      ValueNotifier(false);
  String _command = '';
  List<String> activationCommands = [];

  late Locale locale;
  late SttService sttService;
  late TtsServiceGoogle ttsServiceGoogle;

  VoiceCommands();

  /// Initialize VoiceCommands with Locale, STT, and TTS Services
  Future<void> initialize(
      Locale locale, SttService stt, TtsServiceGoogle tts) async {
    this.locale = locale;
    this.sttService = stt;
    this.ttsServiceGoogle = tts;

    await loadActivationCommands();
    await loadVoiceCommands();
    startListening();
    notifyListeners();
  }

  Future<void> loadVoiceCommands() async {
    final String fileName = 'assets/lang/${locale.languageCode}.json';
    final String fileContent = await rootBundle.loadString(fileName);
    final Map<String, dynamic> jsonContent = json.decode(fileContent);

    if (jsonContent.containsKey('voice_commands')) {
      final voiceCommandsMap = jsonContent['voice_commands'];
      if (voiceCommandsMap is Map) {
        voiceCommands.addAll(voiceCommandsMap.map(
          (key, value) => MapEntry(
            key,
            List<String>.from(value.map((cmd) => cmd.trim().toLowerCase())),
          ),
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

  void startListening() async {
    await sttService.startListening(_handleSpeechResult);
  }

  void _handleSpeechResult(String recognizedText) {
    if (isActivated) {
      _command = recognizedText;
      _handleCommand(_command);
    } else if (_isActivationCommand(recognizedText)) {
      isActivated = true;
      useVoiceControlNotifier.value = true;
      _playActivationSound();
    } else {
      startListening();
    }
  }

  bool _isActivationCommand(String transcript) {
    return activationCommands.any((command) => transcript.contains(command));
  }

  void _handleCommand(String command) {
    bool matched = false;
    const double similarityThreshold = 80.0;

    for (var commandGroup in voiceCommands.entries) {
      final similarity = calculateSimilarity(command, commandGroup.value.first);

      if (similarity >= similarityThreshold ||
          commandGroup.value.any((synonym) => command.contains(synonym))) {
        final primaryCommand = commandGroup.key;

        switch (primaryCommand) {
          case 'risk_detection_command':
            matched = true;
            notifyListeners(); // Trigger UI updates for Risk Detection
            break;

          case 'money_identifier_command':
            matched = _handleMoneyIdentifierCommand();
            break;

          case 'map_command':
            matched = _handleMapCommand();
            break;

          case 'menu_command':
            matched = true;
            ttsServiceGoogle.speakLabels([
              AppLocalizations.of(context as BuildContext).translate("menu"),
            ]);
            break;

          case 'text_command':
            matched = true;
            notifyListeners(); // Handle Text Commands UI Logic
            break;

          case 'photo_command':
            matched = _handlePhotoCommand();
            break;

          default:
            break;
        }

        break;
      }
    }

    if (!matched) {
      startListening();
    } else {
      isActivated = false;
      useVoiceControlNotifier.value = false;
    }
  }

  bool _handleMoneyIdentifierCommand() {
    if (!widgetStates['money_identifier_command']!) {
      widgetStates['money_identifier_command'] = true;
      notifyListeners();
      return true;
    } else {
      ttsServiceGoogle.speakLabels(['Money Identifier is already open']);
      return false;
    }
  }

  bool _handleMapCommand() {
    if (!widgetStates['map_command']!) {
      widgetStates['map_command'] = true;
      notifyListeners();
      return true;
    } else {
      ttsServiceGoogle.speakLabels(['Map is already open']);
      return false;
    }
  }

  bool _handlePhotoCommand() {
    notifyListeners(); // Handle photo logic here if needed
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

  Future<void> _playActivationSound() async {
    await player.play(AssetSource('sounds/activation_sound.mp3'));
  }
}
