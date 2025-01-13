import 'dart:convert';
import 'dart:io';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis/androidmanagement/v1.dart';
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
import 'package:flutter/services.dart'; // Para cargar archivos desde assets
import 'package:audioplayers/audioplayers.dart'; // For audio playback

String sessionToken = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //txapar
  HttpOverrides.global = MyHttpOverrides();

  const platform = MethodChannel('com.example.pbl5_menu/endSession');
  platform.setMethodCallHandler((call) async {
    if (call.method == 'endSession') {
      await endSession(sessionToken);
    } else if (call.method == 'startSession') {
      await startSession();
    }
  });

  //await startSession();

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
  await dotenv.load(fileName: "./.env");

  runApp(MyApp(
    pictureService: pictureService,
    ttsServiceGoogle: ttsServiceGoogle,
    ttsService: ttsService,
    databaseHelper: databaseHelper,
    sttServiceGoogle: sttServiceGoogle, // Pass the STT service
    sttService: sttService, // Pass another STT service
  ));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> startSession({http.Client? client}) async {
  final url = Uri.parse('https://192.168.1.5:1880/start-session');
  client ??= http.Client();
  try {
    final response = await client.get(url);
    if (response.statusCode == 200) {
      sessionToken = jsonDecode(response.body)['session_id'];
      print('Session started successfully');
    } else {
      sessionToken = ''; // Reset sessionToken on failure
      print('Failed to start session: ${response.statusCode}');
    }
  } catch (e) {
    sessionToken = ''; // Reset sessionToken on error
    print('Error starting session: $e');
  }
}

Future<void> endSession(String sessionId, {http.Client? client}) async {
  final url =
      Uri.parse('https://192.168.1.5:1880/end-session?session_id=$sessionId');
  client ??= http.Client();
  try {
    final response = await client.delete(url);
    if (response.statusCode == 200) {
      print('Session ended successfully');
      print('Response: ${response.body}');
    } else if (response.statusCode == 404) {
      print('Session ID not found');
    } else {
      print('Failed to end session: ${response.statusCode}');
    }
  } catch (e) {
    print('Error ending session: $e');
  }
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
  List<List<String>> voiceCommands = []; // Comandos cargados del archivo
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
    _loadVoiceCommands();
    _startListening();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadVoiceCommands() async {
    final String fileContent =
        await rootBundle.loadString('assets/voice_commands.txt');
    setState(() {
      // Cada línea representa un grupo de sinónimos separados por comas
      voiceCommands = fileContent
          .split('\n') // Dividir por líneas
          .map((line) =>
              line.split(',').map((cmd) => cmd.trim().toLowerCase()).toList())
          .toList();
    });
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
    });
    // Reproducir sonido de activación
    _playActivationSound();
  }

  void _handleCommand(String command) {
    print('Activated command: $command');

    bool matched = false;
    const double similarityThreshold = 80.0;

    for (var commandGroup in voiceCommands) {
      final similarity = calculateSimilarity(command, commandGroup.first);

      for (var synonym in commandGroup) {
        // Calculamos la similitud usando la distancia de Levenshtein
        if (similarity >= similarityThreshold || command.contains(synonym)) {
          final primaryCommand = commandGroup.first;

          switch (primaryCommand) {
            case 'arrisku': // Comando principal del grupo de riesgo
              _riskDetectionKey.currentState?.toggleRiskDetection();
              matched = true;
              break;

            case 'dirua': // Comando principal del grupo de identificador de dinero
              _gridMenuKey.currentState
                  ?.showBottomSheet(context, 'Money Identifier');
              matched = true;
              break;

            case 'mapa': // Comando principal del grupo de mapas
              matched = true;
              break;

            case 'menua': // Comando principal del grupo de navegación a casa
              Navigator.popUntil(context, (route) => route.isFirst);
              widget.ttsService.speakLabels(['Going to menu']);
              matched = true;
              break;

            default:
              break;
          }

          if (matched)
            break; // Detenemos el bucle si encontramos un comando válido
        }
      }
      if (matched)
        break; // Salimos del bucle principal si ya hemos procesado el comando
    }

    if (!matched) {
      _startListening();
    } else {
      _isActivated = false;
      useVoiceControl = false;
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
              sttService:
                  useGoogleStt ? widget.sttServiceGoogle : widget.sttService,
              sessionToken: sessionToken, // Pass sessionToken to RiskDetection
            ),
          ),
          Expanded(
            child: GridMenu(
              key: _gridMenuKey,
              pictureService: widget.pictureService,
              ttsService:
                  useGoogleTts ? widget.ttsServiceGoogle : widget.ttsService,
              sessionToken: sessionToken, // Pass sessionToken to GridMenu
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
                      key: const Key('voiceControlSwitch'), // Add a unique Key
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
