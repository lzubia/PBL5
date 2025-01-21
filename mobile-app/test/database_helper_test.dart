// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:pbl5_menu/shared/database_helper.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// import 'database_helper_test.mocks.dart';

// @GenerateMocks([Database])
// void main() {
//   late MockDatabase mockDatabase;
//   late DatabaseHelper databaseHelper;

//   sqfliteFfiInit();
//   databaseFactory = databaseFactoryFfi;

//   setUp(() {
//     mockDatabase = MockDatabase();
//     databaseHelper = DatabaseHelper();
//     databaseHelper.database = Future.value(mockDatabase);
//   });

//   group('DatabaseHelper', () {
//     test('should return the same instance', () {
//       final instance1 = DatabaseHelper();
//       final instance2 = DatabaseHelper();
//       expect(instance1, instance2);
//     });

//     test('should initialize the database', () async {
//       when(mockDatabase.path).thenReturn('app_database.db');
//       final db = await databaseHelper.database;
//       expect(db, mockDatabase);
//     });

//     test('should create tables on database creation', () async {
//       when(mockDatabase.rawQuery(any)).thenAnswer((_) async => [
//             {'COUNT(*)': 0}
//           ]);
//       when(mockDatabase.insert(any, any)).thenAnswer((_) async => 1);

//       await databaseHelper.onCreate(mockDatabase, 1);

//       verify(mockDatabase.execute(any)).called(greaterThan(1));
//       verify(mockDatabase.insert('settings', any)).called(1);
//       verify(mockDatabase.insert('preferences', any)).called(1);
//     });

//     test('should upgrade database schema', () async {
//       await databaseHelper.onUpgrade(mockDatabase, 3, 4);
//       verify(mockDatabase.execute(any)).called(greaterThan(1));
//     });

//     test('should insert default data if not present', () async {
//       when(mockDatabase.rawQuery('SELECT COUNT(*) FROM settings'))
//           .thenAnswer((_) async => [
//                 {'COUNT(*)': 0}
//               ]);
//       when(mockDatabase.rawQuery('SELECT COUNT(*) FROM preferences'))
//           .thenAnswer((_) async => [
//                 {'COUNT(*)': 0}
//               ]);
//       when(mockDatabase.insert('settings', any)).thenAnswer((_) async => 1);
//       when(mockDatabase.insert('preferences', any)).thenAnswer((_) async => 1);

//       await databaseHelper.insertDefaultData(mockDatabase);

//       verify(mockDatabase.insert('settings', any)).called(1);
//       verify(mockDatabase.insert('preferences', any)).called(1);
//     });

//     test('should insert a contact', () async {
//       // Stub the insert method
//       when(mockDatabase.insert('contacts', {'name': 'John Doe'}))
//           .thenAnswer((_) async => 1);

//       // Call the method to test
//       await databaseHelper.insertContact('John Doe');

//       // Verify the behavior
//       verify(mockDatabase.insert('contacts', {'name': 'John Doe'})).called(1);
//     });

//     test('should get all contacts', () async {
//       when(mockDatabase.query('contacts')).thenAnswer((_) async => [
//             {'name': 'John Doe'}
//           ]);
//       final contacts = await databaseHelper.getContacts();
//       expect(contacts, ['John Doe']);
//     });

//     test('should delete a contact by name', () async {
//       // Stub the delete method
//       when(mockDatabase.delete(
//         'contacts',
//         where: 'name = ?',
//         whereArgs: ['John Doe'],
//       )).thenAnswer(
//           (_) async => 1); // Simulate successful deletion with 1 row affected

//       // Call the method to test
//       await databaseHelper.deleteContact('John Doe');

//       // Verify the behavior
//       verify(mockDatabase.delete(
//         'contacts',
//         where: 'name = ?',
//         whereArgs: ['John Doe'],
//       )).called(1);
//     });

//     test('should get preferences', () async {
//       when(mockDatabase.query('preferences')).thenAnswer((_) async => [
//             {
//               'fontSize': 20.0,
//               'language': 'English',
//               'isDarkTheme': 0,
//               'speechRate': 1.0,
//             }
//           ]);
//       final preferences = await databaseHelper.getPreferences();
//       expect(preferences, {
//         'fontSize': 20.0,
//         'language': 'English',
//         'isDarkTheme': 0,
//         'speechRate': 1.0,
//       });
//     });

//     test('should update preferences', () async {
//       // Stub the update method
//       when(mockDatabase.update(
//         'preferences',
//         {
//           'fontSize': 18.0,
//           'language': 'Spanish',
//           'isDarkTheme': 1,
//           'speechRate': 1.2,
//         },
//         where: 'id = ?',
//         whereArgs: [1],
//       )).thenAnswer(
//           (_) async => 1); // Simulate a successful update with 1 row affected

//       // Call the method to test
//       await databaseHelper.updatePreferences(18.0, 'Spanish', true, 1.2);

//       // Verify the behavior
//       verify(mockDatabase.update(
//         'preferences',
//         {
//           'fontSize': 18.0,
//           'language': 'Spanish',
//           'isDarkTheme': 1,
//           'speechRate': 1.2,
//         },
//         where: 'id = ?',
//         whereArgs: [1],
//       )).called(1);
//     });

//     test('should get TTS settings', () async {
//       when(mockDatabase.query('settings', limit: 1)).thenAnswer((_) async => [
//             {
//               'languageCode': 'en-US',
//               'voiceName': 'en-US-Wavenet-D',
//             }
//           ]);
//       final ttsSettings = await databaseHelper.getTtsSettings();
//       expect(ttsSettings, {
//         'languageCode': 'en-US',
//         'voiceName': 'en-US-Wavenet-D',
//       });
//     });

//     test('should update TTS settings', () async {
//       // Stub the update method
//       when(mockDatabase.update(
//         'settings',
//         {
//           'languageCode': 'es-ES',
//           'voiceName': 'es-ES-Wavenet-A',
//         },
//         where: 'id = ?',
//         whereArgs: [1],
//       )).thenAnswer(
//           (_) async => 1); // Simulate a successful update with 1 row affected

//       // Call the method to test
//       await databaseHelper.updateTtsSettings('es-ES', 'es-ES-Wavenet-A');

//       // Verify the behavior
//       verify(mockDatabase.update(
//         'settings',
//         {
//           'languageCode': 'es-ES',
//           'voiceName': 'es-ES-Wavenet-A',
//         },
//         where: 'id = ?',
//         whereArgs: [1],
//       )).called(1);
//     });

//     test('should reset the database', () async {
//       when(mockDatabase.close()).thenAnswer((_) async => Future.value());
//       await databaseHelper.resetDatabase();
//       verify(mockDatabase.close()).called(1);
//     });
//   });
// }
