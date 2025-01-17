import 'dart:convert';
import 'dart:io';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/describe_environment.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/services/stt/i_stt_service.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/settings_screen.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:audioplayers/audioplayers.dart'; // For audio playback
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  await AppInitializer.initialize();
  runApp(MyApp(
    pictureService: AppInitializer.pictureService,
    ttsServiceGoogle: AppInitializer.ttsServiceGoogle,
    databaseHelper: AppInitializer.databaseHelper,
    sttService: AppInitializer.sttService,
    voiceCommands: AppInitializer.voiceCommands,
    riskDetectionKey: AppInitializer.riskDetectionKey,
    gridMenuKey: AppInitializer.gridMenuKey,
    moneyIdentifierKey: AppInitializer.moneyIdentifierKey,
    describeEnvironmentKey: AppInitializer.describeEnvironmentKey,
    ocrWidgetKey: AppInitializer.ocrWidgetKey,
    mapKey: AppInitializer.mapKey,
    locale: AppInitializer.locale,
  ));
}

class MyApp extends StatefulWidget {
  final PictureService pictureService;
  final ITtsService ttsServiceGoogle;
  final DatabaseHelper databaseHelper;
  final ISttService sttService;

  final GlobalKey<RiskDetectionState> riskDetectionKey;
  final GlobalKey<GridMenuState> gridMenuKey;
  final GlobalKey<MoneyIdentifierState> moneyIdentifierKey;
  final GlobalKey<DescribeEnvironmentState> describeEnvironmentKey;
  final GlobalKey<OcrWidgetState> ocrWidgetKey;
  final GlobalKey<MapWidgetState> mapKey;
  final VoiceCommands voiceCommands;

  Locale locale;

  MyApp({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.databaseHelper,
    required this.sttService,
    required this.voiceCommands,
    required this.riskDetectionKey,
    required this.gridMenuKey,
    required this.moneyIdentifierKey,
    required this.describeEnvironmentKey,
    required this.ocrWidgetKey,
    required this.mapKey,
    required this.locale,
  });

  @override
  _MyAppState createState() => _MyAppState(this.locale);
}

class _MyAppState extends State<MyApp> {
  Locale locale;

  _MyAppState(this.locale);

  void setLocale(Locale locale) {
    setState(() {
      this.locale = locale;
    });
    widget.voiceCommands.setContext(context, this.locale);
    widget.ttsServiceGoogle.updateLanguage(this.locale.languageCode,
        '${this.locale.languageCode}-${this.locale.countryCode}-Wavenet-B');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: this.locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'),
        Locale('es', 'ES'),
        Locale('eu', 'ES'),
      ],
      debugShowCheckedModeBanner: false,
      home: MyHomePage(
        pictureService: widget.pictureService,
        ttsServiceGoogle: widget.ttsServiceGoogle,
        databaseHelper: widget.databaseHelper,
        sttService: widget.sttService,
        voiceCommands: widget.voiceCommands,
        riskDetectionKey: widget.riskDetectionKey,
        gridMenuKey: widget.gridMenuKey,
        moneyIdentifierKey: widget.moneyIdentifierKey,
        describeEnvironmentKey: widget.describeEnvironmentKey,
        ocrWidgetKey: widget.ocrWidgetKey,
        mapKey: widget.mapKey,
        setLocale: setLocale,
        locale: this.locale,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final PictureService pictureService;
  final ITtsService ttsServiceGoogle;
  final DatabaseHelper databaseHelper;
  final ISttService sttService;
  final VoiceCommands voiceCommands;

  final GlobalKey<RiskDetectionState> riskDetectionKey;
  final GlobalKey<GridMenuState> gridMenuKey;
  final GlobalKey<MoneyIdentifierState> moneyIdentifierKey;
  final GlobalKey<DescribeEnvironmentState> describeEnvironmentKey;
  final GlobalKey<OcrWidgetState> ocrWidgetKey;
  final GlobalKey<MapWidgetState> mapKey;
  final Function(Locale) setLocale; // Add this line

  Locale locale;

  MyHomePage({
    super.key,
    required this.pictureService,
    required this.ttsServiceGoogle,
    required this.databaseHelper,
    required this.sttService,
    required this.voiceCommands,
    required this.riskDetectionKey,
    required this.gridMenuKey,
    required this.moneyIdentifierKey,
    required this.describeEnvironmentKey,
    required this.ocrWidgetKey,
    required this.mapKey,
    required this.setLocale,
    required this.locale,
  });

  @override
  MyHomePageState createState() => MyHomePageState(
      riskDetectionKey: riskDetectionKey,
      gridMenuKey: gridMenuKey,
      moneyIdentifierKey: moneyIdentifierKey,
      describeEnvironmentKey: describeEnvironmentKey,
      ocrWidgetKey: ocrWidgetKey,
      mapKey: mapKey,
      locale: locale);
}

class MyHomePageState extends State<MyHomePage> {
  bool useGoogleStt = false;
  bool useGoogleTts = false;
  bool _isActivated = false;
  final String sessionToken = AppInitializer.sessionToken;
  final GlobalKey<RiskDetectionState> riskDetectionKey;
  final GlobalKey<GridMenuState> gridMenuKey;
  final GlobalKey<MoneyIdentifierState> moneyIdentifierKey;
  final GlobalKey<DescribeEnvironmentState> describeEnvironmentKey;
  final GlobalKey<OcrWidgetState> ocrWidgetKey;
  final GlobalKey<MapWidgetState> mapKey;

  Locale locale;

  MyHomePageState({
    required this.riskDetectionKey,
    required this.gridMenuKey,
    required this.moneyIdentifierKey,
    required this.describeEnvironmentKey,
    required this.ocrWidgetKey,
    required this.mapKey,
    required this.locale,
  });

  final player = AudioPlayer(); // Para reproducir sonidos de notificación

  @override
  void initState() {
    super.initState();
    widget.voiceCommands.setContext(context, locale);
    widget.voiceCommands.loadVoiceCommands();
    widget.voiceCommands.startListening();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BEGIA', style: TextStyle(fontSize: 24)),
        actions: [
          IconButton(
            key: const Key('settingsButton'),
            icon: const Icon(Icons.settings, size: 50),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    setLocale: widget.setLocale,
                    ttsServiceGoogle: widget.ttsServiceGoogle,
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
              key: riskDetectionKey,
              pictureService: widget.pictureService,
              ttsService: widget.ttsServiceGoogle,
              sttService: widget.sttService,
              sessionToken: sessionToken, // Pass sessionToken to RiskDetection
            ),
          ),
          Expanded(
            child: GridMenu(
              key: gridMenuKey,
              pictureService: widget.pictureService,
              ttsService: widget.ttsServiceGoogle,
              sessionToken: sessionToken, // Pass sessionToken to GridMenu
              moneyIdentifierKey: moneyIdentifierKey,
              describeEnvironmentKey: describeEnvironmentKey,
              ocrWidgetKey: ocrWidgetKey,
              mapKey: mapKey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: VoiceCommands.useVoiceControlNotifier,
                  builder: (context, useVoiceControl, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Voice Control: ${useVoiceControl ? "Enabled" : "Disabled"}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Switch(
                          key: const Key(
                              'voiceControlSwitch'), // Add a unique Key
                          value: useVoiceControl,
                          onChanged: (value) {
                            setState(() {
                              VoiceCommands.useVoiceControlNotifier.value =
                                  value;
                              if (value) {
                                _isActivated = true;
                                widget.voiceCommands.startListening();
                              } else {
                                _isActivated = false;
                                widget.voiceCommands.startListening();
                              }
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
