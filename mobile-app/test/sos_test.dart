import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';
import 'package:pbl5_menu/services/sos.dart';

import 'sos_test.mocks.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final AppLocalizations mockAppLocalizations;

  AppLocalizationsDelegate(this.mockAppLocalizations);

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'eu'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => mockAppLocalizations;

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

@GenerateMocks([http.Client, TtsServiceGoogle, AppLocalizations])
void main() {
  late MockClient mockHttpClient;
  late MockTtsServiceGoogle mockTtsServiceGoogle;
  late SosService sosService;

  setUp(() {
    mockHttpClient = MockClient();
    mockTtsServiceGoogle = MockTtsServiceGoogle();
    sosService = SosService(
      ttsServiceGoogle: mockTtsServiceGoogle,
      client: mockHttpClient,
    );
  });

  Widget buildTestWidget(
    Widget child, {
    required AppLocalizations mockLocalizations,
  }) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        AppLocalizationsDelegate(mockLocalizations),
      ],
      supportedLocales: const [Locale('en', 'US')],
      home: Scaffold(
        body: Builder(
          builder: (context) => child,
        ),
      ),
    );
  }

  group('SosService.sendSosRequest', () {
    const numbers = [
      {'name': 'John Doe', 'phone': '1234567890'},
      {'name': 'Jane Smith', 'phone': '0987654321'}
    ];

    testWidgets('should send SOS request successfully and invoke TTS service',
        (WidgetTester tester) async {
      final mockAppLocalizations = MockAppLocalizations();

      when(mockAppLocalizations.translate('Sos-sent-successfully'))
          .thenReturn('SOS sent successfully');

      when(mockHttpClient.post(
        Uri.parse('https://begiapbl.duckdns.org:1880/sos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'numbers': numbers}),
      )).thenAnswer((_) async => http.Response('{}', 200));

      BuildContext? testContext;

      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              testContext = context;
              return Container(); // Ensure the widget tree is mounted
            },
          ),
          mockLocalizations: mockAppLocalizations,
        ),
      );

      await tester.pumpAndSettle();

      // Ensure the context is not null
      expect(testContext, isNotNull);

      await sosService.sendSosRequest(numbers, testContext!);

      verify(mockHttpClient.post(
        Uri.parse('https://begiapbl.duckdns.org:1880/sos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'numbers': numbers}),
      )).called(1);

      verify(mockTtsServiceGoogle.speakLabels(
        ['SOS sent successfully'],
        testContext!,
      )).called(1);
    });

    testWidgets('should throw an exception on failed SOS request',
        (WidgetTester tester) async {
      final mockAppLocalizations = MockAppLocalizations();

      when(mockAppLocalizations.translate('Sos-sent-successfully'))
          .thenReturn('SOS sent successfully');

      when(mockHttpClient.post(
        Uri.parse('https://begiapbl.duckdns.org:1880/sos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'numbers': numbers}),
      )).thenAnswer((_) async => http.Response('Error', 500));

      BuildContext? testContext;

      await tester.pumpWidget(
        buildTestWidget(
          Builder(
            builder: (context) {
              testContext = context;
              return Container();
            },
          ),
          mockLocalizations: mockAppLocalizations,
        ),
      );

      await tester.pumpAndSettle();

      expect(testContext, isNotNull);

      expect(
        () async => await sosService.sendSosRequest(numbers, testContext!),
        throwsA(isA<Exception>()),
      );

      verify(mockHttpClient.post(
        Uri.parse('https://begiapbl.duckdns.org:1880/sos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'numbers': numbers}),
      )).called(1);

      verifyNever(mockTtsServiceGoogle.speakLabels(any, any));
    });
  });
}
