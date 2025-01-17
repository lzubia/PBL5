import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter/services.dart'; // For vibration
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import '../shared/database_helper.dart';
import 'package:pbl5_menu/services/l10n.dart';

class SettingsScreen extends StatefulWidget {
  final ITtsService ttsServiceGoogle;
  final DatabaseHelper databaseHelper;
  final Function(Locale) setLocale;

  const SettingsScreen({
    required this.ttsServiceGoogle,
    required this.databaseHelper,
    required this.setLocale,
    super.key,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  List<String> contacts = [];
  double _fontSize = 20.0; // Larger default font size
  String _language = 'English';
  bool _isDarkTheme = false;
  double _speechRate = 1.0; // Default speech rate

  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await widget.databaseHelper.getPreferences();
      final savedContacts = await widget.databaseHelper.getContacts();

      setState(() {
        _fontSize = prefs['fontSize'];
        _language = prefs['language'];
        _isDarkTheme = prefs['isDarkTheme'] == 1 ? true : false;
        _speechRate = prefs['speechRate'] ?? 1.0;
        contacts = savedContacts;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _addContact(String contact) async {
    try {
      await widget.databaseHelper.insertContact(contact);
      setState(() {
        contacts.add(contact);
      });
    } catch (e) {
      debugPrint('Error adding contact: $e');
    }
  }

  Future<void> _deleteContact(String contact) async {
    await widget.databaseHelper.deleteContact(contact);
    setState(() {
      contacts.remove(contact);
    });
    //_provideFeedback('Contact deleted');
  }

  Future<void> _savePreferences() async {
    try {
      await widget.databaseHelper
          .updatePreferences(_fontSize, _language, _isDarkTheme, _speechRate);
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  void _changeTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
    });
    _savePreferences();
  }

  void _changeLanguage(String languageCode, String voiceName) {
    widget.ttsServiceGoogle.updateLanguage(languageCode, voiceName);
    setState(() {
      _language = languageCode;
    });
    _savePreferences();
    widget.databaseHelper
        .updateTtsSettings(languageCode, voiceName); // Update the database
    //_provideFeedback('Language changed');
  }

  void _changeSpeechRate(double rate) {
    setState(() {
      _speechRate = rate;
    });
    widget.ttsServiceGoogle.updateSpeechRate(rate);
    _savePreferences();
  }

  void _changeFontSize(double size) {
    setState(() {
      _fontSize = size;
    });
    _savePreferences();
    //_provideFeedback('Font size adjusted');
  }

  void _provideFeedback(String message) {
    // Vibrate for tactile feedback
    HapticFeedback.vibrate();
    // Optional: Add auditory feedback here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: _fontSize, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeData = _isDarkTheme ? ThemeData.dark() : ThemeData.light();
    final textColor = _isDarkTheme ? Colors.white : Colors.black;

    // Language options
    final List<Map<String, String>> languages = [
      {
        "label": "English",
        "languageCode": "en-US",
        "voiceName": "en-US-Wavenet-D"
      },
      {
        "label": "Spanish",
        "languageCode": "es-ES",
        "voiceName": "es-ES-Wavenet-B"
      },
      {
        "label": "Basque",
        "languageCode": "eu-ES",
        "voiceName": "eu-ES-Wavenet-A"
      },
    ];

    return MaterialApp(
      theme: themeData,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('title'),
            style: TextStyle(fontSize: 24.0), // Increase font size
          ),
          centerTitle: true,
          backgroundColor: themeData.primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).translate('contacts'),
                style: TextStyle(
                  fontSize: _fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: ValueKey(contacts[index]),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await _deleteContact(contacts[index]);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            contacts[index],
                            style: TextStyle(
                                fontSize: _fontSize, color: textColor),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.red,
                              size: _fontSize + 4,
                            ),
                            onPressed: () async {
                              await _deleteContact(contacts[index]);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Contact? contact = await _contactPicker.selectContact();
                  if (contact != null) {
                    await _addContact(contact.fullName ?? '');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: Icon(
                  Icons.add,
                  size: _fontSize,
                  color: Colors.white,
                ),
              ),
              const Divider(),
              Text(
                AppLocalizations.of(context).translate('theme'),
                style: TextStyle(
                  fontSize: _fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SwitchListTile(
                title: Text(
                  AppLocalizations.of(context).translate('dark_theme'),
                  style: TextStyle(fontSize: _fontSize, color: textColor),
                ),
                value: _isDarkTheme,
                onChanged: _changeTheme,
              ),
              const Divider(),
              Text(
                AppLocalizations.of(context).translate('language'),
                style: TextStyle(
                  fontSize: _fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate compactness dynamically based on screen width, height, and font size
                  double screenWidth = constraints.maxWidth;
                  double screenHeight = MediaQuery.of(context).size.height;
                  bool isCompact = (screenWidth / _fontSize < 18.0) ||
                      (screenHeight / _fontSize < 18.0);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          widget.setLocale(Locale('en', 'US'));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                        ),
                        child: Text(
                          'English',
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.setLocale(Locale('es', 'ES'));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                        ),
                        child: Text(
                          'Español',
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          widget.setLocale(Locale('eu', 'ES'));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                        ),
                        child: Text(
                          'Euskera',
                          style: TextStyle(
                              fontSize: _fontSize, color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Divider(),
              Text(
                AppLocalizations.of(context).translate('font_size'),
                style: TextStyle(
                  fontSize: _fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Slider(
                value: _fontSize,
                min: 16.0,
                max: 38.0,
                onChanged: _changeFontSize,
              ),
              const Divider(),
              Text(
                AppLocalizations.of(context).translate('speech_rate'),
                style: TextStyle(
                  fontSize: _fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Slider(
                value: _speechRate,
                min: 1,
                max: 2.7,
                divisions: 15,
                label: _speechRate.toStringAsFixed(1),
                onChanged: _changeSpeechRate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
