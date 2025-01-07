import 'dart:async';

import 'package:flutter/material.dart';
import 'package:googleapis/bigquerydatatransfer/v1.dart';
import 'package:pbl5_menu/stt_service_google.dart';
import 'package:pbl5_menu/tts_service_google.dart';
import 'package:pbl5_menu/stt_service.dart';
import 'package:pbl5_menu/i_stt_service.dart';
import 'package:pbl5_menu/i_tts_service.dart';
import 'package:pbl5_menu/risk_detection.dart';
import 'package:pbl5_menu/grid_menu.dart';
import 'package:pbl5_menu/settings_screen.dart';
import 'package:pbl5_menu/picture_service.dart';
import 'package:pbl5_menu/tts_service.dart';
import 'package:pbl5_menu/database_helper.dart';
import 'package:audioplayers/audioplayers.dart'; // For audio playback

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final pictureService = PictureService();
  await pictureService.setupCamera();
  await pictureService.initializeCamera();

  final databaseHelper = DatabaseHelper();
  final ttsServiceGoogle = TtsServiceGoogle(databaseHelper);
  final ttsService = TtsService(databaseHelper);
  final sttServiceGoogle =
      SttServiceGoogle(); // Initialize Speech-to-Text service
  final sttService = SttService(); // Initialize another Speech-to-Text service

  ttsServiceGoogle.initializeTts();
  ttsService.initializeTts();
  await sttServiceGoogle.initializeStt(); // Initialize STT service
  await sttService.initializeStt(); // Initialize another STT service

  runApp(MyApp(
    pictureService: pictureService,
    ttsServiceGoogle: ttsServiceGoogle,
    ttsService: ttsService,
    databaseHelper: databaseHelper,
    sttServiceGoogle: sttServiceGoogle, // Pass the STT service
    sttService: sttService, // Pass another STT service
  ));
}

class MyApp extends StatelessWidget {
  final PictureService pictureService;
  final ITtsService ttsServiceGoogle;
  final ITtsService ttsService;
  final DatabaseHelper databaseHelper;
  final ISttService sttServiceGoogle;
  final ISttService sttService;

  const MyApp({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.ttsService,
    required this.databaseHelper,
    required this.sttServiceGoogle,
    required this.sttService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Risk Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        pictureService: pictureService,
        ttsServiceGoogle: ttsServiceGoogle,
        ttsService: ttsService,
        databaseHelper: databaseHelper,
        sttServiceGoogle: sttServiceGoogle,
        sttService: sttService,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final PictureService pictureService;
  final ITtsService ttsServiceGoogle;
  final ITtsService ttsService;
  final DatabaseHelper databaseHelper;
  final ISttService sttServiceGoogle;
  final ISttService sttService;

  const MyHomePage({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.ttsService,
    required this.databaseHelper,
    required this.sttServiceGoogle,
    required this.sttService,
  });

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  bool useGoogleStt = false;
  bool useGoogleTts = false;
  bool useVoiceControl = false;
  bool isCommandProcessed =
      false; // Para verificar si un comando ha sido procesado
  final GlobalKey<RiskDetectionState> _riskDetectionKey =
      GlobalKey<RiskDetectionState>();
  final player = AudioPlayer(); // Para reproducir sonidos de notificación
  late Timer _commandTimeout; // Temporizador para el timeout de comandos

  @override
  void initState() {
    super.initState();
    _startActivationListening();
  }

  Future<void> _startActivationListening() async {
    await widget.sttService.startListening((transcript) {
      if (_isActivationCommand(transcript)) {
        _activateVoiceControl();
      } else {
        _keepListeningForActivation();
      }
    });
  }

  bool _isActivationCommand(String transcript) {
    return transcript.contains("kaixo begia") ||
        transcript.contains("pazos") ||
        transcript.contains("kaixobe guía") ||
        transcript.contains("hola veguia") ||
        transcript.contains("hola beguia");
  }

  void _activateVoiceControl() {
    setState(() {
      useVoiceControl = true;
      isCommandProcessed =
          false; // Se reinicia el estado de los comandos procesados
    });

    // Reproducir sonido de activación
    _playActivationSound();

    // Iniciar escucha de comandos generales
    _stopListening();
    _startGeneralListening();
  }

  void _keepListeningForActivation() {
    if (!useVoiceControl) {
      _stopListening();
      _startActivationListening();
    }
  }

  Future<void> _startGeneralListening() async {
    await widget.sttService.startListening((transcript) {
      if (isCommandProcessed)
        return; // Si ya se procesó un comando, no seguir escuchando

      _handleCommand(transcript);

      // Si no se procesó ningún comando válido, iniciar temporizador
      if (!isCommandProcessed) {
        _startCommandTimeout();
      }
    });
  }

  void _handleCommand(String command) {
    if (command.contains('risk')) {
      _riskDetectionKey.currentState?.enableRiskDetection();
      isCommandProcessed = true;
    } else if (command.contains('risk detection off')) {
      _riskDetectionKey.currentState?.disableRiskDetection();
      isCommandProcessed = true;
    } else {
      // Si el comando no es válido, podemos reiniciar la escucha después del tiempo de espera
      isCommandProcessed = false;
      _startGeneralListening();
    }
  }

  // Temporizador para reiniciar la escucha si no se detecta ningún comando válido
  void _startCommandTimeout() {
    if (_commandTimeout.isActive) {
      _commandTimeout.cancel(); // Cancelar el temporizador anterior si existe
    }

    _commandTimeout = Timer(const Duration(seconds: 5), () {
      if (!isCommandProcessed) {
        useVoiceControl = false;
        _stopListening();
        _startActivationListening(); // Reiniciar la escucha si no se procesó ningún comando
      }
    });
  }

  Future<void> _playActivationSound() async {
    await player.play(AssetSource(
        'sounds/activation_sound.mp3')); // Reproducir sonido de activación
  }

  void _stopListening() {
    if (widget.sttService.isListening()) {
      widget.sttService.stopListening();
    }
  }

  Future<void> _startListening() async {
    await widget.sttService.startListening((transcript) {
      if (_isActivationCommand(transcript)) {
        _activateVoiceControl();
      } else {
        _keepListeningForActivation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BEGIA', style: TextStyle(fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 50),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    ttsServiceGoogle: widget.ttsServiceGoogle,
                    ttsService: widget.ttsService,
                    databaseHelper: widget.databaseHelper,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RiskDetection(
              key: _riskDetectionKey,
              pictureService: widget.pictureService,
              ttsService:
                  useGoogleTts ? widget.ttsServiceGoogle : widget.ttsService,
              sttService: useGoogleStt
                  ? widget.sttServiceGoogle
                  : widget.sttService, // Pass the appropriate STT service
            ),
          ),
          Expanded(
            child: GridMenu(
              pictureService: widget.pictureService,
              ttsService:
                  useGoogleTts ? widget.ttsServiceGoogle : widget.ttsService,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Voice Control: ${useVoiceControl ? "Enabled" : "Disabled"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: useVoiceControl,
                      onChanged: (value) {
                        setState(() {
                          useVoiceControl = value;
                          if (useVoiceControl) {
                            _startListening();
                          } else {
                            _stopListening();
                          }
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'TTS Service: ${useGoogleTts ? "Google TTS" : "Demo TTS"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: useGoogleTts,
                      onChanged: (value) {
                        setState(() {
                          useGoogleTts = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STT Service: ${useGoogleStt ? "Google STT" : "Demo STT"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Switch(
                      value: useGoogleStt,
                      onChanged: (value) {
                        setState(() {
                          useGoogleStt = value;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
