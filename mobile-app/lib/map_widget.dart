import 'dart:async';
import 'dart:convert';

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
      }
    } else {
      print('No points found');
    }
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
        ],
      ),
    );
  }
}
