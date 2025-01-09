import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbl5_menu/money_identifier.dart';
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
  bool _isActivated =
      false; // Para verificar si el control de voz está activado
  String _command = ''; // Para almacenar el comando de voz
  final GlobalKey<RiskDetectionState> _riskDetectionKey =
      GlobalKey<RiskDetectionState>();
  final GlobalKey<GridMenuState> _gridMenuKey = GlobalKey<GridMenuState>();
  final GlobalKey<MoneyIdentifierState> _moneyIdentifierKey =
      GlobalKey<MoneyIdentifierState>();

  final player = AudioPlayer(); // Para reproducir sonidos de notificación
  late Timer _commandTimeout; // Temporizador para el timeout de comandos

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() async {
    await widget.sttService.startListening(_handleSpeechResult);
    setState(() {});
  }

  void _handleSpeechResult(String recognizedText) {
    print('Texto reconocido: $recognizedText');
    setState(() {
      if (_isActivated) {
        _command = recognizedText;
        _handleCommand(_command);
      } else if (_isActivationCommand(recognizedText)) {
        _isActivated = true;
        useVoiceControl = true;
        _activateVoiceControl();
      } else {
        _startListening();
      }
    });
  }

  bool _isActivationCommand(String transcript) {
    return transcript.contains("begia") ||
        transcript.contains("veguia") ||
        transcript.contains("veguía") ||
        transcript.contains("veía") ||
        transcript.contains("de día") ||
        transcript.contains("beguía") ||
        transcript.contains("begía") ||
        transcript.contains("begia") ||
        transcript.contains("beguía") ||
        transcript.contains("beguía") ||
        transcript.contains("beía") ||
        transcript.contains("beguia") ||
        transcript.contains("vía") ||
        transcript.contains("viego") ||
        transcript.contains("beja") ||
        transcript.contains("begía") ||
        transcript.contains("beía") ||
        transcript.contains("vegia") ||
        transcript.contains("de guía") ||
        transcript.contains("beguía");
  }

  void _activateVoiceControl() {
    setState(() {
      useVoiceControl = true;
      isCommandProcessed = false;
    });

    // Reproducir sonido de activación
    _playActivationSound();

    print('INFO: Activating voice control...');
    // _commandTimeout.cancel();
    // _commandTimeout = Timer(Duration(seconds: 5), () {
    //   setState(() {
    //     _isActivated = false;
    //     useVoiceControl = false;
    //   });
    // });
  }

  void _handleCommand(String command) {
    print('Activated command: $command');
    if (command.contains('arrisco') ||
        command.contains('arrisku') ||
        command.contains('arisku') ||
        command.contains('carrisco') ||
        command.contains('arriscu') ||
        command.contains('arisco') ||
        command.contains('carresco') ||
        command.contains('arrisco') ||
        command.contains('arresco') ||
        command.contains('carisco') ||
        command.contains('ariscó') ||
        command.contains('arísco') ||
        command.contains('arricó') ||
        command.contains('cariscó')) {
      _riskDetectionKey.currentState?.toggleRiskDetection();
      isCommandProcessed = true;
    } else if (command.contains('dirua') ||
        command.contains('dirúa') ||
        command.contains('dírua') ||
        command.contains('dirúa') ||
        command.contains('dira') ||
        command.contains('dírua') ||
        command.contains('dira') ||
        command.contains('de ruina') ||
        command.contains('dilua') ||
        command.contains('derua') ||
        command.contains('dirúa') ||
        command.contains('drua') ||
        command.contains('di ru a') ||
        command.contains('de ru')) {
      // _moneyIdentifierKey.currentState?.initializeMoneyIdentifier();
      // Aseguramos que el estado esté listo

      _gridMenuKey.currentState?.showBottomSheet(context, 'Money Identifier');

      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => MoneyIdentifier(
      //       pictureService: widget.pictureService,
      //       ttsService: widget.ttsService,
      //     ),
      //   ),
      // ).then((_) {
      //   // Al regresar, asegurarse de que la inicialización ocurra
      //   Future.delayed(Duration(milliseconds: 200), () {
      //     if (_moneyIdentifierKey.currentState != null) {
      //       _moneyIdentifierKey.currentState?.initializeMoneyIdentifier();
      //       isCommandProcessed = true;
      //     } else {
      //       print('El widget de MoneyIdentifier aún no está inicializado.');
      //     }
      //   });
      // });
      isCommandProcessed = true;
    } else if (command.contains('mapa') ||
        command.contains('mappa') ||
        command.contains('mía') ||
        command.contains('ma\'pa') ||
        command.contains('ma') ||
        command.contains('mape') ||
        command.contains('mápá') ||
        command.contains('ma') ||
        command.contains('marpa') ||
        command.contains('mappa')) {
      // _moneyIdentifierKey.currentState?.initializeMoneyIdentifier();
      isCommandProcessed = true;
    } else {
      isCommandProcessed = false;
      _startListening();
    }

    // Desactivar tras procesar un comando válido
    if (isCommandProcessed) {
      _isActivated = false;
      useVoiceControl = false;
    }
  }

  Future<void> _playActivationSound() async {
    await player.play(AssetSource(
        'sounds/activation_sound.mp3')); // Reproducir sonido de activación
  }

  void _stopListening() {
    widget.sttService.stopListening();
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
              key: _gridMenuKey,
              pictureService: widget.pictureService,
              ttsService:
                  useGoogleTts ? widget.ttsServiceGoogle : widget.ttsService,
              moneyIdentifierKey: _moneyIdentifierKey,
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
                            _isActivated = true;
                            _startListening();
                          } else {
                            _isActivated = false;
                            _startListening();
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
