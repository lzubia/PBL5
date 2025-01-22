import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String defaultLocale = 'en-US';
const String defaultVoice = 'en-US-Wavenet-D';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Setter for the database
  set database(Future<Database> db) {
    db.then((database) {
      _database = database;
    });
  }

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
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
  }

  // Create tables when the database is created
  Future<void> onCreate(Database db, int version) async {
    await _createTables(db);
    await insertDefaultData(db);
  }

  // Handle schema upgrades (when database version is increased)
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
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
        isDarkTheme INTEGER,
        speechRate REAL
      )
    ''');

    // Contacts table
    await db.execute('''
    CREATE TABLE IF NOT EXISTS contacts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      phone TEXT
    )
  ''');

    // Home locations table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS home(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL,
        longitude REAL
      )
    ''');
  }

  // Insert default data (if not already present)
  Future<void> insertDefaultData(Database db) async {
    final countSettings = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM settings')) ??
        0;
    if (countSettings == 0) {
      await db.insert('settings', {
        'id': 1,
        'languageCode': defaultLocale,
        'voiceName': defaultVoice,
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
        'speechRate': 1.1,
      });
    }
  }

  // Insert a contact
  Future<void> insertContact(String name, String phone) async {
    final db = await database;
    await db.insert('contacts', {'name': name, 'phone': phone});
    debugPrint('Contact inserted: $name, $phone');
  }

  // Get all contacts
  Future<List<Map<String, String>>> getContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('contacts');
    return result.map((Map<String, dynamic> e) {
      return {
        'name': e['name'] as String,
        'phone': e['phone'] as String,
      };
    }).toList();
  }

  /// Deletes a contact by name from the database.
  ///
  /// [name] is the name of the contact to be deleted.
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
    final List<Map<String, dynamic>> result = await db.query('preferences');
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {
        'fontSize': 20.0,
        'language': 'English',
        'isDarkTheme': 0,
        'speechRate': 1.0, // Default speech rate
      };
    }
  }

  // Update preferences
  Future<void> updatePreferences(double fontSize, String language,
      bool isDarkTheme, double speechRate) async {
    final db = await database;
    await db.update(
      'preferences',
      {
        'fontSize': fontSize,
        'language': language,
        'isDarkTheme': isDarkTheme ? 1 : 0,
        'speechRate': speechRate,
      },
      where: 'id = ?',
      whereArgs: [1], // Assuming there's only one row for preferences
    );
  }

  // Get TTS (Text-to-Speech) settings
  Future<Map<String, String>> getTtsSettings() async {
    final db = await database; // Ensure the database is initialized
    try {
      final List<Map<String, dynamic>> result =
          await db.query('settings', limit: 1);
      if (result.isNotEmpty) {
        return {
          'languageCode': result[0]['languageCode'] ?? defaultLocale,
          'voiceName': result[0]['voiceName'] ?? defaultVoice,
        };
      } else {
        return {
          'languageCode': defaultLocale,
          'voiceName': defaultVoice,
        };
      }
    } catch (e) {
      debugPrint('Error fetching TTS settings: $e');
      return {
        'languageCode': defaultLocale,
        'voiceName': defaultVoice,
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

  // Insert home location into the database
  Future<void> insertHome(double latitude, double longitude) async {
    final db = await database;
    await db.insert(
      'home',
      {'latitude': latitude, 'longitude': longitude},
    );
    debugPrint('Home location inserted: $latitude, $longitude');
  }

  Future<LatLng?> getHomeLocation() async {
    final db = await database; // Replace with your database initialization
    final result = await db.query(
      'home', // Table name
      columns: ['latitude', 'longitude'], // Columns to fetch
      limit: 1, // Limit to a single entry
    );

    if (result.isNotEmpty) {
      final home = result.first;
      // Cast latitude and longitude to double
      final latitude = home['latitude'] is int
          ? (home['latitude'] as int).toDouble()
          : home['latitude'] as double;
      final longitude = home['longitude'] is int
          ? (home['longitude'] as int).toDouble()
          : home['longitude'] as double;
      return LatLng(latitude, longitude);
    }

    return null; // No home location found
  }

  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close(); // Explicitly close the database
    }
    String path = join(await getDatabasesPath(), 'app_database.db');
    await deleteDatabase(path); // Deletes the database
    _database = null; // Reset the in-memory reference

    // Reinitialize the database
    await database;
  }

  Future<void> createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE preferences (
        id INTEGER PRIMARY KEY,
        fontSize REAL,
        language TEXT,
        isDarkTheme INTEGER,
        speechRate REAL
      )
    ''');
  }
}
