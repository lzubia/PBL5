// Mocks generated by Mockito 5.4.4 from annotations
// in pbl5_menu/test/tts_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:ui' as _i4;

import 'package:flutter/services.dart' as _i6;
import 'package:flutter_tts/flutter_tts.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:pbl5_menu/shared/database_helper.dart' as _i7;
import 'package:sqflite/sqflite.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeSpeechRateValidRange_0 extends _i1.SmartFake
    implements _i2.SpeechRateValidRange {
  _FakeSpeechRateValidRange_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDatabase_1 extends _i1.SmartFake implements _i3.Database {
  _FakeDatabase_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [FlutterTts].
///
/// See the documentation for Mockito's code generation for more information.
class MockFlutterTts extends _i1.Mock implements _i2.FlutterTts {
  MockFlutterTts() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set startHandler(_i4.VoidCallback? _startHandler) => super.noSuchMethod(
        Invocation.setter(
          #startHandler,
          _startHandler,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set completionHandler(_i4.VoidCallback? _completionHandler) =>
      super.noSuchMethod(
        Invocation.setter(
          #completionHandler,
          _completionHandler,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set pauseHandler(_i4.VoidCallback? _pauseHandler) => super.noSuchMethod(
        Invocation.setter(
          #pauseHandler,
          _pauseHandler,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set continueHandler(_i4.VoidCallback? _continueHandler) => super.noSuchMethod(
        Invocation.setter(
          #continueHandler,
          _continueHandler,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set cancelHandler(_i4.VoidCallback? _cancelHandler) => super.noSuchMethod(
        Invocation.setter(
          #cancelHandler,
          _cancelHandler,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set progressHandler(_i2.ProgressHandler? _progressHandler) =>
      super.noSuchMethod(
        Invocation.setter(
          #progressHandler,
          _progressHandler,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set errorHandler(_i2.ErrorHandler? _errorHandler) => super.noSuchMethod(
        Invocation.setter(
          #errorHandler,
          _errorHandler,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<int?> get getMaxSpeechInputLength => (super.noSuchMethod(
        Invocation.getter(#getMaxSpeechInputLength),
        returnValue: _i5.Future<int?>.value(),
      ) as _i5.Future<int?>);

  @override
  _i5.Future<dynamic> get getLanguages => (super.noSuchMethod(
        Invocation.getter(#getLanguages),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> get getEngines => (super.noSuchMethod(
        Invocation.getter(#getEngines),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> get getDefaultEngine => (super.noSuchMethod(
        Invocation.getter(#getDefaultEngine),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> get getDefaultVoice => (super.noSuchMethod(
        Invocation.getter(#getDefaultVoice),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> get getVoices => (super.noSuchMethod(
        Invocation.getter(#getVoices),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<_i2.SpeechRateValidRange> get getSpeechRateValidRange =>
      (super.noSuchMethod(
        Invocation.getter(#getSpeechRateValidRange),
        returnValue: _i5.Future<_i2.SpeechRateValidRange>.value(
            _FakeSpeechRateValidRange_0(
          this,
          Invocation.getter(#getSpeechRateValidRange),
        )),
      ) as _i5.Future<_i2.SpeechRateValidRange>);

  @override
  _i5.Future<dynamic> awaitSpeakCompletion(bool? awaitCompletion) =>
      (super.noSuchMethod(
        Invocation.method(
          #awaitSpeakCompletion,
          [awaitCompletion],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> awaitSynthCompletion(bool? awaitCompletion) =>
      (super.noSuchMethod(
        Invocation.method(
          #awaitSynthCompletion,
          [awaitCompletion],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> speak(
    String? text, {
    bool? focus = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #speak,
          [text],
          {#focus: focus},
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> pause() => (super.noSuchMethod(
        Invocation.method(
          #pause,
          [],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> synthesizeToFile(
    String? text,
    String? fileName, [
    bool? isFullPath = false,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #synthesizeToFile,
          [
            text,
            fileName,
            isFullPath,
          ],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> setLanguage(String? language) => (super.noSuchMethod(
        Invocation.method(
          #setLanguage,
          [language],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> setSpeechRate(double? rate) => (super.noSuchMethod(
        Invocation.method(
          #setSpeechRate,
          [rate],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> setVolume(double? volume) => (super.noSuchMethod(
        Invocation.method(
          #setVolume,
          [volume],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> setSharedInstance(bool? sharedSession) =>
      (super.noSuchMethod(
        Invocation.method(
          #setSharedInstance,
          [sharedSession],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> autoStopSharedSession(bool? autoStop) =>
      (super.noSuchMethod(
        Invocation.method(
          #autoStopSharedSession,
          [autoStop],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> setIosAudioCategory(
    _i2.IosTextToSpeechAudioCategory? category,
    List<_i2.IosTextToSpeechAudioCategoryOptions>? options, [
    _i2.IosTextToSpeechAudioMode? mode =
        _i2.IosTextToSpeechAudioMode.defaultMode,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #setIosAudioCategory,
          [
            category,
            options,
            mode,
          ],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> setEngine(String? engine) => (super.noSuchMethod(
        Invocation.method(
          #setEngine,
          [engine],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> setPitch(double? pitch) => (super.noSuchMethod(
        Invocation.method(
          #setPitch,
          [pitch],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> setVoice(Map<String, String>? voice) =>
      (super.noSuchMethod(
        Invocation.method(
          #setVoice,
          [voice],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> clearVoice() => (super.noSuchMethod(
        Invocation.method(
          #clearVoice,
          [],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> stop() => (super.noSuchMethod(
        Invocation.method(
          #stop,
          [],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> isLanguageAvailable(String? language) =>
      (super.noSuchMethod(
        Invocation.method(
          #isLanguageAvailable,
          [language],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> isLanguageInstalled(String? language) =>
      (super.noSuchMethod(
        Invocation.method(
          #isLanguageInstalled,
          [language],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> areLanguagesInstalled(List<String>? languages) =>
      (super.noSuchMethod(
        Invocation.method(
          #areLanguagesInstalled,
          [languages],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> setSilence(int? timems) => (super.noSuchMethod(
        Invocation.method(
          #setSilence,
          [timems],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<dynamic> setQueueMode(int? queueMode) => (super.noSuchMethod(
        Invocation.method(
          #setQueueMode,
          [queueMode],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  void setStartHandler(_i4.VoidCallback? callback) => super.noSuchMethod(
        Invocation.method(
          #setStartHandler,
          [callback],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setCompletionHandler(_i4.VoidCallback? callback) => super.noSuchMethod(
        Invocation.method(
          #setCompletionHandler,
          [callback],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setContinueHandler(_i4.VoidCallback? callback) => super.noSuchMethod(
        Invocation.method(
          #setContinueHandler,
          [callback],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setPauseHandler(_i4.VoidCallback? callback) => super.noSuchMethod(
        Invocation.method(
          #setPauseHandler,
          [callback],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setCancelHandler(_i4.VoidCallback? callback) => super.noSuchMethod(
        Invocation.method(
          #setCancelHandler,
          [callback],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setProgressHandler(_i2.ProgressHandler? callback) => super.noSuchMethod(
        Invocation.method(
          #setProgressHandler,
          [callback],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void setErrorHandler(_i2.ErrorHandler? handler) => super.noSuchMethod(
        Invocation.method(
          #setErrorHandler,
          [handler],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<dynamic> platformCallHandler(_i6.MethodCall? call) =>
      (super.noSuchMethod(
        Invocation.method(
          #platformCallHandler,
          [call],
        ),
        returnValue: _i5.Future<dynamic>.value(),
      ) as _i5.Future<dynamic>);

  @override
  _i5.Future<void> setAudioAttributesForNavigation() => (super.noSuchMethod(
        Invocation.method(
          #setAudioAttributesForNavigation,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}

/// A class which mocks [DatabaseHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabaseHelper extends _i1.Mock implements _i7.DatabaseHelper {
  MockDatabaseHelper() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set database(_i5.Future<_i3.Database>? db) => super.noSuchMethod(
        Invocation.setter(
          #database,
          db,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<_i3.Database> get database => (super.noSuchMethod(
        Invocation.getter(#database),
        returnValue: _i5.Future<_i3.Database>.value(_FakeDatabase_1(
          this,
          Invocation.getter(#database),
        )),
      ) as _i5.Future<_i3.Database>);

  @override
  _i5.Future<void> onCreate(
    _i3.Database? db,
    int? version,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #onCreate,
          [
            db,
            version,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> onUpgrade(
    _i3.Database? db,
    int? oldVersion,
    int? newVersion,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #onUpgrade,
          [
            db,
            oldVersion,
            newVersion,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> insertDefaultData(_i3.Database? db) => (super.noSuchMethod(
        Invocation.method(
          #insertDefaultData,
          [db],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> insertContact(String? name) => (super.noSuchMethod(
        Invocation.method(
          #insertContact,
          [name],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<List<String>> getContacts() => (super.noSuchMethod(
        Invocation.method(
          #getContacts,
          [],
        ),
        returnValue: _i5.Future<List<String>>.value(<String>[]),
      ) as _i5.Future<List<String>>);

  @override
  _i5.Future<void> deleteContact(String? name) => (super.noSuchMethod(
        Invocation.method(
          #deleteContact,
          [name],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<Map<String, dynamic>> getPreferences() => (super.noSuchMethod(
        Invocation.method(
          #getPreferences,
          [],
        ),
        returnValue:
            _i5.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i5.Future<Map<String, dynamic>>);

  @override
  _i5.Future<void> updatePreferences(
    double? fontSize,
    String? language,
    bool? isDarkTheme,
    double? speechRate,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updatePreferences,
          [
            fontSize,
            language,
            isDarkTheme,
            speechRate,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<Map<String, String>> getTtsSettings() => (super.noSuchMethod(
        Invocation.method(
          #getTtsSettings,
          [],
        ),
        returnValue: _i5.Future<Map<String, String>>.value(<String, String>{}),
      ) as _i5.Future<Map<String, String>>);

  @override
  _i5.Future<void> updateTtsSettings(
    String? languageCode,
    String? voiceName,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateTtsSettings,
          [
            languageCode,
            voiceName,
          ],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);

  @override
  _i5.Future<void> resetDatabase() => (super.noSuchMethod(
        Invocation.method(
          #resetDatabase,
          [],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
}
