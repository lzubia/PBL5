import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en', 'US');
  Iterable<Locale> supportedLocales = [
    const Locale('en', 'US'),
    const Locale('es', 'ES'),
    const Locale('eu', 'ES'),
  ];

  Locale get currentLocale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('locale', locale.toString());
  }

  void _loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? localeString = prefs.getString('locale');
    if (localeString != null) {
      List<String> localeParts = localeString.split('_');
      if (localeParts.length == 2) {
        _locale = Locale(localeParts[0], localeParts[1]);
      } else {
        _locale = Locale(localeParts[0]);
      }
      notifyListeners();
    }
  }
}
