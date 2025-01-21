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
  final dbHelper = DatabaseHelper(); // Create an instance of DatabaseHelper
  final ttsService = TtsServiceGoogle(
      dbHelper); // Initialize TtsServiceGoogle with DatabaseHelper
  final appInitializer = AppInitializer();
  await appInitializer.initialize(pictureService: pictureService);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => appInitializer), // Provide AppInitializer
        ChangeNotifierProvider(
            create: (_) => LocaleProvider()), // LocaleProvider
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // ThemeProvider
        ChangeNotifierProvider.value(value: pictureService), // PictureService
        ChangeNotifierProvider(
          create: (_) => MapProvider(
              ttsService: ttsService), // MapProvider with TtsServiceGoogle
        ),
        ChangeNotifierProvider(
          create: (_) =>
              VoiceCommands(sttService), // VoiceCommands with SttService
        ),
        Provider(create: (_) => dbHelper), // Provide DatabaseHelper
        Provider<ITtsService>(
          create: (_) => ttsService, // Provide TtsServiceGoogle as ITtsService
        ),
        Provider(
            create: (_) => appInitializer.sttService), // Provide SttService
        ChangeNotifierProvider(
            create: (_) => WidgetStateProvider()), // WidgetStateProvider
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
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // Detecta toques en áreas vacías.
        onDoubleTap: () {
          // Toggle state using Provider
          final voiceCommands = context.read<VoiceCommands>();
          voiceCommands.toggleVoiceControl();
        },
        child: Column(
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
              child: Consumer<VoiceCommands>(
                builder: (context, voiceCommands, child) {
                  return Visibility(
                    visible: VoiceCommands.useVoiceControlNotifier.value,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Image.asset(
                        'assets/BegiaGif.gif',
                        height: 100,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
