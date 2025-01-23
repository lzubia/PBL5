import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/translation_provider.dart';
import 'package:provider/provider.dart';

class MapProvider extends ChangeNotifier {
  Location location;
  final ITtsService ttsService;
  final http.Client httpClient;
  final PolylinePoints polylinePoints;

  LocationData? _currentLocation;
  LatLng? _destination;
  List<LatLng> _polylineCoordinates = [];
  List<Map<String, dynamic>> _instructions = [];
  StreamSubscription<LocationData>? locationSubscription;

  bool _loading = false;
  bool get isLoading => _loading;

  String? _destinationName;
  String? get destinationName => _destinationName;

  LocationData? get currentLocation => _currentLocation;
  set currentLocation(LocationData? location) {
    _currentLocation = location;
    notifyListeners();
  }

  LatLng? get destination => _destination;
  set destination(LatLng? destination) {
    _destination = destination;
    notifyListeners();
  }

  List<LatLng> get polylineCoordinates => _polylineCoordinates;
  List<Map<String, dynamic>> get instructions => _instructions;

  MapProvider({
    required this.ttsService,
    Location? location,
    http.Client? httpClient,
    PolylinePoints? polylinePoints,
  })  : location = location ?? Location(),
        httpClient = httpClient ?? http.Client(),
        polylinePoints = polylinePoints ?? PolylinePoints();

  /// Get current location and start listening to updates.
  Future<void> getCurrentLocation(BuildContext context) async {
    // Use context safely within this method
    final localizationMessage =
        AppLocalizations.of(context).translate("mapa-on");
    ttsService.speakLabels([localizationMessage], context);

    _currentLocation = await location.getLocation();
    notifyListeners();

    locationSubscription = location.onLocationChanged.listen((newLoc) {
      _currentLocation = newLoc;
      notifyListeners();
      if (_instructions.isNotEmpty) {
        _updateCurrentInstruction(context);
      }
    });
  }

  /// Set the destination and calculate route + instructions.
  /// Set the destination using either a String address or a LatLng object.
  /// `address` and `location` are mutually exclusive; provide only one.
  Future<void> setDestination({
    required BuildContext context,
    String? address,
    LatLng? location,
  }) async {
    final apiKey = dotenv.env['GEOCODING_API_KEY'];
    if (apiKey == null) {
      throw Exception("Missing Google API Key in .env");
    }

    if (address == null && location == null) {
      throw ArgumentError("Either `address` or `location` must be provided.");
    }

    _loading = true;
    notifyListeners();

    try {
      final result = address != null
          ? await _fetchDestinationFromAddress(apiKey, address, context)
          : await _fetchDestinationFromLatLng(apiKey, location!, context);

      if (result == null) {
        return;
      }

      _destinationName = result['name'];
      _destination = result['location'];
      notifyListeners();

      await fetchPolylineCoordinates();
      await fetchNavigationInstructions(context);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Fetch destination details from an address.
  Future<Map<String, dynamic>?> _fetchDestinationFromAddress(
      String apiKey, String address, BuildContext context) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey'));

    return _processGeocodingResponse(response, context, address);
  }

  /// Fetch destination details from a LatLng object.
  Future<Map<String, dynamic>?> _fetchDestinationFromLatLng(
      String apiKey, LatLng location, BuildContext context) async {
    final latLngString = '${location.latitude},${location.longitude}';
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latLngString&key=$apiKey'));

    return _processGeocodingResponse(response, context, 'home');
  }

  /// Process the geocoding response and return the destination details.
  Future<Map<String, dynamic>?> _processGeocodingResponse(
      http.Response response, BuildContext context, String defaultName) async {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'ZERO_RESULTS') {
        await ttsService.speakLabels(
            [AppLocalizations.of(context).translate("destination-not-found")],
            context);
        return null;
      }

      final location = data['results'][0]['geometry']['location'];
      return {
        'name': defaultName,
        'location': LatLng(location['lat'], location['lng']),
      };
    } else {
      throw Exception("Failed to fetch destination.");
    }
  }

  /// Fetch polyline coordinates for the route.
  Future<void> fetchPolylineCoordinates() async {
    if (_currentLocation == null || _destination == null) return;

    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null) {
      throw Exception("Missing Google API Key in .env");
    }

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey,
      request: PolylineRequest(
        origin: PointLatLng(
            _currentLocation!.latitude!, _currentLocation!.longitude!),
        destination:
            PointLatLng(_destination!.latitude, _destination!.longitude),
        mode: TravelMode.walking,
      ),
    );

    if (result.points.isNotEmpty) {
      _polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      notifyListeners();
    } else {
      throw Exception("No polyline found.");
    }
  }

  /// Fetch navigation instructions (steps).
  Future<void> fetchNavigationInstructions(BuildContext context) async {
    if (_currentLocation == null || _destination == null) return;

    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    final origin =
        "${_currentLocation!.latitude},${_currentLocation!.longitude}";
    final dest = "${_destination!.latitude},${_destination!.longitude}";

    final response = await httpClient.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&mode=walking&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final steps = data['routes'][0]['legs'][0]['steps'] as List;
      _instructions = steps.map((step) {
        final instruction = step['html_instructions'] as String;
        final startLocation = step['start_location'];
        return {
          'instruction': removeHtmlTags(instruction),
          'start_location': LatLng(startLocation['lat'], startLocation['lng']),
        };
      }).toList();

      if (_instructions.isNotEmpty) {
        final firstInstruction = _instructions[0]['instruction'];

        // Use context to get the TranslationProvider
        final translationProvider =
            Provider.of<TranslationProvider>(context, listen: false);

        // Translate the instruction
        final translatedInstruction = await translationProvider.translateText(
            "Start your trip to $_destinationName. First instruction: $firstInstruction",
            Localizations.localeOf(context)
                .languageCode); // Replace 'es' with the desired language

        await ttsService.speakLabels([translatedInstruction], context);
      }

      notifyListeners();
    } else {
      throw Exception("Failed to fetch navigation instructions.");
    }
  }

  /// Remove HTML tags from instructions.
  String removeHtmlTags(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>');
    return htmlText.replaceAll(exp, '');
  }

  /// Update the current instruction based on proximity.
  void _updateCurrentInstruction(BuildContext context) async {
    if (_instructions.isEmpty || _currentLocation == null) return;

    final currentLatLng = LatLng(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
    );

    int closestIndex = -1;
    double closestDistance = double.infinity;

    for (int i = 0; i < _instructions.length; i++) {
      final instructionLatLng = _instructions[i]['start_location'] as LatLng;
      final distance = calculateDistance(currentLatLng, instructionLatLng);

      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    if (closestDistance < 10) {
      final instruction = _instructions[closestIndex]['instruction'];
      final translationProvider =
          Provider.of<TranslationProvider>(context, listen: false);
      final translatedInstruction = await translationProvider.translateText(
          instruction, Localizations.localeOf(context).languageCode);

      await ttsService.speakLabels([
        AppLocalizations.of(context).translate("Now" + translatedInstruction)
      ], context);

      _instructions = _instructions.sublist(closestIndex + 1);
      notifyListeners();
    }

    if (_instructions.isEmpty) {
      ttsService.speakLabels([
        AppLocalizations.of(context).translate("Destination-reached"),
        _destinationName ?? "",
      ], context);
    }
  }

  /// Calculate distance between two points in meters.
  double calculateDistance(LatLng start, LatLng end) {
    const double p = 0.017453292519943295; // Pi/180
    final double a = 0.5 -
        cos((end.latitude - start.latitude) * p) / 2 +
        cos(start.latitude * p) *
            cos(end.latitude * p) *
            (1 - cos((end.longitude - start.longitude) * p)) /
            2;
    return 12742 * asin(sqrt(a)) * 1000; // 2 * R; R = 6371 km
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    locationSubscription = null; // Explicitly set it to null after canceling
    super.dispose();
  }
}
