import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../main_layout.dart'; // Import your main layout

class NearbyHospitalsPage extends StatefulWidget {
  @override
  _NearbyHospitalsPageState createState() => _NearbyHospitalsPageState();
}

class _NearbyHospitalsPageState extends State<NearbyHospitalsPage> {
  //final String apiKey = 'Your API Key';
  List<Map<String, dynamic>> _hospitals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHospitals();
  }

  Future<void> _fetchHospitals() async {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=5000&type=hospital&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final results = data['results'] as List;

      setState(() {
        _hospitals = results
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
                itemCount: _hospitals.length,
                itemBuilder: (context, index) {
                  final hospital = _hospitals[index];
                  final name = hospital['name'] ?? 'Hospital';
                  final address = hospital['address'] ?? 'Address not available';
                  final phone = hospital['phone'];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white.withOpacity(0.95),
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Icon(Icons.local_hospital, color: Colors.redAccent),
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
