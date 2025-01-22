import 'package:flutter/material.dart';

abstract class ITtsService {
  void initializeTts();
  Future<void> speakLabels(List<dynamic> detectedObjects, BuildContext context);
  Future<void> updateLanguage(String newLanguageCode, String newVoiceName);
  Future<void> updateSpeechRate(double newSpeechRate);
}
