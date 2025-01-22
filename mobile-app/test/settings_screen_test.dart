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

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final AppLocalizations localizations;

  AppLocalizationsDelegate(this.localizations);

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'eu'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => localizations;

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

class MockAppLocalizations extends Mock implements AppLocalizations {
  @override
  String translate(String key) {
    switch (key) {
      case 'title':
        return 'Settings';
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

@GenerateMocks(
    [DatabaseHelper, ITtsService, LocaleProvider, FlutterNativeContactPicker])
void main() {
  late MockDatabaseHelper mockDatabaseHelper;
  late MockITtsService mockTtsService;
  late MockLocaleProvider mockLocaleProvider;
  late MockFlutterNativeContactPicker mockContactPicker;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockTtsService = MockITtsService();
    mockLocaleProvider = MockLocaleProvider();
    mockContactPicker = MockFlutterNativeContactPicker();

    // Mock database preferences
    when(mockDatabaseHelper.getPreferences()).thenAnswer((_) async => {
          'fontSize': 20.0,
          'language': 'English',
          'isDarkTheme': 0,
          'speechRate': 1.0,
        });

    // Mock database contacts
    when(mockDatabaseHelper.getContacts())
        .thenAnswer((_) async => [
          {'name': 'John Doe'},
          {'name': 'Jane Smith'}
        ]);
  });

  tearDown(() {
    reset(mockDatabaseHelper);
    reset(mockTtsService);
    reset(mockLocaleProvider);
    reset(mockContactPicker);
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
            AppLocalizationsDelegate(MockAppLocalizations()),
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
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

  // testWidgets('should display all sections and load initial settings',
  //     (WidgetTester tester) async {
  //   await pumpSettingsScreen(tester);

  //   // Verify that initial sections are displayed
  //   expect(find.text('Contacts'), findsOneWidget);
  //   expect(find.text('Theme'), findsOneWidget);
  //   expect(find.text('Language'), findsOneWidget);
  //   expect(find.text('Font Size'), findsOneWidget);
  //   expect(find.text('Speech Rate'), findsOneWidget);

  //   // Verify that initial contacts are loaded
  //   await tester.pumpAndSettle(); // Ensure the widget tree is settled
  //   expect(find.text('John Doe'), findsOneWidget);
  //   expect(find.text('Jane Smith'), findsOneWidget);

  //   // Verify that database preferences were fetched
  //   verify(mockDatabaseHelper.getPreferences()).called(1);
  //   verify(mockDatabaseHelper.getContacts()).called(1);
  // });

  // testWidgets('should add a contact when the add button is pressed',
  //     (WidgetTester tester) async {
  //   await pumpSettingsScreen(tester);

  //   // Mock the behavior of the contact picker
  //   when(mockContactPicker.selectContact()).thenAnswer(
  //     (_) async => Contact(fullName: 'New Contact'),
  //   );

  //   // Mock the database insertContact method
  //   when(mockDatabaseHelper.insertContact(any, any)).thenAnswer((_) async {});

  //   // Find the "Add Contact" button using the key
  //   final addContactButton = find.byKey(const Key('addContactButton'));
  //   expect(addContactButton, findsOneWidget);

  //   // Tap the "Add Contact" button
  //   await tester.tap(addContactButton);
  //   await tester.pumpAndSettle();

  //   // Verify that the contact picker was called
  //   verify(mockContactPicker.selectContact()).called(1);

  //   // Verify that the contact was inserted into the database
  //   verify(mockDatabaseHelper.insertContact('New Contact', any)).called(1);

  //   // Verify that the new contact is displayed in the list
  //   expect(find.text('New Contact'), findsOneWidget);
  // });

  // testWidgets('should delete a contact when dismissed',
  //     (WidgetTester tester) async {
  //   await pumpSettingsScreen(tester);

  //   // Simulate dismissing a contact
  //   await tester.drag(find.text('John Doe'), const Offset(-500.0, 0.0));
  //   await tester.pumpAndSettle();

  //   // Verify that the contact was deleted
  //   verify(mockDatabaseHelper.deleteContact('John Doe')).called(1);
  //   expect(find.text('John Doe'), findsNothing);
  // });

  testWidgets('should toggle theme when switch is toggled',
      (WidgetTester tester) async {
    await pumpSettingsScreen(tester);

    final themeSwitch = find.byType(SwitchListTile);
    expect(themeSwitch, findsOneWidget);

    // Toggle the theme switch
    await tester.tap(themeSwitch);
    await tester.pump();

    // Verify that theme is updated in the database
    verify(mockDatabaseHelper.updatePreferences(
      any,
      any,
      true,
      any,
    )).called(1);
  });

  // testWidgets('should change font size when slider is adjusted',
  //     (WidgetTester tester) async {
  //   await pumpSettingsScreen(tester);

  //   final fontSizeSlider = find.byType(Slider).first;
  //   expect(fontSizeSlider, findsOneWidget);

  //   // Ensure the slider is visible
  //   await tester.ensureVisible(fontSizeSlider);

  //   // Adjust the slider value
  //   await tester.drag(fontSizeSlider, const Offset(100.0, 0.0));
  //   await tester.pump();

  //   // Verify that font size is updated
  //   verify(mockDatabaseHelper.updatePreferences(
  //     any,
  //     any,
  //     any,
  //     any,
  //   )).called(2);
  // });

  // testWidgets('should change speech rate when slider is adjusted',
  //     (WidgetTester tester) async {
  //   await pumpSettingsScreen(tester);

  //   final speechRateSlider = find.byType(Slider).last;
  //   expect(speechRateSlider, findsOneWidget);

  //   // Ensure the slider is visible
  //   await tester.ensureVisible(speechRateSlider);

  //   // Adjust the slider value
  //   await tester.drag(speechRateSlider, const Offset(100.0, 0.0));
  //   await tester.pump();

  //   // Verify that speech rate is updated
  //   verify(mockTtsService.updateSpeechRate(any)).called(2);
  //   verify(mockDatabaseHelper.updatePreferences(
  //     any,
  //     any,
  //     any,
  //     any,
  //   )).called(2);
  // });


  // testWidgets('should change language when a language button is pressed',
  //     (WidgetTester tester) async {
  //   await pumpSettingsScreen(tester);

  //   // Press the "Español" button
  //   final spanishButton = find.text('Español');
  //   expect(spanishButton, findsOneWidget);

  //   await tester.tap(spanishButton);
  //   await tester.pump();

  //   // Verify that language is updated
  //   verify(mockLocaleProvider.setLocale(const Locale('es', 'ES'))).called(1);
  //   verify(mockTtsService.updateLanguage('es-ES', 'es-ES-Wavenet-B')).called(1);
  //   verify(mockDatabaseHelper.updatePreferences(any, 'es-ES', any, any))
  //       .called(1);
  // });
}
