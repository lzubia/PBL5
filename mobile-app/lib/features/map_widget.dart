import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pbl5_menu/map_provider.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:provider/provider.dart';

class MapWidget extends StatefulWidget {
  final String title; // Set the title to 'home'

  const MapWidget({Key? key, required this.title}) : super(key: key);

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final TextEditingController _destinationController = TextEditingController();

  // Store the selected location
  LatLng? _selectedLocation;

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

  void _onLocationSelected(LatLng latLng) {
    setState(() {
      _selectedLocation = latLng;
    });

    if (widget.title == 'save') {
      // You can add a marker at the selected location
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Location Selected: ${latLng.latitude}, ${latLng.longitude}')),
      );
    }
  }

  void _saveSelectedLocation() {
    if (_selectedLocation != null) {
      // Here you would save the selected location to the database
      // For example, call the insertHome method
      final dbHelper = DatabaseHelper();
      dbHelper.insertHome(
          _selectedLocation!.latitude, _selectedLocation!.longitude);
      Navigator.pop(context); // Close the map screen after saving
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
    }
  }

  Widget _buildSearchBar(BuildContext context) {
    if (widget.title == 'guide') {
      return Row(
        children: [
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 30.0), // Add space on the right
              child: TextField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  hintText: 'Search destination',
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _searchDestination(context),
          ),
        ],
      );
    } else if (widget.title == 'save') {
      return IconButton(
        icon: const Icon(Icons.save),
        onPressed: _saveSelectedLocation,
        tooltip: 'Save Location',
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80.0, // Set the toolbar height
          title: Text(widget.title), // Dynamically set the title from widget
          actions: [
            Flexible(
              child: Padding(
                padding:
                    const EdgeInsets.all(8.0), // Add padding to the search bar
                child: _buildSearchBar(context),
              ),
            ),
          ],
        ),
        body: Consumer<MapProvider>(
          builder: (context, mapProvider, child) {
            if (mapProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (mapProvider.currentLocation == null) {
              return const Center(child: Text("Loading current location..."));
            }

            return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    mapProvider.currentLocation!.latitude!,
                    mapProvider.currentLocation!.longitude!,
                  ),
                  zoom: 13.5,
                ),
                onTap:
                    _onLocationSelected, // Allow the user to select location on tap
                polylines: {
                  Polyline(
                    polylineId: const PolylineId("route"),
                    points: mapProvider.polylineCoordinates,
                    color: const Color(0xFF7B61FF),
                    width: 6,
                  ),
                },
                markers: {
                  if (_selectedLocation != null)
                    if (widget.title == 'save')
                      Marker(
                        markerId: const MarkerId("selectedLocation"),
                        position: _selectedLocation!,
                      ),
                  Marker(
                    markerId: const MarkerId("currentLocation"),
                    position: LatLng(
                      mapProvider.currentLocation!.latitude!,
                      mapProvider.currentLocation!.longitude!,
                    ),
                  ),
                });
          },
        ));
  }
}
