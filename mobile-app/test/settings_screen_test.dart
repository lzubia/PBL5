import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:pbl5_menu/features/settings_screen.dart';
import 'package:pbl5_menu/locale_provider.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:provider/provider.dart';

import 'settings_screen_test.mocks.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String translate(String key) {
    switch (key) {
      case 'contacts':
        return 'Contacts';
      case 'theme':
        return 'Theme';
      case 'language':
        return 'Language';
      case 'font_size':
        return 'Font Size';
      case 'speech_rate':
        return 'Speech Rate';
      default:
        return key;
    }
  }
}

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

@GenerateMocks(
    [DatabaseHelper, ITtsService, LocaleProvider, FlutterNativeContactPicker])
void main() {
  late MockDatabaseHelper mockDatabaseHelper;
  late MockITtsService mockTtsService;
  late MockLocaleProvider mockLocaleProvider;
  late MockFlutterNativeContactPicker mockContactPicker;

  setUp(() {
    SettingsScreen.kTestMode = true;
    mockDatabaseHelper = MockDatabaseHelper();
    mockTtsService = MockITtsService();
    mockLocaleProvider = MockLocaleProvider();
    mockContactPicker = MockFlutterNativeContactPicker();

    when(mockDatabaseHelper.getPreferences()).thenAnswer((_) async => {
          'fontSize': 20.0,
          'language': 'English',
          'isDarkTheme': 0,
          'speechRate': 1.0,
        });

    when(mockDatabaseHelper.getContacts()).thenAnswer((_) async => [
          {'name': 'John Doe', 'phone': '1234567890'},
          {'name': 'Jane Smith', 'phone': '0987654321'}
        ]);
  });

  tearDown(() {
    reset(mockDatabaseHelper);
    reset(mockTtsService);
    reset(mockLocaleProvider);
    reset(mockContactPicker);
    SettingsScreen.kTestMode = false;
  });

  Future<void> pumpSettingsScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<DatabaseHelper>.value(value: mockDatabaseHelper),
          Provider<ITtsService>.value(value: mockTtsService),
          ChangeNotifierProvider<LocaleProvider>.value(
              value: mockLocaleProvider),
        ],
        child: MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            // Inject mock AppLocalizations
            AppLocalizationsDelegate(MockAppLocalizations()),
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('es', 'ES'),
            Locale('eu', 'ES'),
          ],
          home: SettingsScreen(contactPicker: mockContactPicker),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('should display all sections and load initial settings',
      (WidgetTester tester) async {
    await pumpSettingsScreen(tester);

    // Verify that the initial sections are displayed
    expect(find.text('Contacts'), findsOneWidget);
    expect(find.text('Theme'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Font Size'), findsOneWidget);
    expect(find.text('Speech Rate'), findsOneWidget);

    // Verify that the initial contacts are loaded
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Jane Smith'), findsOneWidget);

    // Verify database methods were called
    verify(mockDatabaseHelper.getPreferences()).called(1);
    verify(mockDatabaseHelper.getContacts()).called(1);
  });

  testWidgets('should add a contact when the add button is pressed',
      (WidgetTester tester) async {
    await pumpSettingsScreen(tester);

    // Mock the contact picker to return a new contact
    when(mockContactPicker.selectContact()).thenAnswer(
      (_) async =>
          Contact(fullName: 'New Contact', phoneNumbers: ['123456789']),
    );

    // Mock the insertContact and getContacts methods
    when(mockDatabaseHelper.insertContact(any, any)).thenAnswer((_) async {});
    when(mockDatabaseHelper.getContacts()).thenAnswer((_) async => [
          {'name': 'John Doe', 'phone': '1234567890'},
          {'name': 'Jane Smith', 'phone': '0987654321'},
          {'name': 'New Contact', 'phone': '123456789'}, // Updated contact list
        ]);

    // Tap the "Add Contact" button
    final addContactButton = find.byKey(const Key('addContactButton'));
    expect(addContactButton, findsOneWidget);

    await tester.tap(addContactButton);
    await tester.pumpAndSettle();

    // Verify the contact picker was called
    verify(mockContactPicker.selectContact()).called(1);

    // Verify the new contact was inserted into the database
    verify(mockDatabaseHelper.insertContact('New Contact', '123456789'))
        .called(1);

    // Verify the new contact is displayed in the UI
    expect(find.text('New Contact'), findsOneWidget);
  });

  testWidgets('should delete a contact when dismissed',
      (WidgetTester tester) async {
    await pumpSettingsScreen(tester);

    // Ensure initial state contains "John Doe"
    expect(find.text('John Doe'), findsOneWidget);

    // Mock deleteContact and return updated contacts list
    when(mockDatabaseHelper.deleteContact('John Doe')).thenAnswer((_) async {});
    when(mockDatabaseHelper.getContacts()).thenAnswer((_) async => [
          {'name': 'Jane Smith', 'phone': '0987654321'} // "John Doe" removed
        ]);

    // Simulate dismissing "John Doe"
    await tester.drag(find.text('John Doe'), const Offset(-500, 0));
    await tester.pumpAndSettle(); // Wait for animations and rebuilds

    // Verify that deleteContact was called
    verify(mockDatabaseHelper.deleteContact('John Doe')).called(1);

    // Verify that "John Doe" is no longer in the widget tree
    expect(find.text('John Doe'), findsNothing);

    // Verify that "Jane Smith" is still in the widget tree
    expect(find.text('Jane Smith'), findsOneWidget);
  });

  testWidgets('should toggle theme when switch is toggled',
      (WidgetTester tester) async {
    await pumpSettingsScreen(tester);

    final themeSwitch = find.byType(SwitchListTile);
    expect(themeSwitch, findsOneWidget);

    await tester.tap(themeSwitch);
    await tester.pump();

    verify(mockDatabaseHelper.updatePreferences(
      any,
      any,
      true,
      any,
    )).called(1);
  });

  testWidgets('should change font size when slider is adjusted',
      (WidgetTester tester) async {
    await pumpSettingsScreen(tester);

    // Ensure the Slider is visible
    final fontSizeSlider = find.byType(Slider).first;
    await tester.ensureVisible(fontSizeSlider);
    await tester.pumpAndSettle();

    // Mock updatePreferences to ensure it's called
    when(mockDatabaseHelper.updatePreferences(any, any, any, any))
        .thenAnswer((_) async {});

    // Simulate interaction with the Slider
    await tester.drag(
        fontSizeSlider, const Offset(50.0, 0.0)); // Drag to increase font size
    await tester.pumpAndSettle();

    // Verify that updatePreferences was called with a font size close to the new value
    verify(mockDatabaseHelper.updatePreferences(
      argThat(closeTo(
          28.0, 0.5)), // Allow a tolerance of ±0.5 for floating-point values
      any,
      any,
      any,
    )).called(greaterThan(0)); // Ensure at least one call was made
  });

  testWidgets('should change speech rate when slider is adjusted',
      (WidgetTester tester) async {
    await pumpSettingsScreen(tester);

    // Ensure the speech rate slider is visible
    final speechRateSlider = find.byType(Slider).last;
    await tester.ensureVisible(speechRateSlider);
    await tester.pumpAndSettle();

    // Mock updateSpeechRate in ITtsService
    when(mockTtsService.updateSpeechRate(any)).thenAnswer((_) async {});

    // Simulate interaction with the slider
    await tester.drag(speechRateSlider,
        const Offset(50.0, 0.0)); // Drag to change speech rate
    await tester.pumpAndSettle();

    // Verify that updateSpeechRate was called with a value close to the expected range
    verify(mockTtsService.updateSpeechRate(
      argThat(closeTo(1.9, 0.2)), // Adjust the expected value and tolerance
    )).called(greaterThan(0)); // Ensure at least one call was made
  });

  testWidgets('should change language when a language button is pressed',
      (WidgetTester tester) async {
    await pumpSettingsScreen(tester);

    final spanishButton = find.text('ESP');
    expect(spanishButton, findsOneWidget);

    await tester.tap(spanishButton);
    await tester.pump();

    verify(mockLocaleProvider.setLocale(const Locale('es', 'ES'))).called(1);
    verify(mockTtsService.updateLanguage('es-ES', 'es-ES-Wavenet-B')).called(1);
  });

  testWidgets('should not add a contact if contact picker returns null',
      (WidgetTester tester) async {
    await pumpSettingsScreen(tester);

    when(mockContactPicker.selectContact()).thenAnswer((_) async => null);

    final addContactButton = find.byKey(const Key('addContactButton'));
    expect(addContactButton, findsOneWidget);

    await tester.tap(addContactButton);
    await tester.pumpAndSettle();

    verify(mockContactPicker.selectContact()).called(1);
    verifyNever(mockDatabaseHelper.insertContact(any, any));

    expect(find.text('New Contact'), findsNothing);
  });
}
