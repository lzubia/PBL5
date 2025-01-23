import 'package:flutter/widgets.dart';

class WidgetStateProvider with ChangeNotifier {
  Map<String, bool> widgetStates = {
    'Money Identifier': false,
    'GPS (Map)': false,
    'Scanner (Read Texts, QRs, ...)': false,
    'Describe Environment': false,
  };

  void setWidgetState(String widgetName, bool state) {
    widgetStates[widgetName] = state;
    notifyListeners();
  }

  bool getWidgetState(String widgetName) {
    return widgetStates[widgetName] ?? false;
  }
}
