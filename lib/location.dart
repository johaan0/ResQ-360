import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class UserLocationMap extends StatefulWidget {
  @override
  _UserLocationMapState createState() => _UserLocationMapState();
}

class _UserLocationMapState extends State<UserLocationMap> {
  MapController? _mapController; // Make it nullable
  LatLng? _currentLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(); // Initialize the controller
    _getUserLocation();
  }

 

   Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }


    // Get current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    // Ensure mapController is not null before calling move()
    if (_mapController != null && _currentLocation != null) {
      _mapController!.move(_currentLocation!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Location Map")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation ?? LatLng(0, 0), // Default if no location
                zoom: 15.0,
              ),
              children: [
                // OpenStreetMap layer
                TileLayer(
  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
),


                // Marker for user's location
                if (_currentLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentLocation!,
                        width: 50,
                        height: 50,
                        child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getUserLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }
}
