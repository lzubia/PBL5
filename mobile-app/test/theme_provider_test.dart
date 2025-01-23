import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pbl5_menu/theme_provider.dart';

void main() {
  late ThemeProvider themeProvider;

  setUp(() {
    themeProvider = ThemeProvider();
  });

  group('ThemeProvider Tests', () {
    test('Initial theme is light', () {
      expect(themeProvider.currentTheme, ThemeData.light());
    });

    test('toggleTheme switches from light to dark', () {
      themeProvider.toggleTheme();
      expect(themeProvider.currentTheme, ThemeData.dark());
    });

    test('toggleTheme switches from dark to light', () {
      themeProvider.toggleTheme(); // Switch to dark
      themeProvider.toggleTheme(); // Switch back to light
      expect(themeProvider.currentTheme, ThemeData.light());
    });

    test('toggleTheme notifies listeners', () {
      bool listenerCalled = false;

      themeProvider.addListener(() {
        listenerCalled = true;
      });

      themeProvider.toggleTheme();

      expect(listenerCalled, isTrue);
    });
  });
}
