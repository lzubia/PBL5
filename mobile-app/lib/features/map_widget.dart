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

class MapWidget extends StatefulWidget {
  final ITtsService ttsService;
  BuildContext context;
  MapWidget({super.key, required this.ttsService, required this.context});

  @override
  State<MapWidget> createState() => MapWidgetState(this.context);
}

class MapWidgetState extends State<MapWidget> {
  final Completer<GoogleMapController> _controller = Completer();
  final TextEditingController _destinationController = TextEditingController();

  LatLng? destination;
  String destinationText = '';
  BuildContext context;

  List<LatLng> polylineCoordinates = [];
  List<Map<String, dynamic>> _instructions = [];
  LocationData? currentLocation;
  StreamSubscription<LocationData>? locationSubscription;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  MapWidgetState(this.context);

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void setContext(BuildContext context) {
    this.context = context;
  }

  void getCurrentLocation() async {
    widget.ttsService
        .speakLabels([AppLocalizations.of(context).translate("mapa-on")]);

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
                  zoom: 17,
                  target: LatLng(
                    newLoc.latitude!,
                    newLoc.longitude!,
                  ),
                ),
              ),
            );
            _updateCurrentInstruction(); // Update instructions dynamically
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
    setState(() {
      destinationText = _destinationController.text;
    });
    final response = await http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=${_destinationController.text}&key=$apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'ZERO_RESULTS') {
        widget.ttsService.speakLabels(['loc_not_found']);
        return;
      }
      final location = data['results'][0]['geometry']['location'];
      setState(() {
        destination = LatLng(location['lat'], location['lng']);
        getPolyPoints();
      });
    } else {
      throw Exception('Failed to load location');
    }
  }

  String removeHtmlTags(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlText.replaceAll(exp, '');
  }

  Future<String> translateText(String text, String targetLanguage) async {
    final apiKey = dotenv.env['TRANSLATE_API_KEY'];
    final response = await http.post(
      Uri.parse(
          'https://translation.googleapis.com/language/translate/v2?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'q': text,
        'source': 'en',
        'target': 'es',
        'format': 'text',
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']['translations'][0]['translatedText'];
    } else {
      throw Exception('Failed to translate text');
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
        setState(() {
          polylineCoordinates.clear();
          for (PointLatLng point in result.points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        });

        _instructions = await fetchDirections(
          '${currentLocation?.latitude},${currentLocation?.longitude}',
          '${destination?.latitude},${destination?.longitude}',
          dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
        );

        if (_instructions.isNotEmpty) {
          final firstInstruction =
              removeHtmlTags(_instructions[0]['instruction']);
          final translatedInstruction =
              await translateText(firstInstruction, 'es');
          widget.ttsService.speakLabels([
            "${[
              AppLocalizations.of(context).translate("start_trip")
            ]} $destinationText . ${[
              AppLocalizations.of(context).translate("first")
            ]}, $translatedInstruction"
          ]);
          // setState(() {
          //   _instructions = _instructions.sublist(0);
          // });
        }
      }
    } else {
      print('No points found');
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
        final startLocation = step['start_location'];
        final endLocation = step['end_location'];
        return {
          'maneuver': maneuver,
          'instruction': instruction,
          'start_location': LatLng(startLocation['lat'], startLocation['lng']),
          'end_location': LatLng(endLocation['lat'], endLocation['lng']),
        };
      }).toList();
    } else {
      throw Exception('Failed to load directions');
    }
  }

  void _updateCurrentInstruction() async {
    if (_instructions.isEmpty || currentLocation == null) return;

    final currentLatLng = LatLng(
      currentLocation!.latitude!,
      currentLocation!.longitude!,
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
      final instruction =
          removeHtmlTags(_instructions[closestIndex]['instruction']);
      final translatedInstruction = await translateText(instruction, 'es');
      await widget.ttsService.speakLabels([
        "${AppLocalizations.of(context).translate("now")}, $translatedInstruction"
      ]);
      setState(() {
        _instructions = _instructions.sublist(closestIndex + 1);
      });
    }
    if (_instructions.length == 0) {
      widget.ttsService.speakLabels([
        "${AppLocalizations.of(context).translate("reached")} $destinationText"
      ]);
    }
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
        ],
      ),
    );
  }
}
