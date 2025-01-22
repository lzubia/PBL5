import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:provider/provider.dart';
import '../shared/database_helper.dart';
import '../locale_provider.dart';
import '../services/stt/i_tts_service.dart';
import '../services/l10n.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final FlutterNativeContactPicker _contactPicker =
      FlutterNativeContactPicker();

  // State variables
  List<Map<String, String>> contacts = [];

  double _fontSize = 20.0;
  String _language = 'English';
  bool _isDarkTheme = false;
  double _speechRate = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final dbHelper = context.read<DatabaseHelper>();
      final prefs = await dbHelper.getPreferences();
      final savedContacts =
          await dbHelper.getContacts(); // Fetch all data (name + phone)

      setState(() {
        _fontSize = prefs['fontSize'];
        _language = prefs['language'];
        _isDarkTheme = prefs['isDarkTheme'] == 1;
        _speechRate = prefs['speechRate'] ?? 1.0;

        // Populate both lists
        contacts = savedContacts;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _updatePreferences() async {
    try {
      final dbHelper = context.read<DatabaseHelper>();
      await dbHelper.updatePreferences(
        _fontSize,
        _language,
        _isDarkTheme,
        _speechRate,
      );
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  Future<void> _addContact(String contact, String number) async {
    try {
      final dbHelper = context.read<DatabaseHelper>();
      // Add the contact to the database
      await dbHelper.insertContact(contact, number);

      // Re-fetch the contacts after inserting a new one
      final updatedContacts = await dbHelper.getContacts();

      setState(() {
        // Update the contacts list
        contacts = updatedContacts;
      });
    } catch (e) {
      debugPrint('Error adding contact: $e');
    }
  }

  Future<void> _deleteContact(String contactName) async {
    try {
      final dbHelper = context.read<DatabaseHelper>();
      await dbHelper.deleteContact(contactName);

      // Re-fetch the contacts after deletion to update the list
      final updatedContacts = await dbHelper.getContacts();

      setState(() {
        contacts = updatedContacts;
      });
      debugPrint('Contact deleted: $contactName');
    } catch (e) {
      debugPrint('Error deleting contact: $e');
    }
  }

  void _changeTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
    });
    _updatePreferences();
  }

  void _changeLanguage(String languageCode, String voiceName) {
    final ttsService = context.read<ITtsService>();
    ttsService.updateLanguage(languageCode, voiceName);
    setState(() {
      _language = languageCode;
    });
    _updatePreferences();
  }

  void _changeFontSize(double size) {
    setState(() {
      _fontSize = size;
    });
    _updatePreferences();
  }

  void _changeSpeechRate(double rate) {
    final ttsService = context.read<ITtsService>();
    setState(() {
      _speechRate = rate;
    });
    ttsService.updateSpeechRate(rate);
    _updatePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeData = _isDarkTheme ? ThemeData.dark() : ThemeData.light();
    final textColor = _isDarkTheme ? Colors.white : Colors.black;

    return MaterialApp(
      theme: themeData,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 100.0,
          title: const Text('BEGIA',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, bottom: 16.0), // Exclude top padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(
                context,
                'contacts',
                textColor,
                actionButton: ElevatedButton(
                  onPressed: () async {
                    // Navigate to the map screen to select the home location
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapWidget(
                                title: 'save',
                              )),
                    );
                  },
                  child: Icon(Icons.home, size: _fontSize),
                ),
              ),
              _buildContactsList(),
              _buildAddContactButton(),
              const Divider(),
              _buildThemeSwitch(),
              const Divider(),
              _buildSectionTitle(context, 'language', textColor),
              _buildLanguageSelector(localeProvider),
              const Divider(),
              _buildSectionTitle(context, 'font_size', textColor),
              _buildFontSizeSlider(),
              const Divider(),
              _buildSectionTitle(context, 'speech_rate', textColor),
              _buildSpeechRateSlider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String key, Color color,
      {Widget? actionButton}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context).translate(key),
          style: TextStyle(
            fontSize: _fontSize + 4,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (actionButton != null)
          actionButton, // If button is provided, show it
      ],
    );
  }

  Widget _buildContactsList() {
    return Expanded(
      child: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: ValueKey(contacts[index]),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              await _deleteContact(contacts[index]['name'] ?? '');
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
                  contacts[index]['name'] ?? '',
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: _isDarkTheme
                        ? Colors.white
                        : Colors.black, // Changes based on theme
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.red,
                    size: _fontSize + 4,
                  ),
                  onPressed: () async {
                    await _deleteContact(contacts[index]['name'] ?? '');
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddContactButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          final contact = await _contactPicker.selectContact();
          if (contact == null) return;

          final contactName = contact.fullName ?? 'Unknown';
          final phoneNumber = contact.phoneNumbers?.isNotEmpty == true
              ? contact.phoneNumbers!.first
              : null;

          if (phoneNumber == null || phoneNumber.isEmpty) {
            debugPrint('No phone number found for selected contact.');
            return;
          }

          final cleanedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
          await _addContact(contactName, cleanedPhone);
        } catch (e) {
          debugPrint('Error picking contact: $e');
        }
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _buildThemeSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SwitchListTile(
        contentPadding:
            EdgeInsets.zero, // Remove padding that might be adding extra space
        title: Text(
          AppLocalizations.of(context).translate('theme'),
          style: TextStyle(
            fontSize: _fontSize + 4,
            fontWeight: FontWeight.bold,
            color:
                _isDarkTheme ? Colors.white : Colors.black, // Text color change
          ),
        ),
        value: _isDarkTheme,
        onChanged: _changeTheme,
      ),
    );
  }

  Widget _buildLanguageSelector(LocaleProvider localeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLanguageButton(localeProvider, 'ENG', 'en-US', 'en-US-Wavenet-D'),
        _buildLanguageButton(localeProvider, 'ESP', 'es-ES', 'es-ES-Wavenet-B'),
        _buildLanguageButton(localeProvider, 'EUS', 'eu-ES', 'eu-ES-Wavenet-A'),
      ],
    );
  }

  Widget _buildLanguageButton(
      LocaleProvider localeProvider, String label, String code, String voice) {
    return ElevatedButton(
      onPressed: () {
        localeProvider
            .setLocale(Locale(code.split('-')[0], code.split('-')[1]));
        _changeLanguage(code, voice);
      },
      child: Text(label, style: TextStyle(fontSize: _fontSize)),
    );
  }

  Widget _buildFontSizeSlider() {
    return Slider(
      value: _fontSize,
      min: 16.0,
      max: 38.0,
      onChanged: _changeFontSize,
    );
  }

  Widget _buildSpeechRateSlider() {
    return Slider(
      value: _speechRate,
      min: 1.0,
      max: 2.7,
      onChanged: _changeSpeechRate,
    );
  }
}
