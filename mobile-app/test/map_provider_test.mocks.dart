// Mocks generated by Mockito 5.4.4 from annotations
// in pbl5_menu/test/map_provider_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i9;
import 'dart:convert' as _i10;
import 'dart:typed_data' as _i12;
import 'dart:ui' as _i7;

import 'package:audioplayers/audioplayers.dart' as _i5;
import 'package:flutter/services.dart' as _i6;
import 'package:flutter_polyline_points/flutter_polyline_points.dart' as _i13;
import 'package:flutter_polyline_points/src/point_lat_lng.dart' as _i15;
import 'package:flutter_polyline_points/src/utils/polyline_request.dart'
    as _i14;
import 'package:flutter_polyline_points/src/utils/polyline_result.dart' as _i4;
import 'package:http/http.dart' as _i3;
import 'package:location/location.dart' as _i8;
import 'package:location_platform_interface/location_platform_interface.dart'
    as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i11;
import 'package:pbl5_menu/services/l10n.dart' as _i18;
import 'package:pbl5_menu/services/tts/tts_service_google.dart' as _i16;
import 'package:pbl5_menu/translation_provider.dart' as _i17;

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

class _FakeLocationData_0 extends _i1.SmartFake implements _i2.LocationData {
  _FakeLocationData_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeResponse_1 extends _i1.SmartFake implements _i3.Response {
  _FakeResponse_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamedResponse_2 extends _i1.SmartFake
    implements _i3.StreamedResponse {
  _FakeStreamedResponse_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePolylineResult_3 extends _i1.SmartFake
    implements _i4.PolylineResult {
  _FakePolylineResult_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAudioPlayer_4 extends _i1.SmartFake implements _i5.AudioPlayer {
  _FakeAudioPlayer_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeClient_5 extends _i1.SmartFake implements _i3.Client {
  _FakeClient_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAssetBundle_6 extends _i1.SmartFake implements _i6.AssetBundle {
  _FakeAssetBundle_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeLocale_7 extends _i1.SmartFake implements _i7.Locale {
  _FakeLocale_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [Location].
///
/// See the documentation for Mockito's code generation for more information.
class MockLocation extends _i1.Mock implements _i8.Location {
  MockLocation() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i9.Stream<_i2.LocationData> get onLocationChanged => (super.noSuchMethod(
        Invocation.getter(#onLocationChanged),
        returnValue: _i9.Stream<_i2.LocationData>.empty(),
      ) as _i9.Stream<_i2.LocationData>);

  @override
  _i9.Future<bool> changeSettings({
    _i2.LocationAccuracy? accuracy = _i2.LocationAccuracy.high,
    int? interval = 1000,
    double? distanceFilter = 0.0,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #changeSettings,
          [],
          {
            #accuracy: accuracy,
            #interval: interval,
            #distanceFilter: distanceFilter,
          },
        ),
        returnValue: _i9.Future<bool>.value(false),
      ) as _i9.Future<bool>);

  @override
  _i9.Future<bool> isBackgroundModeEnabled() => (super.noSuchMethod(
        Invocation.method(
          #isBackgroundModeEnabled,
          [],
        ),
        returnValue: _i9.Future<bool>.value(false),
      ) as _i9.Future<bool>);

  @override
  _i9.Future<bool> enableBackgroundMode({bool? enable = true}) =>
      (super.noSuchMethod(
        Invocation.method(
          #enableBackgroundMode,
          [],
          {#enable: enable},
        ),
        returnValue: _i9.Future<bool>.value(false),
      ) as _i9.Future<bool>);

  @override
  _i9.Future<_i2.LocationData> getLocation() => (super.noSuchMethod(
        Invocation.method(
          #getLocation,
          [],
        ),
        returnValue: _i9.Future<_i2.LocationData>.value(_FakeLocationData_0(
          this,
          Invocation.method(
            #getLocation,
            [],
          ),
        )),
      ) as _i9.Future<_i2.LocationData>);

  @override
  _i9.Future<_i2.PermissionStatus> hasPermission() => (super.noSuchMethod(
        Invocation.method(
          #hasPermission,
          [],
        ),
        returnValue: _i9.Future<_i2.PermissionStatus>.value(
            _i2.PermissionStatus.granted),
      ) as _i9.Future<_i2.PermissionStatus>);

  @override
  _i9.Future<_i2.PermissionStatus> requestPermission() => (super.noSuchMethod(
        Invocation.method(
          #requestPermission,
          [],
        ),
        returnValue: _i9.Future<_i2.PermissionStatus>.value(
            _i2.PermissionStatus.granted),
      ) as _i9.Future<_i2.PermissionStatus>);

  @override
  _i9.Future<bool> serviceEnabled() => (super.noSuchMethod(
        Invocation.method(
          #serviceEnabled,
          [],
        ),
        returnValue: _i9.Future<bool>.value(false),
      ) as _i9.Future<bool>);

  @override
  _i9.Future<bool> requestService() => (super.noSuchMethod(
        Invocation.method(
          #requestService,
          [],
        ),
        returnValue: _i9.Future<bool>.value(false),
      ) as _i9.Future<bool>);

  @override
  _i9.Future<_i2.AndroidNotificationData?> changeNotificationOptions({
    String? channelName,
    String? title,
    String? iconName,
    String? subtitle,
    String? description,
    _i7.Color? color,
    bool? onTapBringToFront,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #changeNotificationOptions,
          [],
          {
            #channelName: channelName,
            #title: title,
            #iconName: iconName,
            #subtitle: subtitle,
            #description: description,
            #color: color,
            #onTapBringToFront: onTapBringToFront,
          },
        ),
        returnValue: _i9.Future<_i2.AndroidNotificationData?>.value(),
      ) as _i9.Future<_i2.AndroidNotificationData?>);
}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i3.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i9.Future<_i3.Response> head(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #head,
          [url],
          {#headers: headers},
        ),
        returnValue: _i9.Future<_i3.Response>.value(_FakeResponse_1(
          this,
          Invocation.method(
            #head,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i9.Future<_i3.Response>);

  @override
  _i9.Future<_i3.Response> get(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #get,
          [url],
          {#headers: headers},
        ),
        returnValue: _i9.Future<_i3.Response>.value(_FakeResponse_1(
          this,
          Invocation.method(
            #get,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i9.Future<_i3.Response>);

  @override
  _i9.Future<_i3.Response> post(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i10.Encoding? encoding,
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
        returnValue: _i9.Future<_i3.Response>.value(_FakeResponse_1(
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
      ) as _i9.Future<_i3.Response>);

  @override
  _i9.Future<_i3.Response> put(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i10.Encoding? encoding,
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
        returnValue: _i9.Future<_i3.Response>.value(_FakeResponse_1(
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
      ) as _i9.Future<_i3.Response>);

  @override
  _i9.Future<_i3.Response> patch(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i10.Encoding? encoding,
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
        returnValue: _i9.Future<_i3.Response>.value(_FakeResponse_1(
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
      ) as _i9.Future<_i3.Response>);

  @override
  _i9.Future<_i3.Response> delete(
    Uri? url, {
    Map<String, String>? headers,
    Object? body,
    _i10.Encoding? encoding,
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
        returnValue: _i9.Future<_i3.Response>.value(_FakeResponse_1(
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
      ) as _i9.Future<_i3.Response>);

  @override
  _i9.Future<String> read(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #read,
          [url],
          {#headers: headers},
        ),
        returnValue: _i9.Future<String>.value(_i11.dummyValue<String>(
          this,
          Invocation.method(
            #read,
            [url],
            {#headers: headers},
          ),
        )),
      ) as _i9.Future<String>);

  @override
  _i9.Future<_i12.Uint8List> readBytes(
    Uri? url, {
    Map<String, String>? headers,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #readBytes,
          [url],
          {#headers: headers},
        ),
        returnValue: _i9.Future<_i12.Uint8List>.value(_i12.Uint8List(0)),
      ) as _i9.Future<_i12.Uint8List>);

  @override
  _i9.Future<_i3.StreamedResponse> send(_i3.BaseRequest? request) =>
      (super.noSuchMethod(
        Invocation.method(
          #send,
          [request],
        ),
        returnValue:
            _i9.Future<_i3.StreamedResponse>.value(_FakeStreamedResponse_2(
          this,
          Invocation.method(
            #send,
            [request],
          ),
        )),
      ) as _i9.Future<_i3.StreamedResponse>);

  @override
  void close() => super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [PolylinePoints].
///
/// See the documentation for Mockito's code generation for more information.
class MockPolylinePoints extends _i1.Mock implements _i13.PolylinePoints {
  MockPolylinePoints() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i9.Future<_i4.PolylineResult> getRouteBetweenCoordinates({
    required _i14.PolylineRequest? request,
    String? googleApiKey,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getRouteBetweenCoordinates,
          [],
          {
            #request: request,
            #googleApiKey: googleApiKey,
          },
        ),
        returnValue: _i9.Future<_i4.PolylineResult>.value(_FakePolylineResult_3(
          this,
          Invocation.method(
            #getRouteBetweenCoordinates,
            [],
            {
              #request: request,
              #googleApiKey: googleApiKey,
            },
          ),
        )),
      ) as _i9.Future<_i4.PolylineResult>);

  @override
  _i9.Future<List<_i4.PolylineResult>> getRouteWithAlternatives({
    required _i14.PolylineRequest? request,
    String? googleApiKey,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getRouteWithAlternatives,
          [],
          {
            #request: request,
            #googleApiKey: googleApiKey,
          },
        ),
        returnValue:
            _i9.Future<List<_i4.PolylineResult>>.value(<_i4.PolylineResult>[]),
      ) as _i9.Future<List<_i4.PolylineResult>>);

  @override
  List<_i15.PointLatLng> decodePolyline(String? encodedString) =>
      (super.noSuchMethod(
        Invocation.method(
          #decodePolyline,
          [encodedString],
        ),
        returnValue: <_i15.PointLatLng>[],
      ) as List<_i15.PointLatLng>);
}

/// A class which mocks [TtsServiceGoogle].
///
/// See the documentation for Mockito's code generation for more information.
class MockTtsServiceGoogle extends _i1.Mock implements _i16.TtsServiceGoogle {
  MockTtsServiceGoogle() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.AudioPlayer get audioPlayer => (super.noSuchMethod(
        Invocation.getter(#audioPlayer),
        returnValue: _FakeAudioPlayer_4(
          this,
          Invocation.getter(#audioPlayer),
        ),
      ) as _i5.AudioPlayer);

  @override
  set audioPlayer(_i5.AudioPlayer? _audioPlayer) => super.noSuchMethod(
        Invocation.setter(
          #audioPlayer,
          _audioPlayer,
        ),
        returnValueForMissingStub: null,
      );

  @override
  String get languageCode => (super.noSuchMethod(
        Invocation.getter(#languageCode),
        returnValue: _i11.dummyValue<String>(
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
        returnValue: _i11.dummyValue<String>(
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
  _i3.Client get httpClient => (super.noSuchMethod(
        Invocation.getter(#httpClient),
        returnValue: _FakeClient_5(
          this,
          Invocation.getter(#httpClient),
        ),
      ) as _i3.Client);

  @override
  _i6.AssetBundle get assetBundle => (super.noSuchMethod(
        Invocation.getter(#assetBundle),
        returnValue: _FakeAssetBundle_6(
          this,
          Invocation.getter(#assetBundle),
        ),
      ) as _i6.AssetBundle);

  @override
  _i9.Future<void> initializeTts() => (super.noSuchMethod(
        Invocation.method(
          #initializeTts,
          [],
        ),
        returnValue: _i9.Future<void>.value(),
        returnValueForMissingStub: _i9.Future<void>.value(),
      ) as _i9.Future<void>);

  @override
  _i9.Future<void> loadSettings() => (super.noSuchMethod(
        Invocation.method(
          #loadSettings,
          [],
        ),
        returnValue: _i9.Future<void>.value(),
        returnValueForMissingStub: _i9.Future<void>.value(),
      ) as _i9.Future<void>);

  @override
  _i9.Future<void> updateLanguage(
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
        returnValue: _i9.Future<void>.value(),
        returnValueForMissingStub: _i9.Future<void>.value(),
      ) as _i9.Future<void>);

  @override
  _i9.Future<void> updateSpeechRate(double? newSpeechRate) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateSpeechRate,
          [newSpeechRate],
        ),
        returnValue: _i9.Future<void>.value(),
        returnValueForMissingStub: _i9.Future<void>.value(),
      ) as _i9.Future<void>);

  @override
  _i9.Future<String> getAccessToken() => (super.noSuchMethod(
        Invocation.method(
          #getAccessToken,
          [],
        ),
        returnValue: _i9.Future<String>.value(_i11.dummyValue<String>(
          this,
          Invocation.method(
            #getAccessToken,
            [],
          ),
        )),
      ) as _i9.Future<String>);

  @override
  _i9.Future<void> speakLabels(List<dynamic>? detectedObjects) =>
      (super.noSuchMethod(
        Invocation.method(
          #speakLabels,
          [detectedObjects],
        ),
        returnValue: _i9.Future<void>.value(),
        returnValueForMissingStub: _i9.Future<void>.value(),
      ) as _i9.Future<void>);
}

/// A class which mocks [TranslationProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockTranslationProvider extends _i1.Mock
    implements _i17.TranslationProvider {
  MockTranslationProvider() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
      ) as bool);

  @override
  _i9.Future<String> translateText(
    String? text,
    String? targetLanguage,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #translateText,
          [
            text,
            targetLanguage,
          ],
        ),
        returnValue: _i9.Future<String>.value(_i11.dummyValue<String>(
          this,
          Invocation.method(
            #translateText,
            [
              text,
              targetLanguage,
            ],
          ),
        )),
      ) as _i9.Future<String>);

  @override
  void addListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i7.VoidCallback? listener) => super.noSuchMethod(
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

/// A class which mocks [AppLocalizations].
///
/// See the documentation for Mockito's code generation for more information.
class MockAppLocalizations extends _i1.Mock implements _i18.AppLocalizations {
  MockAppLocalizations() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Locale get locale => (super.noSuchMethod(
        Invocation.getter(#locale),
        returnValue: _FakeLocale_7(
          this,
          Invocation.getter(#locale),
        ),
      ) as _i7.Locale);

  @override
  _i9.Future<bool> load() => (super.noSuchMethod(
        Invocation.method(
          #load,
          [],
        ),
        returnValue: _i9.Future<bool>.value(false),
      ) as _i9.Future<bool>);

  @override
  String translate(String? key) => (super.noSuchMethod(
        Invocation.method(
          #translate,
          [key],
        ),
        returnValue: _i11.dummyValue<String>(
          this,
          Invocation.method(
            #translate,
            [key],
          ),
        ),
      ) as String);
}
