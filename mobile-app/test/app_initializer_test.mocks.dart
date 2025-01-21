// Mocks generated by Mockito 5.4.4 from annotations
// in pbl5_menu/test/app_initializer_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i14;
import 'dart:convert' as _i19;
import 'dart:io' as _i5;
import 'dart:typed_data' as _i20;
import 'dart:ui' as _i10;

import 'package:audioplayers/audioplayers.dart' as _i8;
import 'package:camera/camera.dart' as _i2;
import 'package:flutter/material.dart' as _i6;
import 'package:http/http.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i15;
import 'package:pbl5_menu/features/voice_commands.dart' as _i18;
import 'package:pbl5_menu/services/picture_service.dart' as _i4;
import 'package:pbl5_menu/services/stt/i_tts_service.dart' as _i12;
import 'package:pbl5_menu/services/stt/stt_service.dart' as _i11;
import 'package:pbl5_menu/services/tts/tts_service_google.dart' as _i17;
import 'package:pbl5_menu/shared/database_helper.dart' as _i16;
import 'package:pbl5_menu/widgetState_provider.dart' as _i13;
import 'package:speech_to_text/speech_to_text.dart' as _i9;
import 'package:sqflite/sqflite.dart' as _i7;

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

class _FakeCameraController_0 extends _i1.SmartFake
    implements _i2.CameraController {
  _FakeCameraController_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeClient_1 extends _i1.SmartFake implements _i3.Client {
  _FakeClient_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeImageDecoder_2 extends _i1.SmartFake implements _i4.ImageDecoder {
  _FakeImageDecoder_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeMultipartFileWrapper_3 extends _i1.SmartFake
    implements _i4.MultipartFileWrapper {
  _FakeMultipartFileWrapper_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFile_4 extends _i1.SmartFake implements _i5.File {
  _FakeFile_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeMultipartRequest_5 extends _i1.SmartFake
    implements _i3.MultipartRequest {
  _FakeMultipartRequest_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWidget_6 extends _i1.SmartFake implements _i6.Widget {
  _FakeWidget_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );

  @override
  String toString({_i6.DiagnosticLevel? minLevel = _i6.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeDatabase_7 extends _i1.SmartFake implements _i7.Database {
  _FakeDatabase_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAudioPlayer_8 extends _i1.SmartFake implements _i8.AudioPlayer {
  _FakeAudioPlayer_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSpeechToText_9 extends _i1.SmartFake implements _i9.SpeechToText {
  _FakeSpeechToText_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLocale_10 extends _i1.SmartFake implements _i10.Locale {
  _FakeLocale_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSttService_11 extends _i1.SmartFake implements _i11.SttService {
  _FakeSttService_11(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeITtsService_12 extends _i1.SmartFake implements _i12.ITtsService {
  _FakeITtsService_12(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeWidgetStateProvider_13 extends _i1.SmartFake
    implements _i13.WidgetStateProvider {
  _FakeWidgetStateProvider_13(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeResponse_14 extends _i1.SmartFake implements _i3.Response {
  _FakeResponse_14(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamedResponse_15 extends _i1.SmartFake
    implements _i3.StreamedResponse {
  _FakeStreamedResponse_15(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [PictureService].
///
/// See the documentation for Mockito's code generation for more information.
class MockPictureService extends _i1.Mock implements _i4.PictureService {
  MockPictureService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.CameraController get controller => (super.noSuchMethod(
        Invocation.getter(#controller),
        returnValue: _FakeCameraController_0(
          this,
          Invocation.getter(#controller),
        ),
      ) as _i2.CameraController);

  @override
  set controller(_i2.CameraController? _controller) => super.noSuchMethod(
        Invocation.setter(
          #controller,
          _controller,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.Client get httpClient => (super.noSuchMethod(
        Invocation.getter(#httpClient),
        returnValue: _FakeClient_1(
          this,
          Invocation.getter(#httpClient),
        ),
      ) as _i3.Client);

  @override
  set httpClient(_i3.Client? _httpClient) => super.noSuchMethod(
        Invocation.setter(
          #httpClient,
          _httpClient,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get isCameraInitialized => (super.noSuchMethod(
        Invocation.getter(#isCameraInitialized),
        returnValue: false,
      ) as bool);

  @override
  set isCameraInitialized(bool? _isCameraInitialized) => super.noSuchMethod(
        Invocation.setter(
          #isCameraInitialized,
          _isCameraInitialized,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.ImageDecoder get imageDecoder => (super.noSuchMethod(
        Invocation.getter(#imageDecoder),
        returnValue: _FakeImageDecoder_2(
          this,
          Invocation.getter(#imageDecoder),
        ),
      ) as _i4.ImageDecoder);

  @override
  set imageDecoder(_i4.ImageDecoder? _imageDecoder) => super.noSuchMethod(
        Invocation.setter(
          #imageDecoder,
          _imageDecoder,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.MultipartFileWrapper get multipartFileWrapper => (super.noSuchMethod(
        Invocation.getter(#multipartFileWrapper),
        returnValue: _FakeMultipartFileWrapper_3(
          this,
          Invocation.getter(#multipartFileWrapper),
        ),
      ) as _i4.MultipartFileWrapper);

  @override
  set multipartFileWrapper(_i4.MultipartFileWrapper? _multipartFileWrapper) =>
      super.noSuchMethod(
        Invocation.setter(
          #multipartFileWrapper,
          _multipartFileWrapper,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.File Function(String) get fileFactory => (super.noSuchMethod(
        Invocation.getter(#fileFactory),
        returnValue: (String path) => _FakeFile_4(
          this,
          Invocation.getter(#fileFactory),
        ),
      ) as _i5.File Function(String));

  @override
  set fileFactory(_i5.File Function(String)? _fileFactory) =>
      super.noSuchMethod(
        Invocation.setter(
          #fileFactory,
          _fileFactory,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.MultipartRequestFactory get multipartRequestFactory =>
      (super.noSuchMethod(
        Invocation.getter(#multipartRequestFactory),
        returnValue: (
          String method,
          Uri url,
        ) =>
            _FakeMultipartRequest_5(
          this,
          Invocation.getter(#multipartRequestFactory),
        ),
      ) as _i4.MultipartRequestFactory);

  @override
  set multipartRequestFactory(
          _i4.MultipartRequestFactory? _multipartRequestFactory) =>
      super.noSuchMethod(
        Invocation.setter(
          #multipartRequestFactory,
          _multipartRequestFactory,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  _i14.Future<void> setupCamera() => (super.noSuchMethod(
        Invocation.method(
          #setupCamera,
          [],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<void> initializeCamera() => (super.noSuchMethod(
        Invocation.method(
          #initializeCamera,
          [],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  void disposeCamera() => super.noSuchMethod(
        Invocation.method(
          #disposeCamera,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i6.Widget getCameraPreview() => (super.noSuchMethod(
        Invocation.method(
          #getCameraPreview,
          [],
        ),
        returnValue: _FakeWidget_6(
          this,
          Invocation.method(
            #getCameraPreview,
            [],
          ),
        ),
      ) as _i6.Widget);

  @override
  _i14.Future<void> takePicture({
    required String? endpoint,
    required dynamic Function(List<dynamic>)? onLabelsDetected,
    required dynamic Function(Duration)? onResponseTimeUpdated,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #takePicture,
          [],
          {
            #endpoint: endpoint,
            #onLabelsDetected: onLabelsDetected,
            #onResponseTimeUpdated: onResponseTimeUpdated,
          },
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<String> captureAndProcessImage() => (super.noSuchMethod(
        Invocation.method(
          #captureAndProcessImage,
          [],
        ),
        returnValue: _i14.Future<String>.value(_i15.dummyValue<String>(
          this,
          Invocation.method(
            #captureAndProcessImage,
            [],
          ),
        )),
      ) as _i14.Future<String>);

  @override
  _i14.Future<void> sendImageAndHandleResponse(
    String? filePath,
    String? endpoint,
    dynamic Function(List<String>)? onDetectedObjects,
    dynamic Function(Duration)? onResponseTime,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #sendImageAndHandleResponse,
          [
            filePath,
            endpoint,
            onDetectedObjects,
            onResponseTime,
          ],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  List<String> parseLabelsFromResponse(String? responseBody) =>
      (super.noSuchMethod(
        Invocation.method(
          #parseLabelsFromResponse,
          [responseBody],
        ),
        returnValue: <String>[],
      ) as List<String>);

  @override
  void addListener(_i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [DatabaseHelper].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabaseHelper extends _i1.Mock implements _i16.DatabaseHelper {
  MockDatabaseHelper() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set database(_i14.Future<_i7.Database>? db) => super.noSuchMethod(
        Invocation.setter(
          #database,
          db,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i14.Future<_i7.Database> get database => (super.noSuchMethod(
        Invocation.getter(#database),
        returnValue: _i14.Future<_i7.Database>.value(_FakeDatabase_7(
          this,
          Invocation.getter(#database),
        )),
      ) as _i14.Future<_i7.Database>);

  @override
  _i14.Future<void> onCreate(
    _i7.Database? db,
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
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<void> onUpgrade(
    _i7.Database? db,
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
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<void> insertDefaultData(_i7.Database? db) => (super.noSuchMethod(
        Invocation.method(
          #insertDefaultData,
          [db],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<void> insertContact(String? name) => (super.noSuchMethod(
        Invocation.method(
          #insertContact,
          [name],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<List<String>> getContacts() => (super.noSuchMethod(
        Invocation.method(
          #getContacts,
          [],
        ),
        returnValue: _i14.Future<List<String>>.value(<String>[]),
      ) as _i14.Future<List<String>>);

  @override
  _i14.Future<void> deleteContact(String? name) => (super.noSuchMethod(
        Invocation.method(
          #deleteContact,
          [name],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<Map<String, dynamic>> getPreferences() => (super.noSuchMethod(
        Invocation.method(
          #getPreferences,
          [],
        ),
        returnValue:
            _i14.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i14.Future<Map<String, dynamic>>);

  @override
  _i14.Future<void> updatePreferences(
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
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<Map<String, String>> getTtsSettings() => (super.noSuchMethod(
        Invocation.method(
          #getTtsSettings,
          [],
        ),
        returnValue: _i14.Future<Map<String, String>>.value(<String, String>{}),
      ) as _i14.Future<Map<String, String>>);

  @override
  _i14.Future<void> updateTtsSettings(
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
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<void> resetDatabase() => (super.noSuchMethod(
        Invocation.method(
          #resetDatabase,
          [],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);
}

/// A class which mocks [TtsServiceGoogle].
///
/// See the documentation for Mockito's code generation for more information.
class MockTtsServiceGoogle extends _i1.Mock implements _i17.TtsServiceGoogle {
  MockTtsServiceGoogle() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i8.AudioPlayer get audioPlayer => (super.noSuchMethod(
        Invocation.getter(#audioPlayer),
        returnValue: _FakeAudioPlayer_8(
          this,
          Invocation.getter(#audioPlayer),
        ),
      ) as _i8.AudioPlayer);

  @override
  set audioPlayer(_i8.AudioPlayer? _audioPlayer) => super.noSuchMethod(
        Invocation.setter(
          #audioPlayer,
          _audioPlayer,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get languageCode => (super.noSuchMethod(
        Invocation.getter(#languageCode),
        returnValue: _i15.dummyValue<String>(
          this,
          Invocation.getter(#languageCode),
        ),
      ) as String);

  @override
  set languageCode(String? _languageCode) => super.noSuchMethod(
        Invocation.setter(
          #languageCode,
          _languageCode,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get voiceName => (super.noSuchMethod(
        Invocation.getter(#voiceName),
        returnValue: _i15.dummyValue<String>(
          this,
          Invocation.getter(#voiceName),
        ),
      ) as String);

  @override
  set voiceName(String? _voiceName) => super.noSuchMethod(
        Invocation.setter(
          #voiceName,
          _voiceName,
        ),
        returnValueForMissingStub: null,
      );

  @override
  double get speechRate => (super.noSuchMethod(
        Invocation.getter(#speechRate),
        returnValue: 0.0,
      ) as double);

  @override
  set speechRate(double? _speechRate) => super.noSuchMethod(
        Invocation.setter(
          #speechRate,
          _speechRate,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i14.Future<void> initializeTts() => (super.noSuchMethod(
        Invocation.method(
          #initializeTts,
          [],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<void> loadSettings() => (super.noSuchMethod(
        Invocation.method(
          #loadSettings,
          [],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<void> updateLanguage(
    String? newLanguageCode,
    String? newVoiceName,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateLanguage,
          [
            newLanguageCode,
            newVoiceName,
          ],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<void> updateSpeechRate(double? newSpeechRate) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateSpeechRate,
          [newSpeechRate],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<String> getAccessToken() => (super.noSuchMethod(
        Invocation.method(
          #getAccessToken,
          [],
        ),
        returnValue: _i14.Future<String>.value(_i15.dummyValue<String>(
          this,
          Invocation.method(
            #getAccessToken,
            [],
          ),
        )),
      ) as _i14.Future<String>);

  @override
  _i14.Future<void> speakLabels(List<dynamic>? detectedObjects) =>
      (super.noSuchMethod(
        Invocation.method(
          #speakLabels,
          [detectedObjects],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);
}

/// A class which mocks [SttService].
///
/// See the documentation for Mockito's code generation for more information.
class MockSttService extends _i1.Mock implements _i11.SttService {
  MockSttService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i9.SpeechToText get speech => (super.noSuchMethod(
        Invocation.getter(#speech),
        returnValue: _FakeSpeechToText_9(
          this,
          Invocation.getter(#speech),
        ),
      ) as _i9.SpeechToText);

  @override
  set speech(_i9.SpeechToText? _speech) => super.noSuchMethod(
        Invocation.setter(
          #speech,
          _speech,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get isListening => (super.noSuchMethod(
        Invocation.getter(#isListening),
        returnValue: false,
      ) as bool);

  @override
  set isListening(bool? _isListening) => super.noSuchMethod(
        Invocation.setter(
          #isListening,
          _isListening,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i14.Future<void> initializeStt() => (super.noSuchMethod(
        Invocation.method(
          #initializeStt,
          [],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<void> startListening(dynamic Function(String)? onResult) =>
      (super.noSuchMethod(
        Invocation.method(
          #startListening,
          [onResult],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  void stopListening() => super.noSuchMethod(
        Invocation.method(
          #stopListening,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void restartListening() => super.noSuchMethod(
        Invocation.method(
          #restartListening,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void handleStatus(String? status) => super.noSuchMethod(
        Invocation.method(
          #handleStatus,
          [status],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [VoiceCommands].
///
/// See the documentation for Mockito's code generation for more information.
class MockVoiceCommands extends _i1.Mock implements _i18.VoiceCommands {
  MockVoiceCommands() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get riskTrigger => (super.noSuchMethod(
        Invocation.getter(#riskTrigger),
        returnValue: false,
      ) as bool);

  @override
  set riskTrigger(bool? _riskTrigger) => super.noSuchMethod(
        Invocation.setter(
          #riskTrigger,
          _riskTrigger,
        ),
        returnValueForMissingStub: null,
      );

  @override
  int get triggerVariable => (super.noSuchMethod(
        Invocation.getter(#triggerVariable),
        returnValue: 0,
      ) as int);

  @override
  set triggerVariable(int? _triggerVariable) => super.noSuchMethod(
        Invocation.setter(
          #triggerVariable,
          _triggerVariable,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.AudioPlayer get player => (super.noSuchMethod(
        Invocation.getter(#player),
        returnValue: _FakeAudioPlayer_8(
          this,
          Invocation.getter(#player),
        ),
      ) as _i8.AudioPlayer);

  @override
  set player(_i8.AudioPlayer? _player) => super.noSuchMethod(
        Invocation.setter(
          #player,
          _player,
        ),
        returnValueForMissingStub: null,
      );

  @override
  Map<String, List<String>> get voiceCommands => (super.noSuchMethod(
        Invocation.getter(#voiceCommands),
        returnValue: <String, List<String>>{},
      ) as Map<String, List<String>>);

  @override
  List<String> get activationCommands => (super.noSuchMethod(
        Invocation.getter(#activationCommands),
        returnValue: <String>[],
      ) as List<String>);

  @override
  set activationCommands(List<String>? _activationCommands) =>
      super.noSuchMethod(
        Invocation.setter(
          #activationCommands,
          _activationCommands,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i10.Locale get locale => (super.noSuchMethod(
        Invocation.getter(#locale),
        returnValue: _FakeLocale_10(
          this,
          Invocation.getter(#locale),
        ),
      ) as _i10.Locale);

  @override
  set locale(_i10.Locale? _locale) => super.noSuchMethod(
        Invocation.setter(
          #locale,
          _locale,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i11.SttService get sttService => (super.noSuchMethod(
        Invocation.getter(#sttService),
        returnValue: _FakeSttService_11(
          this,
          Invocation.getter(#sttService),
        ),
      ) as _i11.SttService);

  @override
  set sttService(_i11.SttService? _sttService) => super.noSuchMethod(
        Invocation.setter(
          #sttService,
          _sttService,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i12.ITtsService get ttsServiceGoogle => (super.noSuchMethod(
        Invocation.getter(#ttsServiceGoogle),
        returnValue: _FakeITtsService_12(
          this,
          Invocation.getter(#ttsServiceGoogle),
        ),
      ) as _i12.ITtsService);

  @override
  set ttsServiceGoogle(_i12.ITtsService? _ttsServiceGoogle) =>
      super.noSuchMethod(
        Invocation.setter(
          #ttsServiceGoogle,
          _ttsServiceGoogle,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i13.WidgetStateProvider get widgetStateProvider => (super.noSuchMethod(
        Invocation.getter(#widgetStateProvider),
        returnValue: _FakeWidgetStateProvider_13(
          this,
          Invocation.getter(#widgetStateProvider),
        ),
      ) as _i13.WidgetStateProvider);

  @override
  set widgetStateProvider(_i13.WidgetStateProvider? _widgetStateProvider) =>
      super.noSuchMethod(
        Invocation.setter(
          #widgetStateProvider,
          _widgetStateProvider,
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool get isActivated => (super.noSuchMethod(
        Invocation.getter(#isActivated),
        returnValue: false,
      ) as bool);

  @override
  String get command => (super.noSuchMethod(
        Invocation.getter(#command),
        returnValue: _i15.dummyValue<String>(
          this,
          Invocation.getter(#command),
        ),
      ) as String);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  void toggleActivation(bool? value) => super.noSuchMethod(
        Invocation.method(
          #toggleActivation,
          [value],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i14.Future<void> initialize(_i6.BuildContext? context) =>
      (super.noSuchMethod(
        Invocation.method(
          #initialize,
          [context],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<void> loadVoiceCommands() => (super.noSuchMethod(
        Invocation.method(
          #loadVoiceCommands,
          [],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  _i14.Future<void> loadActivationCommands() => (super.noSuchMethod(
        Invocation.method(
          #loadActivationCommands,
          [],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  void startListening() => super.noSuchMethod(
        Invocation.method(
          #startListening,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  bool isActivationCommand(String? transcript) => (super.noSuchMethod(
        Invocation.method(
          #isActivationCommand,
          [transcript],
        ),
        returnValue: false,
      ) as bool);

  @override
  _i14.Future<void> playActivationSound() => (super.noSuchMethod(
        Invocation.method(
          #playActivationSound,
          [],
        ),
        returnValue: _i14.Future<void>.value(),
        returnValueForMissingStub: _i14.Future<void>.value(),
      ) as _i14.Future<void>);

  @override
  void handleCommand(String? command) => super.noSuchMethod(
        Invocation.method(
          #handleCommand,
          [command],
        ),
        returnValueForMissingStub: null,
      );

  @override
  double calculateSimilarity(
    String? s1,
    String? s2,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #calculateSimilarity,
          [
            s1,
            s2,
          ],
        ),
        returnValue: 0.0,
      ) as double);

  @override
  int levenshteinDistance(
    String? s1,
    String? s2,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #levenshteinDistance,
          [
            s1,
            s2,
          ],
        ),
        returnValue: 0,
      ) as int);

  @override
  void addListener(_i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i10.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i3.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i14.Future<_i3.Response> head(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #head,
          [url],
          {#headers: headers},
        ),
        returnValue: _i14.Future<_i3.Response>.value(_FakeResponse_14(
          this,
          Invocation.method(
            #head,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i14.Future<_i3.Response>);

  @override
  _i14.Future<_i3.Response> get(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [url],
          {#headers: headers},
        ),
        returnValue: _i14.Future<_i3.Response>.value(_FakeResponse_14(
          this,
          Invocation.method(
            #get,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i14.Future<_i3.Response>);

  @override
  _i14.Future<_i3.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i19.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #post,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i14.Future<_i3.Response>.value(_FakeResponse_14(
          this,
          Invocation.method(
            #post,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i14.Future<_i3.Response>);

  @override
  _i14.Future<_i3.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i19.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #put,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i14.Future<_i3.Response>.value(_FakeResponse_14(
          this,
          Invocation.method(
            #put,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i14.Future<_i3.Response>);

  @override
  _i14.Future<_i3.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i19.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #patch,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i14.Future<_i3.Response>.value(_FakeResponse_14(
          this,
          Invocation.method(
            #patch,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i14.Future<_i3.Response>);

  @override
  _i14.Future<_i3.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i19.Encoding? encoding,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [url],
          {
            #headers: headers,
            #body: body,
            #encoding: encoding,
          },
        ),
        returnValue: _i14.Future<_i3.Response>.value(_FakeResponse_14(
          this,
          Invocation.method(
            #delete,
            [url],
            {
              #headers: headers,
              #body: body,
              #encoding: encoding,
            },
          ),
        )),
      ) as _i14.Future<_i3.Response>);

  @override
  _i14.Future<String> read(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #read,
          [url],
          {#headers: headers},
        ),
        returnValue: _i14.Future<String>.value(_i15.dummyValue<String>(
          this,
          Invocation.method(
            #read,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i14.Future<String>);

  @override
  _i14.Future<_i20.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #readBytes,
          [url],
          {#headers: headers},
        ),
        returnValue: _i14.Future<_i20.Uint8List>.value(_i20.Uint8List(0)),
      ) as _i14.Future<_i20.Uint8List>);

  @override
  _i14.Future<_i3.StreamedResponse> send(_i3.BaseRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(
          #send,
          [request],
        ),
        returnValue:
            _i14.Future<_i3.StreamedResponse>.value(_FakeStreamedResponse_15(
          this,
          Invocation.method(
            #send,
            [request],
          ),
        )),
      ) as _i14.Future<_i3.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
