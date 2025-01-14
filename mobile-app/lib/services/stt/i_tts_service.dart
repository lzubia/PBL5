abstract class ITtsService {
  void initializeTts();
  Future<void> speakLabels(List<dynamic> detectedObjects);
  Future<void> updateLanguage(String newLanguageCode, String newVoiceName);
  Future<void> updateSpeechRate(double newSpeechRate);
}