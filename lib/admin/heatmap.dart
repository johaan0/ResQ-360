import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelpRequestHeatmapPage extends StatefulWidget {
  const HelpRequestHeatmapPage({super.key});

  @override
  State<HelpRequestHeatmapPage> createState() => _HelpRequestHeatmapPageState();
}

class _HelpRequestHeatmapPageState extends State<HelpRequestHeatmapPage> {
  List<LatLng> requestLocations = [];

  @override
  void initState() {
    super.initState();
    fetchRequestLocations();
  }

  Future<void> fetchRequestLocations() async {
  final snapshot = await FirebaseFirestore.instance.collection("help_request").get();
  List<LatLng> locations = [];

  for (var doc in snapshot.docs) {
    final data = doc.data();
    final location = data['location'];

    if (location != null && location['latitude'] != null && location['longitude'] != null) {
      double lat = (location['latitude'] as num).toDouble();
      double lon = (location['longitude'] as num).toDouble();
      locations.add(LatLng(lat, lon));
    }
  }

  setState(() {
    requestLocations = locations;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Help Requests Map",
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
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(10.8505, 76.2711), // Center on Kerala
          zoom: 7.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: requestLocations.map((location) {
              return Marker(
                width: 50,
                height: 50,
                point: location,
                child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
