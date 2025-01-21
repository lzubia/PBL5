import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class MapProvider extends ChangeNotifier {
  LocationData? _currentLocation;
  LatLng? _destination;
  List<LatLng> _polylineCoordinates = [];
  List<Map<String, dynamic>> _instructions = [];
  StreamSubscription<LocationData>? _locationSubscription;

  LocationData? get currentLocation => _currentLocation;
  LatLng? get destination => _destination;
  List<LatLng> get polylineCoordinates => _polylineCoordinates;

  final Location _location = Location();
  final http.Client httpClient;
  final PolylinePoints polylinePoints;

  MapProvider({http.Client? httpClient, PolylinePoints? polylinePoints})
      : httpClient = httpClient ?? http.Client(),
        polylinePoints = polylinePoints ?? PolylinePoints();

  set location(_location) {}

  set locationSubscription(
      StreamSubscription<LocationData> _locationSubscription) {}

  set destination(LatLng? _destination) {}

  set currentLocation(LocationData? _currentLocation) {}

  Future<void> getCurrentLocation() async {
    _currentLocation = await _location.getLocation();
    notifyListeners();

    _locationSubscription = _location.onLocationChanged.listen((newLoc) {
      _currentLocation = newLoc;
      notifyListeners();
    });
  }

  Future<void> setDestination(String destinationAddress) async {
    final apiKey = dotenv.env['GEOCODING_API_KEY'];
    final response = await httpClient.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$destinationAddress&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'ZERO_RESULTS') {
        throw Exception('Destination not found.');
      }
      final location = data['results'][0]['geometry']['location'];
      _destination = LatLng(location['lat'], location['lng']);
      notifyListeners();

      await fetchPolylineCoordinates();
    } else {
      throw Exception('Failed to fetch destination.');
    }
  }

  Future<void> fetchPolylineCoordinates() async {
    if (_currentLocation == null || _destination == null) return;

    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey!,
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
      throw Exception('No polyline found.');
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}
