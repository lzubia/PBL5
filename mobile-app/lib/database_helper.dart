import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Lazy-loaded singleton database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 4, // Increment version for migrations
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables when the database is created
  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertDefaultData(db);
  }

  // Handle schema upgrades (when database version is increased)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Only call _createTables for versions less than 4
      await _createTables(db);
    }
  }

  // Create the tables
  Future<void> _createTables(Database db) async {
    // Settings table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS settings (
        id INTEGER PRIMARY KEY,
        languageCode TEXT,
        voiceName TEXT
      )
    ''');

    // Preferences table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS preferences (
        id INTEGER PRIMARY KEY,
        fontSize REAL,
        language TEXT,
        isDarkTheme INTEGER
      )
    ''');

    // Contacts table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    ''');
  }

  // Insert default data (if not already present)
  Future<void> _insertDefaultData(Database db) async {
    final countSettings = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM settings')) ??
        0;
    if (countSettings == 0) {
      await db.insert('settings', {
        'id': 1,
        'languageCode': 'en-US',
        'voiceName': 'en-US-Wavenet-D',
      });
    }

    final countPreferences = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM preferences')) ??
        0;
    if (countPreferences == 0) {
      await db.insert('preferences', {
        'id': 1,
        'fontSize': 20.0,
        'language': 'English',
        'isDarkTheme': 0,
      });
    }
  }

  // Insert a contact
  Future<void> insertContact(String name) async {
    final db = await database;
    await db.insert('contacts', {'name': name});
  }

  // Get all contacts
  Future<List<String>> getContacts() async {
    final db = await database;
    final result = await db.query('contacts');
    return result.map((e) => e['name'] as String).toList();
  }

  // Delete a contact by name
  Future<void> deleteContact(String name) async {
    final db = await database;
    await db.delete(
      'contacts',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  // Get preferences
  Future<Map<String, dynamic>> getPreferences() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('preferences', limit: 1);
    if (result.isNotEmpty) {
      return result[0];
    } else {
      return {
        'fontSize': 20.0,
        'language': 'English',
        'isDarkTheme': 0,
      };
    }
  }

  // Update preferences
  Future<void> updatePreferences(
      double fontSize, String language, bool isDarkTheme) async {
    final db = await database;
    await db.update(
      'preferences',
      {
        'fontSize': fontSize,
        'language': language,
        'isDarkTheme': isDarkTheme ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [1], // Assuming there's only one row for preferences
    );
  }

  // Get TTS (Text-to-Speech) settings
  Future<Map<String, String>> getTtsSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> result =
        await db.query('settings', limit: 1);
    if (result.isNotEmpty) {
      return {
        'languageCode': result[0]['languageCode'] ?? 'en-US',
        'voiceName': result[0]['voiceName'] ?? 'en-US-Wavenet-D',
      };
    } else {
      return {
        'languageCode': 'en-US',
        'voiceName': 'en-US-Wavenet-D',
      };
    }
  }

  // Update TTS settings
  Future<void> updateTtsSettings(String languageCode, String voiceName) async {
    final db = await database;
    await db.update(
      'settings',
      {'languageCode': languageCode, 'voiceName': voiceName},
      where: 'id = ?',
      whereArgs: [1], // Assuming there's only one row for TTS settings
    );
  }

  Future<void> resetDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    await deleteDatabase(path); // Deletes the database
    _database = null; // Reset the in-memory reference
  }
}
