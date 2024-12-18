abstract class ISttService {
  Future<void> initializeStt();
  Future<void> startListening(Function(String) onResult);
  void stopListening();
}