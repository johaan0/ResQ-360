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

  if (location != null && location['lat'] != null && location['lon'] != null) {
    double lat = (location['lat'] as num).toDouble();
    double lon = (location['lon'] as num).toDouble();
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
        title: const Text('Help Request Heatmap'),
        backgroundColor: const Color(0xFF833AB4),
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
          CircleLayer(
            circles: requestLocations.map((location) {
              return CircleMarker(
                point: location,
                color: Colors.red.withOpacity(0.5),
                radius: 15,
                borderColor: Colors.redAccent,
                borderStrokeWidth: 1,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
