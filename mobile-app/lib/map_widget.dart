import 'dart:async';
import 'dart:convert';
import 'dart:math'; // Add this import

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/services.dart' show rootBundle;

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  State<MapWidget> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<MapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _destinationController = TextEditingController();

  LatLng? destination;

  List<LatLng> polylineCoordinates = [];
  List<Map<String, dynamic>> _instructions = [];
  LocationData? currentLocation;
  StreamSubscription<LocationData>? locationSubscription;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    Location location = Location();

    var locationData = await location.getLocation();
    if (mounted) {
      setState(() {
        currentLocation = locationData;
      });
    }

    GoogleMapController googleMapController = await _controller.future;

    locationSubscription = location.onLocationChanged.listen(
      (newLoc) {
        if (mounted) {
          setState(() {
            currentLocation = newLoc;
            googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  zoom: 13.5,
                  target: LatLng(
                    newLoc.latitude!,
                    newLoc.longitude!,
                  ),
                ),
              ),
            );
            _updateCurrentInstruction();
          });
        }
      },
    );
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _searchDestination() async {
    final apiKey = dotenv.env['GEOCODING_API_KEY'];
    final response = await http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=${_destinationController.text}&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['results'][0]['geometry']['location'];
      setState(() {
        destination = LatLng(location['lat'], location['lng']);
        getPolyPoints();
      });
    } else {
      throw Exception('Failed to load location');
    }
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
      request: PolylineRequest(
        origin: PointLatLng(
          currentLocation?.latitude ?? 0.0,
          currentLocation?.longitude ?? 0.0,
        ),
        destination: PointLatLng(
          destination!.latitude,
          destination!.longitude,
        ),
        mode: TravelMode.walking,
      ),
    );

    if (result.points.isNotEmpty) {
      if (mounted) {
        setState(
          () {
            polylineCoordinates.clear();
            for (PointLatLng point in result.points) {
              polylineCoordinates.add(
                LatLng(
                  point.latitude,
                  point.longitude,
                ),
              );
            }
          },
        );
        _fetchAndDisplayDirections();
      }
    } else {
      print('No points found');
    }
  }

  Future<void> _fetchAndDisplayDirections() async {
    try {
      final instructions = await fetchDirections(
        '${currentLocation?.latitude},${currentLocation?.longitude}',
        '${destination?.latitude},${destination?.longitude}',
        dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
      );
      setState(() {
        _instructions = instructions;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List<Map<String, dynamic>>> fetchDirections(
      String origin, String destination, String apiKey) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=walking&key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final steps = data['routes'][0]['legs'][0]['steps'] as List;
      return steps.map((step) {
        final maneuver = step['maneuver'] ?? '';
        final instruction = step['html_instructions'] as String;
        final endLocation = step['end_location'];
        return {
          'maneuver': maneuver,
          'instruction': instruction,
          'location': LatLng(endLocation['lat'], endLocation['lng']),
        };
      }).toList();
    } else {
      throw Exception('Failed to load directions');
    }
  }

  void _updateCurrentInstruction() {
    if (_instructions.isEmpty || currentLocation == null) return;

    final currentLatLng =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
    final nextInstruction = _instructions.firstWhere(
      (instruction) {
        final instructionLatLng = instruction['location'] as LatLng;
        return _calculateDistance(currentLatLng, instructionLatLng) <
            20; // 20 meters threshold
      },
      orElse: () => _instructions.first,
    );

    setState(() {
      _instructions = [nextInstruction];
    });
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                hintText: 'Enter destination',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchDestination,
                ),
              ),
            ),
          ),
          Expanded(
            child: currentLocation == null
                ? const Center(child: Text("Loading"))
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        currentLocation!.latitude!,
                        currentLocation!.longitude!,
                      ),
                      zoom: 13.5,
                    ),
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId("route"),
                        points: polylineCoordinates,
                        color: const Color(0xFF7B61FF),
                        width: 6,
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId("currentLocation"),
                        icon: currentLocationIcon,
                        position: LatLng(
                          currentLocation!.latitude!,
                          currentLocation!.longitude!,
                        ),
                      ),
                      if (destination != null)
                        Marker(
                          markerId: const MarkerId("destination"),
                          icon: destinationIcon,
                          position: destination!,
                        ),
                    },
                    onMapCreated: (mapController) {
                      _controller.complete(mapController);
                    },
                  ),
          ),
          Expanded(
            child: _instructions.isEmpty
                ? const Center(child: Text("No instructions available"))
                : ListView.builder(
                    itemCount: _instructions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_instructions[index]['instruction']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
