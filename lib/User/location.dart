import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

class LocationService {
  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return {
        "latitude": position.latitude,
        "longitude": position.longitude
      };
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }
}

class UserLocationMap extends StatefulWidget {
  const UserLocationMap({super.key});

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
    _updateUserLocation();
  }

  /// This function gets the user's location and updates the map
  Future<void> _updateUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied.");
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      if (_mapController != null) {
        _mapController!.move(_currentLocation!, 15.0);
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _shareLocation() async {
  if (_currentLocation != null) {
    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${_currentLocation!.latitude},${_currentLocation!.longitude}";
    String message = "Here's my current location: $googleMapsUrl";

    await Share.share(message);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Location not available yet')),
    );
  }
}

  /// This function returns the latitude and longitude for external use (e.g., SOS message)
  Future<Map<String, double>?> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return {
        "latitude": position.latitude,
        "longitude": position.longitude
      };
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  automaticallyImplyLeading: true,
  leading: BackButton(color: Colors.white),
  title: Text(
    "Your Current Location",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.purple, Colors.red],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
  backgroundColor: Colors.transparent,
  elevation: 0,
),

      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? LatLng(0, 0), // Default if no location
                initialZoom: 16.0,
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
      floatingActionButton: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    FloatingActionButton(
      heroTag: 'location_btn',
      onPressed: _updateUserLocation,
      child: Icon(Icons.my_location),
    ),
    SizedBox(height: 10),
    FloatingActionButton(
      heroTag: 'share_btn',
      onPressed: _shareLocation,
      child: Icon(Icons.share),
      backgroundColor: Colors.purple,
    ),
  ],
),

    );
  }
}
