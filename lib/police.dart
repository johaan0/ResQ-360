import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'main_layout.dart'; // Import your main layout

class NearbyPoliceStationsPage extends StatefulWidget {
  @override
  _NearbyPoliceStationsPageState createState() => _NearbyPoliceStationsPageState();
}

class _NearbyPoliceStationsPageState extends State<NearbyPoliceStationsPage> {
  final String apiKey = 'AIzaSyC1tSvmENNjKFJrvaSTjUtQER9r1vXr-NM';
  List<Map<String, dynamic>> _stations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchPoliceStations();
  }

  Future<void> _fetchPoliceStations() async {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=5000&type=police&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final results = data['results'] as List;

      setState(() {
        _stations = results
            .map((place) => {
                  'name': place['name'],
                  'address': place['vicinity'],
                  'phone': place['formatted_phone_number'], // Only if available
                })
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      print("Error: ${data['status']}");
    }
  }

  void _callNumber(String number) async {
    final url = 'tel:$number';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot open dialer")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      //title: "Nearby Police Stations",
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF833ab4), Color(0xFFfd1d1d), Color(0xFFfcb045)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _loading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : ListView.builder(
                padding: EdgeInsets.all(12),
                itemCount: _stations.length,
                itemBuilder: (context, index) {
                  final station = _stations[index];
                  final name = station['name'] ?? 'Police Station';
                  final address = station['address'] ?? 'Address not available';
                  final phone = station['phone'];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white.withOpacity(0.95),
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Icon(Icons.local_police, color: Colors.deepPurple),
                      title: Text(
                        name,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Text(address),
                      trailing: phone != null
                          ? IconButton(
                              icon: Icon(Icons.call, color: Colors.green),
                              onPressed: () => _callNumber(phone),
                            )
                          : null,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
