import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../shared/database_helper.dart';
import '../locale_provider.dart';
import '../services/stt/i_tts_service.dart';
import '../services/l10n.dart';

class SettingsScreen extends StatefulWidget {
  final ITtsService ttsServiceGoogle;
  final DatabaseHelper databaseHelper;

  const SettingsScreen({
    required this.ttsServiceGoogle,
    required this.databaseHelper,
    super.key,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();

  // State variables
  List<String> contacts = [];
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
      final prefs = await widget.databaseHelper.getPreferences();
      final savedContacts = await widget.databaseHelper.getContacts();

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
      await widget.databaseHelper.updatePreferences(
        _fontSize,
        _language,
        _isDarkTheme,
        _speechRate,
      );
    } catch (e) {
      debugPrint('Error saving preferences: $e');
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
  }

  void _changeTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
    });
    _updatePreferences();
  }

  void _changeLanguage(String languageCode, String voiceName) {
    widget.ttsServiceGoogle.updateLanguage(languageCode, voiceName);
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
    widget.ttsServiceGoogle.updateSpeechRate(rate);
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
          title: Text(
            AppLocalizations.of(context).translate('title'),
            style: const TextStyle(fontSize: 24.0),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'contacts', textColor),
              _buildContactsList(),
              _buildAddContactButton(),
              const Divider(),
              _buildSectionTitle(context, 'theme', textColor),
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

  Widget _buildSectionTitle(BuildContext context, String key, Color color) {
    return Text(
      AppLocalizations.of(context).translate(key),
      style: TextStyle(fontSize: _fontSize + 4, fontWeight: FontWeight.bold, color: color),
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
            onDismissed: (_) => _deleteContact(contacts[index]),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              title: Text(contacts[index], style: TextStyle(fontSize: _fontSize)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddContactButton() {
    return ElevatedButton(
      onPressed: () async {
        final contact = await _contactPicker.selectContact();
        if (contact != null) await _addContact(contact.fullName ?? '');
      },
      child: const Icon(Icons.add),
    );
  }

  Widget _buildThemeSwitch() {
    return SwitchListTile(
      title: const Text('Dark Theme'),
      value: _isDarkTheme,
      onChanged: _changeTheme,
    );
  }

  Widget _buildLanguageSelector(LocaleProvider localeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLanguageButton(localeProvider, 'English', 'en-US', 'en-US-Wavenet-D'),
        _buildLanguageButton(localeProvider, 'Español', 'es-ES', 'es-ES-Wavenet-B'),
        _buildLanguageButton(localeProvider, 'Euskera', 'eu-ES', 'eu-ES-Wavenet-A'),
      ],
    );
  }

  Widget _buildLanguageButton(
      LocaleProvider localeProvider, String label, String code, String voice) {
    return ElevatedButton(
      onPressed: () {
        localeProvider.setLocale(Locale(code.split('-')[0], code.split('-')[1]));
        _changeLanguage(code, voice);
      },
      child: Text(label),
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
