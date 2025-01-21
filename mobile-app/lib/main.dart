import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:pbl5_menu/features/grid_menu.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/features/settings_screen.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/locale_provider.dart';
import 'package:pbl5_menu/map_provider.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:pbl5_menu/theme_provider.dart';
import 'package:pbl5_menu/widgetState_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final pictureService = PictureService();
  final sttService = SttService();
  final appInitializer = AppInitializer();
  await appInitializer.initialize(pictureService: pictureService);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => AppInitializer()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: pictureService), // Share instance
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => VoiceCommands(sttService)), // Wrap in ChangeNotifierProvider
        Provider(create: (_) => DatabaseHelper()), // Provide DatabaseHelper
        Provider<ITtsService>(
          create: (context) =>
              TtsServiceGoogle(context.read<DatabaseHelper>()), // Pass dependency
        ),
        // Provider(create: (_) => SttService()),
        Provider(create: (_) => appInitializer.sttService),
        ChangeNotifierProvider(create: (_) => WidgetStateProvider()), // Provide WidgetStateProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure VoiceCommands initializes dependencies after the app starts
      Provider.of<VoiceCommands>(context, listen: false).initialize(context);
    });

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
                  builder: (context) => SettingsScreen(),
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
                      'Camera: ${pictureService.isCameraInitialized ? "Enabled" : "Disabled"}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Consumer<VoiceCommands>(
                      builder: (context, voiceCommands, child) {
                        return Switch(
                          key: const Key('voiceControlSwitch'),
                          value: voiceCommands.isActivated,
                          onChanged: (value) {
                            voiceCommands.toggleActivation(value);
                          },
                        );
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
