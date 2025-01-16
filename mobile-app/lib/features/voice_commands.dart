import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:googleapis/admob/v1.dart';
import 'package:pbl5_menu/features/describe_environment.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/services/l10n.dart';

class VoiceCommands {
  final AudioPlayer player = AudioPlayer();
  Map<String, List<String>> voiceCommands = {};
  bool _isActivated = false;
  // static bool useVoiceControl = false;
  static final ValueNotifier<bool> useVoiceControlNotifier =
      ValueNotifier(false);
  String _command = '';

  Locale locale;

  GlobalKey<RiskDetectionState> _riskDetectionKey =
      GlobalKey<RiskDetectionState>();
  GlobalKey<GridMenuState> _gridMenuKey = GlobalKey<GridMenuState>();
  GlobalKey<MoneyIdentifierState> _moneyIdentifierKey =
      GlobalKey<MoneyIdentifierState>();
  GlobalKey<DescribeEnvironmentState> _describeEnvironmentKey =
      GlobalKey<DescribeEnvironmentState>();
  GlobalKey<OcrWidgetState> _ocrWidgetKey = GlobalKey<OcrWidgetState>();
  GlobalKey<MapWidgetState> _mapKey = GlobalKey<MapWidgetState>();

  SttService sttService;
  TtsServiceGoogle ttsServiceGoogle;

  late BuildContext context;

  // Inside the class
  List<String> activationCommands = [];

  VoiceCommands(
      this.sttService,
      this.ttsServiceGoogle,
      this._riskDetectionKey,
      this._gridMenuKey,
      this._moneyIdentifierKey,
      this._describeEnvironmentKey,
      this._ocrWidgetKey,
      this._mapKey,
      this.locale) {
    loadActivationCommands();
    startListening();
  }

  void setContext(BuildContext context, Locale locale) {
    this.context = context;
    this.locale = locale;
    loadVoiceCommands();
  }

  Future<void> loadVoiceCommands() async {
    // final locale = Locale('en', 'EU');
    final String fileName = 'assets/lang/${locale.languageCode}.json';
    final String fileContent = await rootBundle.loadString(fileName);

    final Map<String, dynamic> jsonContent = json.decode(fileContent);

    if (jsonContent.containsKey('voice_commands')) {
      final voiceCommandsMap = jsonContent['voice_commands'];

      if (voiceCommandsMap is Map) {
        voiceCommands = voiceCommandsMap.map(
          (key, value) {
            return MapEntry(
              key,
              List<String>.from(value.map((cmd) => cmd.trim().toLowerCase())),
            );
          },
        );
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

  void stopListening() async {
    await sttService.stopListening();
  }

  void _handleSpeechResult(String recognizedText) {
    print('Texto reconocido: $recognizedText');
    if (_isActivated) {
      _command = recognizedText;
      _handleCommand(_command);
    } else if (_isActivationCommand(recognizedText)) {
      _isActivated = true;
      useVoiceControlNotifier.value = true;
      _activateVoiceControl();
    } else {
      startListening();
    }
  }

  bool _isActivationCommand(String transcript) {
    return activationCommands.any((command) => transcript.contains(command));
  }

  void _activateVoiceControl() {
    useVoiceControlNotifier.value = true;
    // Reproducir sonido de activación
    _playActivationSound();
  }

  Map<String, bool> widgetStates = {
    'GPS (Map)': false,
    'Money Identifier': false,
    // Add other widgets as needed
  };

  void _handleCommand(String command) {
    print('Activated command: $command');

    bool matched = false;
    const double similarityThreshold = 80.0;

    for (var commandGroup in voiceCommands.entries) {
      final similarity = calculateSimilarity(command, commandGroup.value.first);

      for (var synonym in commandGroup.value) {
        // Calculamos la similitud usando la distancia de Levenshtein
        if (similarity >= similarityThreshold || command.contains(synonym)) {
          final primaryCommand = commandGroup.key;

          switch (primaryCommand) {
            case 'risk_detection_command': // Comando principal del grupo de riesgo
              _riskDetectionKey.currentState?.toggleRiskDetection();
              matched = true;
              break;

            case 'money_identifier_command': // Comando principal del grupo de identificador de dinero
              if (!widgetStates['Money Identifier']!) {
                _gridMenuKey.currentState
                    ?.showBottomSheet(context!, 'Money Identifier');
                widgetStates['Money Identifier'] = true;
              } else {
                ttsServiceGoogle.speakLabels(
                    ['El identificador de dinero ya está abierto']);
              }
              matched = true;
              break;

            case 'map_command': // Comando principal del grupo de mapas
              if (!widgetStates['GPS (Map)']!) {
                _gridMenuKey.currentState
                    ?.showBottomSheet(context!, 'GPS (Map)');
                widgetStates['GPS (Map)'] = true;
              } else {
                ttsServiceGoogle.speakLabels(['El mapa ya está abierto']);
              }
              matched = true;
              break;

            case 'menu_command': // Comando principal del grupo de navegación a casa
              Navigator.popUntil(context!, (route) => route.isFirst);
              ttsServiceGoogle.speakLabels(
                  [AppLocalizations.of(context).translate("menu")]);
              matched = true;
              break;

            case 'text_command': // Comando principal del grupo de identificador de dinero
              _gridMenuKey.currentState
                  ?.showBottomSheet(context!, 'Scanner (Read Texts, QRs, ...)');
              matched = true;
              break;

            case 'photo_command': // Handle 'foto' voice command
              if (_gridMenuKey.currentState?.currentWidgetTitle ==
                  'describe_environment') {
                _describeEnvironmentKey.currentState?.takeAndSendImage();
              } else if (_gridMenuKey.currentState?.currentWidgetTitle ==
                  scannerTitle) {
                _ocrWidgetKey.currentState?.takeAndSendImage();
              }
              matched = true;
              break;

            default:
              break;
          }

          if (matched) stopListening();
          startListening();
          break; // Detenemos el bucle si encontramos un comando válido
        }
      }
      if (matched)
        break; // Salimos del bucle principal si ya hemos procesado el comando
    }

    if (!matched) {
      startListening();
    } else {
      _isActivated = false;
      useVoiceControlNotifier.value = false;
    }
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
              [
                dp[i - 1][j], // Eliminación
                dp[i][j - 1], // Inserción
                dp[i - 1][j - 1] // Sustitución
              ].reduce((a, b) => a < b ? a : b);
        }
      }
    }

    return dp[len1][len2];
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

  Future<void> _playActivationSound() async {
    await player.play(AssetSource(
        'sounds/activation_sound.mp3')); // Reproducir sonido de activación
  }
}
