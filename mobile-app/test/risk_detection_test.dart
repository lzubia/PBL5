import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/features/risk_detection.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/picture_service.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/app_initializer.dart';
import 'package:provider/provider.dart';
import 'package:fake_async/fake_async.dart';

import 'risk_detection_test.mocks.dart';

class MockAppLocalizations extends AppLocalizations {
  MockAppLocalizations() : super(const Locale('en', 'US'));

  @override
  String translate(String key) {
    switch (key) {
      case 'risk-on':
        return 'Risk detection enabled';
      case 'risk-off':
        return 'Risk detection disabled';
      default:
        return key;
    }
  }
}

class MockAppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  final MockAppLocalizations mockAppLocalizations;

  MockAppLocalizationsDelegate(this.mockAppLocalizations);

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'eu'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => mockAppLocalizations;

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

@GenerateMocks([PictureService, ITtsService, VoiceCommands, AppInitializer])
void main() {
  late MockPictureService mockPictureService;
  late MockITtsService mockTtsService;
  late MockVoiceCommands mockVoiceCommands;
  late MockAppLocalizations mockAppLocalizations;
  late MockAppInitializer mockAppInitializer;

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    mockPictureService = MockPictureService();
    mockTtsService = MockITtsService();
    mockVoiceCommands = MockVoiceCommands();
    mockAppLocalizations = MockAppLocalizations();
    mockAppInitializer = MockAppInitializer();

    // Load dotenv environment variables
    await dotenv.load(fileName: ".env");

    // Mock behavior for dependencies
    when(mockPictureService.isCameraInitialized).thenReturn(true);
    when(mockVoiceCommands.riskTrigger).thenReturn(false);
    when(mockAppInitializer.sessionToken).thenReturn('test-session-token');
  });

  Future<void> pumpRiskDetection(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PictureService>.value(
              value: mockPictureService),
          Provider<ITtsService>.value(value: mockTtsService),
          ChangeNotifierProvider<VoiceCommands>.value(value: mockVoiceCommands),
          Provider<AppInitializer>.value(value: mockAppInitializer),
        ],
        child: MaterialApp(
          localizationsDelegates: [
            MockAppLocalizationsDelegate(mockAppLocalizations),
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

    await tester.pumpAndSettle();
  }

  testWidgets('should display widgets when camera is initialized',
      (WidgetTester tester) async {
    await pumpRiskDetection(tester);

    expect(find.byType(Switch), findsOneWidget); // Switch should exist
    expect(find.byIcon(Icons.warning),
        findsOneWidget); // Warning icon should exist
  });

  // testWidgets(
  //     'should call PictureService takePicture periodically when enabled',
  //     (WidgetTester tester) async {
  //   // Pump the widget tree and toggle the switch before entering FakeAsync
  //   await pumpRiskDetection(tester);

  //   // Enable risk detection by toggling the switch
  //   await tester.tap(find.byType(Switch));
  //   await tester.pumpAndSettle(); // Wait for the state change to complete

  //   // Use FakeAsync for timer simulation
  //   fakeAsync((fake) {
  //     // Advance time to trigger the periodic timer
  //     fake.elapse(const Duration(milliseconds: 1500));
  //     fake.flushMicrotasks(); // Ensure all pending microtasks are completed

  //     // Verify that takePicture is called once
  //     verify(mockPictureService.takePicture(
  //       endpoint: anyNamed('endpoint'),
  //       onLabelsDetected: anyNamed('onLabelsDetected'),
  //       onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
  //     )).called(1);

  //     // Advance time to simulate the next timer tick
  //     fake.elapse(const Duration(milliseconds: 1500));
  //     fake.flushMicrotasks();

  //     // Verify that takePicture is called a second time
  //     verify(mockPictureService.takePicture(
  //       endpoint: anyNamed('endpoint'),
  //       onLabelsDetected: anyNamed('onLabelsDetected'),
  //       onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
  //     )).called(1);
  //   });
  // });

  testWidgets('should cancel Timer when risk detection is disabled',
      (WidgetTester tester) async {
    await pumpRiskDetection(tester);

    // Enable risk detection
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Disable risk detection
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Verify that no additional calls to takePicture occur
    fakeAsync((fake) {
      fake.elapse(const Duration(milliseconds: 1500));
      verifyNever(mockPictureService.takePicture(
        endpoint: anyNamed('endpoint'),
        onLabelsDetected: anyNamed('onLabelsDetected'),
        onResponseTimeUpdated: anyNamed('onResponseTimeUpdated'),
      ));
    });
  });

  testWidgets('should enable risk detection when switch is turned on',
      (WidgetTester tester) async {
    await pumpRiskDetection(tester);

    // Ensure switch is present
    expect(find.byType(Switch), findsOneWidget);

    // Tap the switch to enable risk detection
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Verify that the TTS service was called with the correct label
    verify(mockTtsService.speakLabels(["Risk detection enabled"], any))
        .called(1);
  });

  testWidgets('should disable risk detection when switch is turned off',
      (WidgetTester tester) async {
    await pumpRiskDetection(tester);

    // Ensure switch is present
    expect(find.byType(Switch), findsOneWidget);

    // Tap the switch to enable risk detection
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Tap the switch again to disable risk detection
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    verify(mockTtsService.speakLabels(["Risk detection disabled"], any))
        .called(1);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('should show response time when available',
      (WidgetTester tester) async {
    await pumpRiskDetection(tester);

    // Access the widget state
    final riskDetectionState =
        tester.state<RiskDetectionState>(find.byType(RiskDetection));

    // Update the responseTime in the state
    riskDetectionState.setState(() {
      riskDetectionState.responseTime = const Duration(milliseconds: 500);
    });

    await tester.pumpAndSettle();

    // Verify that the response time is displayed
    expect(find.text('Response Time: 500 ms'), findsOneWidget);
  });

  testWidgets(
      'should trigger enableRiskDetection when VoiceCommands triggers risk',
      (WidgetTester tester) async {
    // Set riskTrigger to true
    when(mockVoiceCommands.riskTrigger).thenReturn(true);

    await pumpRiskDetection(tester);

    // Verify that risk detection was enabled
    verify(mockTtsService.speakLabels(["Risk detection enabled"], any))
        .called(1);
  });
}
