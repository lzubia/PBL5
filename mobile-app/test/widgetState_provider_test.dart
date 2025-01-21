import 'package:flutter_test/flutter_test.dart';
import 'package:pbl5_menu/widgetState_provider.dart';

void main() {
  late WidgetStateProvider widgetStateProvider;

  setUp(() {
    widgetStateProvider = WidgetStateProvider();
  });

  group('WidgetStateProvider Tests', () {
    test('Initial state of widgets is false', () {
      expect(widgetStateProvider.getWidgetState('Money Identifier'), isFalse);
      expect(widgetStateProvider.getWidgetState('GPS (Map)'), isFalse);
      expect(
          widgetStateProvider.getWidgetState('Scanner (Read Texts, QRs, ...)'),
          isFalse);
      expect(
          widgetStateProvider.getWidgetState('Describe Environment'), isFalse);
    });

    test('setWidgetState updates the state of a widget', () {
      widgetStateProvider.setWidgetState('Money Identifier', true);

      expect(widgetStateProvider.getWidgetState('Money Identifier'), isTrue);
    });

    test('getWidgetState returns false for unknown widget', () {
      expect(widgetStateProvider.getWidgetState('Unknown Widget'), isFalse);
    });

    test('setWidgetState notifies listeners', () {
      bool listenerCalled = false;

      widgetStateProvider.addListener(() {
        listenerCalled = true;
      });

      widgetStateProvider.setWidgetState('GPS (Map)', true);

      expect(listenerCalled, isTrue);
    });

    test('setWidgetState does not throw an error for new widgets', () {
      expect(() => widgetStateProvider.setWidgetState('New Widget', true),
          returnsNormally);
      expect(widgetStateProvider.getWidgetState('New Widget'), isTrue);
    });
  });
}
