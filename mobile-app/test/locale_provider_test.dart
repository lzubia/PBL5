import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbl5_menu/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_provider_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    SharedPreferences.setMockInitialValues({}); // Mock initial values
  });

  group('LocaleProvider Tests', () {
    test('Default locale is English (en_US)', () {
      final localeProvider = LocaleProvider();
      expect(localeProvider.currentLocale, const Locale('en', 'US'));
    });

    test('setLocale updates locale and saves to SharedPreferences', () async {
      final localeProvider = LocaleProvider();

      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({}); // Empty initial values
      SharedPreferences prefs = await SharedPreferences.getInstance();

      localeProvider.setLocale(const Locale('es', 'ES'));

      await Future.delayed(
          const Duration(milliseconds: 500)); // Small delay for async ops

      // Verify the locale is updated
      expect(localeProvider.currentLocale, const Locale('es', 'ES'));

      // Verify that the locale is saved in SharedPreferences
      expect(prefs.getString('locale'), 'es_ES');
    });

    test('setLocale notifies listeners', () async {
      final localeProvider = LocaleProvider();
      bool isListenerNotified = false;

      // Add a listener to verify that it gets called
      localeProvider.addListener(() {
        isListenerNotified = true;
      });

      localeProvider.setLocale(const Locale('eu', 'ES'));

      // Wait for the async SharedPreferences save operation
      await Future.delayed(const Duration(milliseconds: 500));

      expect(isListenerNotified, isTrue);
      expect(localeProvider.currentLocale, const Locale('eu', 'ES'));
    });

    test('_loadLocale loads locale from SharedPreferences', () async {
      // Mock SharedPreferences with an existing locale value
      SharedPreferences.setMockInitialValues({'locale': 'es_ES'});

      final localeProvider = LocaleProvider();

      // Wait for async _loadLocale to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify the locale is loaded from SharedPreferences
      expect(localeProvider.currentLocale, const Locale('es', 'ES'));
    });

    test('_loadLocale uses default locale when no saved locale exists',
        () async {
      // Mock SharedPreferences with no saved locale
      SharedPreferences.setMockInitialValues({});

      final localeProvider = LocaleProvider();

      // Wait for async _loadLocale to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Verify the default locale is used
      expect(localeProvider.currentLocale, const Locale('en', 'US'));
    });

    test('Supported locales are correctly defined', () {
      final localeProvider = LocaleProvider();

      // Verify supported locales
      expect(
        localeProvider.supportedLocales,
        containsAll([
          const Locale('en', 'US'),
          const Locale('es', 'ES'),
          const Locale('eu', 'ES'),
        ]),
      );
    });
  });
}
