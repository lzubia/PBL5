import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter/services.dart'; // For vibration
import 'database_helper.dart';
import 'package:pbl5_menu/tts_service_google.dart';

class SettingsScreen extends StatefulWidget {
  final TtsServiceGoogle ttsService;
  final DatabaseHelper databaseHelper;

  const SettingsScreen({
    required this.ttsService,
    required this.databaseHelper,
    super.key,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<String> contacts = [];
  double _fontSize = 20.0; // Larger default font size
  String _language = 'English';
  bool _isDarkTheme = false;

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
          .updatePreferences(_fontSize, _language, _isDarkTheme);
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
    widget.ttsService.updateLanguage(languageCode, voiceName);
    setState(() {
      _language = languageCode;
    });
    _savePreferences();
    widget.databaseHelper
        .updateTtsSettings(languageCode, voiceName); // Update the database
    //_provideFeedback('Language changed');
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
            'BEGIA',
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
                'Contacts',
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
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
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
                    _addContact(contact.fullName ?? '');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: Icon(
                  Icons.add,
                  size: _fontSize,
                  color: Colors.white,
                ),
              ),
              Divider(),
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: _fontSize + 4,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SwitchListTile(
                title: Text(
                  'Dark Theme',
                  style: TextStyle(fontSize: _fontSize, color: textColor),
                ),
                value: _isDarkTheme,
                onChanged: _changeTheme,
              ),
              Divider(),
              Text(
                'Language',
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
                      ...languages.map((language) {
                        String fullText = language['label']!;
                        String shortText = language['label']!.substring(0, 3);

                        return ElevatedButton(
                          onPressed: () => _changeLanguage(
                              language['languageCode']!,
                              language['voiceName']!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _language == language['languageCode']
                                    ? Colors.blue
                                    : Colors.grey,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                          ),
                          child: Text(
                            isCompact ? shortText : fullText,
                            style: TextStyle(
                                fontSize: _fontSize, color: Colors.white),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
              Divider(),
              Text(
                'Font Size',
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
            ],
          ),
        ),
      ),
    );
  }
}
