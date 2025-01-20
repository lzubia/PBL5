import 'package:flutter/material.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/locale_provider.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/settings_screen.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pbl5_menu/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pictureService = PictureService();
  final appInitializer = AppInitializer();
  await appInitializer.initialize(pictureService: pictureService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VoiceCommands()),
        ChangeNotifierProvider.value(
            value: pictureService), // Use the same instance
        ChangeNotifierProvider.value(
            value: appInitializer), // Provide appInitializer
        Provider(create: (_) => DatabaseHelper()), // Provide DatabaseHelper
        Provider<ITtsService>(
          create: (context) => TtsServiceGoogle(context.read<
              DatabaseHelper>()), // Pass DatabaseHelper to TtsServiceGoogle
        ),
        Provider(create: (_) => SttService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      locale: localeProvider.currentLocale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: localeProvider.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ttsService = Provider.of<ITtsService>(context);
    final databaseHelper = Provider.of<DatabaseHelper>(context);

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
                    ttsServiceGoogle: ttsService,
                    databaseHelper: databaseHelper,
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
            child: RiskDetection(),
          ),
          Expanded(
            child: GridMenu(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<PictureService>(
              builder: (context, pictureService, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Camara: ${pictureService.isCameraInitialized ? "Enabled" : "Disabled"} ',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Switch(
                      key: const Key('voiceControlSwitch'),
                      value: Provider.of<VoiceCommands>(context).isActivated,
                      onChanged: (value) {
                        Provider.of<VoiceCommands>(context, listen: false)
                            .toggleActivation(value);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
