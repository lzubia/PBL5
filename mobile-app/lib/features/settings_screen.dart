import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:provider/provider.dart';
import '../shared/database_helper.dart';
import '../locale_provider.dart';
import '../services/stt/i_tts_service.dart';
import '../services/l10n.dart';

class SettingsScreen extends StatefulWidget {
  final FlutterNativeContactPicker? contactPicker;

  const SettingsScreen({super.key, this.contactPicker});

  @override
  SettingsScreenState createState() => SettingsScreenState();

  static bool kTestMode = false; // Static variable for test mode
}

class SettingsScreenState extends State<SettingsScreen> {
  late FlutterNativeContactPicker _contactPicker;

  // State variables
  List<Map<String, String>> contacts = [];
  Timer? _debounceTimer;
  double _fontSize = 20.0;
  String _language = 'English';
  bool _isDarkTheme = false;
  double _speechRate = 1.0;

  @override
  void initState() {
    super.initState();
    _contactPicker = widget.contactPicker ?? FlutterNativeContactPicker();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final dbHelper = context.read<DatabaseHelper>();
      final prefs = await dbHelper.getPreferences();
      final savedContacts = await dbHelper.getContacts();

      setState(() {
        _fontSize = prefs['fontSize'];
        _language = prefs['language'];
        _isDarkTheme = prefs['isDarkTheme'] == 1;
        _speechRate = prefs['speechRate'] ?? 1.0;
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
      await dbHelper.insertContact(contact, number);
      final updatedContacts = await dbHelper.getContacts();

      setState(() {
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
      final updatedContacts = await dbHelper.getContacts();

      setState(() {
        contacts = updatedContacts;
      });
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
    setState(() {
      _speechRate = rate;
    });

    debugPrint('Speech rate changed to: $rate');

    if (SettingsScreen.kTestMode) {
      // Call directly in test mode
      final ttsService = context.read<ITtsService>();
      ttsService.updateSpeechRate(rate);
      _updatePreferences();
    } else {
      // Debounced call
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        final ttsService = context.read<ITtsService>();
        ttsService.updateSpeechRate(rate);
        _updatePreferences();
      });
    }
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
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  context,
                  'contacts',
                  textColor,
                  actionButton: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MapWidget(title: 'save'),
                        ),
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
        if (actionButton != null) actionButton,
      ],
    );
  }

  Widget _buildContactsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: ValueKey(contacts[index]),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => _deleteContact(contacts[index]['name'] ?? ''),
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
                  color: _isDarkTheme ? Colors.white : Colors.black,
                ),
              ),
              trailing: IconButton(
                icon:
                    Icon(Icons.cancel, color: Colors.red, size: _fontSize + 4),
                onPressed: () => _deleteContact(contacts[index]['name'] ?? ''),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddContactButton() {
    return ElevatedButton(
      key: const Key('addContactButton'),
      onPressed: () async {
        try {
          final contact = await _contactPicker.selectContact();
          if (contact == null) return;

          final contactName = contact.fullName ?? 'Unknown';
          final phoneNumber = contact.phoneNumbers?.first ?? '';

          if (phoneNumber.isEmpty) {
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
    return SwitchListTile(
      title: Text(
        AppLocalizations.of(context).translate('theme'),
        style: TextStyle(
          fontSize: _fontSize + 4,
          fontWeight: FontWeight.bold,
          color: _isDarkTheme ? Colors.white : Colors.black,
        ),
      ),
      value: _isDarkTheme,
      onChanged: _changeTheme,
    );
  }

  Widget _buildLanguageSelector(LocaleProvider localeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLanguageButton(localeProvider, 'ENG', 'en-US', 'en-US-Wavenet-D'),
        _buildLanguageButton(localeProvider, 'ESP', 'es-ES', 'es-ES-Wavenet-B'),
        _buildLanguageButton(
            localeProvider, 'EUS', 'eu-ES', 'eu-ES-Standard-A'),
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
