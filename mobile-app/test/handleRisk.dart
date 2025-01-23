import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pbl5_menu/features/voice_commands.dart';
import 'package:pbl5_menu/services/stt/stt_service.dart';

import 'voice_commands_test.mocks.dart';

// Generate mocks for classes that VoiceCommands depends on
@GenerateMocks([SttService])
void main() {
  group('_handleRiskDetectionCommand Tests', () {
    late VoiceCommands voiceCommands;
    late MockSttService mockSttService;

    setUp(() {
      mockSttService = MockSttService();

      // Create an instance of VoiceCommands, injecting the mocked SttService
      voiceCommands = VoiceCommands(mockSttService);

      // Mock necessary methods
      when(mockSttService.stopListening()).thenAnswer((_) async => {});
      when(mockSttService.startListening(any)).thenAnswer((_) async => {});
    });

    test('_handleRiskDetectionCommand updates state and handles delay', () async {
      bool notified = false;

      // Listen for changes
      voiceCommands.addListener(() {
        notified = true;
      });

      // Call the method
      await voiceCommands.handleRiskDetectionCommand();

      // Verify immediate updates
      expect(voiceCommands.riskTrigger, isTrue);
      expect(voiceCommands.isActivated, isFalse);
      expect(voiceCommands.command, equals(''));
      expect(notified, isTrue);
      verify(mockSttService.stopListening()).called(1);

      // Verify startListening call, casting `any` to match the type
      verify(mockSttService.startListening(any)).called(1);

      // Wait for the 2-second delay to complete
      await Future.delayed(const Duration(seconds: 2));

      // Verify delayed update
      expect(voiceCommands.riskTrigger, isFalse);
    });
  });
}
