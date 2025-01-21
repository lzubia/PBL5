import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';

class MapProvider extends ChangeNotifier {
  Location location = Location();
  final ITtsService ttsService;
  final http.Client httpClient;
  final PolylinePoints polylinePoints;

  LocationData? _currentLocation;
  LatLng? _destination;
  List<LatLng> _polylineCoordinates = [];
  List<Map<String, dynamic>> _instructions = [];
  StreamSubscription<LocationData>? _locationSubscription;

  bool _loading = false;
  bool get isLoading => _loading;

  String? _destinationName;
  String? get destinationName => _destinationName;

  LocationData? get currentLocation => _currentLocation;
  LatLng? get destination => _destination;
  List<LatLng> get polylineCoordinates => _polylineCoordinates;
  List<Map<String, dynamic>> get instructions => _instructions;

  MapProvider({
    required this.ttsService,
    http.Client? httpClient,
    PolylinePoints? polylinePoints,
  })  : httpClient = httpClient ?? http.Client(),
        polylinePoints = polylinePoints ?? PolylinePoints();

  /// Get current location and start listening to updates.
  Future<void> getCurrentLocation() async {
    _currentLocation = await location.getLocation();
    notifyListeners();

    _locationSubscription = location.onLocationChanged.listen((newLoc) {
      _currentLocation = newLoc;
      notifyListeners();
      _updateCurrentInstruction(); // Dynamically update instructions
    });

    // Speak a message to indicate the map is active.
    await ttsService.speakLabels(["Map is now active."]);
  }

  /// Set the destination and calculate route + instructions.
  Future<void> setDestination(String destinationAddress) async {
    final apiKey = dotenv.env['GEOCODING_API_KEY'];
    if (apiKey == null) {
      throw Exception("Missing Google API Key in .env");
    }

    _loading = true;
    notifyListeners();

    try {
      final response = await httpClient.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$destinationAddress&key=$apiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'ZERO_RESULTS') {
          await ttsService.speakLabels(["Destination not found."]);
          throw Exception("Destination not found.");
        }

        final location = data['results'][0]['geometry']['location'];
        _destinationName = destinationAddress;
        _destination = LatLng(location['lat'], location['lng']);
        notifyListeners();

        await _fetchPolylineCoordinates();
        await _fetchNavigationInstructions();
      } else {
        throw Exception("Failed to fetch destination.");
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Fetch polyline coordinates for the route.
  Future<void> _fetchPolylineCoordinates() async {
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
  Future<void> _fetchNavigationInstructions() async {
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
        await ttsService.speakLabels([
          "Start your trip to $_destinationName. First instruction: $firstInstruction"
        ]);
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
  void _updateCurrentInstruction() {
    if (_instructions.isEmpty || _currentLocation == null) return;

    final currentLatLng = LatLng(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
    );

    int closestIndex = -1;
    double closestDistance = double.infinity;

    for (int i = 0; i < _instructions.length; i++) {
      final instructionLatLng = _instructions[i]['start_location'] as LatLng;
      final distance = _calculateDistance(currentLatLng, instructionLatLng);

      if (distance < closestDistance) {
        closestDistance = distance;
        closestIndex = i;
      }
    }

    if (closestDistance < 10) {
      final instruction = _instructions[closestIndex]['instruction'];
      ttsService.speakLabels(["Now: $instruction"]);
      _instructions = _instructions.sublist(closestIndex + 1);
      notifyListeners();
    }

    // Notify the user if they've reached the destination.
    if (_instructions.isEmpty) {
      ttsService.speakLabels(
          ["You have reached your destination: $_destinationName"]);
    }
  }

  /// Calculate distance between two points in meters.
  double _calculateDistance(LatLng start, LatLng end) {
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
    _locationSubscription?.cancel();
    super.dispose();
  }
}
