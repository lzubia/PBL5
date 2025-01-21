import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:provider/provider.dart';

import 'risk_detection_test.mocks.dart';

@GenerateMocks([PictureService, ITtsService, VoiceCommands])
void main() {
  late MockPictureService mockPictureService;
  late MockITtsService mockTtsService;
  late MockVoiceCommands mockVoiceCommands;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    mockPictureService = MockPictureService();
    mockTtsService = MockITtsService();
    mockVoiceCommands = MockVoiceCommands();

    when(mockPictureService.isCameraInitialized).thenReturn(true);
    when(mockVoiceCommands.riskTrigger).thenReturn(false);
  });

  tearDown(() {
    reset(mockPictureService);
    reset(mockTtsService);
    reset(mockVoiceCommands);

    clearInteractions(mockPictureService);
    clearInteractions(mockTtsService);
    clearInteractions(mockVoiceCommands);
  });

  Future<void> pumpRiskDetection(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PictureService>.value(
              value: mockPictureService),
          Provider<ITtsService>.value(value: mockTtsService),
          ChangeNotifierProvider<VoiceCommands>.value(value: mockVoiceCommands),
        ],
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('es', 'ES'),
            Locale('eu', 'ES'),
          ],
          home: Scaffold(
            body: const RiskDetection(),
          ),
        ),
      ),
    );

    // Ensure all animations and asynchronous tasks are completed
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  testWidgets('should display widgets when camera is initialized',
      (WidgetTester tester) async {
    await pumpRiskDetection(tester);

    expect(find.byType(Switch), findsOneWidget); // Switch should exist
    expect(find.byIcon(Icons.warning),
        findsOneWidget); // Warning icon should exist
  });

  // testWidgets('should enable risk detection when switch is turned on',
  //     (WidgetTester tester) async {
  //   await pumpRiskDetection(tester);

  //   await tester.pumpAndSettle();
  //   expect(find.byType(Switch), findsOneWidget);

  //   await tester.tap(find.byType(Switch));
  //   await tester.pumpAndSettle();

  //   verify(mockTtsService.speakLabels(["Risk detection enabled"])).called(1);
  //   expect(find.byType(Switch), findsOneWidget);
  // });

  // testWidgets('should disable risk detection when switch is turned off',
  //     (WidgetTester tester) async {
  //   await pumpRiskDetection(tester);

  //   await tester.pumpAndSettle();
  //   expect(find.byType(Switch), findsOneWidget);

  //   await tester.tap(find.byType(Switch));
  //   await tester.pumpAndSettle();

  //   await tester.tap(find.byType(Switch));
  //   await tester.pumpAndSettle();

  //   verify(mockTtsService.speakLabels(["Risk detection disabled"])).called(1);
  //   expect(find.byType(Switch), findsOneWidget);
  // });

  // testWidgets('should show response time when available',
  //     (WidgetTester tester) async {
  //   await pumpRiskDetection(tester);

  //   final riskDetectionState =
  //       tester.state<RiskDetectionState>(find.byType(RiskDetection));
  //   riskDetectionState.setState(() {
  //     riskDetectionState.responseTime = const Duration(milliseconds: 500);
  //   });

  //   await tester.pumpAndSettle();

  //   expect(find.text('Response Time: 500 ms'), findsOneWidget);
  // });
}
