import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pbl5_menu/map_provider.dart';
import 'package:provider/provider.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<MapProvider>(context, listen: false).getCurrentLocation();
  }

  Future<void> _searchDestination(BuildContext context) async {
    final mapProvider = Provider.of<MapProvider>(context, listen: false);
    try {
      await mapProvider.setDestination(_destinationController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchDestination(context),
                ),
              ),
            ),
          ),
          Expanded(
            child: Consumer<MapProvider>(
              builder: (context, mapProvider, child) {
                if (mapProvider.currentLocation == null) {
                  return const Center(child: Text("Loading..."));
                }

                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      mapProvider.currentLocation!.latitude!,
                      mapProvider.currentLocation!.longitude!,
                    ),
                    zoom: 13.5,
                  ),
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: mapProvider.polylineCoordinates,
                      color: const Color(0xFF7B61FF),
                      width: 6,
                    ),
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('currentLocation'),
                      position: LatLng(
                        mapProvider.currentLocation!.latitude!,
                        mapProvider.currentLocation!.longitude!,
                      ),
                    ),
                    if (mapProvider.destination != null)
                      Marker(
                        markerId: const MarkerId('destination'),
                        position: mapProvider.destination!,
                      ),
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
