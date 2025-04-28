import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'chat_screen.dart';

class CommunicationPage extends StatefulWidget {
  final Map<String, dynamic> requestData;

  const CommunicationPage({super.key, required this.requestData});

  @override
  _CommunicationPageState createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  String phoneNumber = '';

  @override
  void initState() {
    super.initState();
    fetchPhoneNumber();
  }

  Future<void> fetchPhoneNumber() async {
    try {
      final email = widget.requestData['email'];
      final userSnap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (userSnap.docs.isNotEmpty) {
        setState(() {
          phoneNumber = userSnap.docs.first.data()['phone'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching phone number: $e");
    }
  }

  void _makePhoneCall(String number) async {
    final Uri url = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  final data = widget.requestData;

  // Check if 'location' is not null and has latitude and longitude
  final location = data['location'];
  
  if (location == null || location['latitude'] == null || location['longitude'] == null) {
   // return const Center(child: Text('Location data is not available'));
  }

  final lat = location['latitude'];
  final lon = location['longitude'];

  // Dummy volunteer location (you should replace this with actual coordinates)
  final volunteerLat = lat + 0.002; // Simulating volunteer location
  final volunteerLon = lon + 0.002;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Assistance Info',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF833ab4), Color.fromARGB(255, 210, 18, 140)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card with user details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text("Name: ${data['username']}"),
                        subtitle: Text("Email: ${data['email']}"),
                        trailing: Icon(Icons.person, color: const Color(0xFF833ab4)),
                      ),
                      Divider(),
                      ListTile(
                        title: Text("Support: ${data['type_of_support']}"),
                        subtitle: Text(data['description']),
                        trailing: Icon(Icons.info_outline, color: const Color(0xFF833ab4)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: [
                  if (phoneNumber.isNotEmpty)
                    ElevatedButton.icon(
                      icon: Icon(Icons.phone, color: Colors.white),
                      label: Text("Call User", style: TextStyle(color: Colors.white)),
                      onPressed: () => _makePhoneCall(phoneNumber),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 38, 163, 59),
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: Icon(Icons.chat, color: Colors.white),
                    label: Text("Start Chat", style: TextStyle(color: Colors.white)),
                   onPressed: () {
                         Navigator.push(
                         context,
                         MaterialPageRoute(
                        builder: (context) => ChatScreen(
                        userEmail: data['email'],
                        volunteerEmail: FirebaseAuth.instance.currentUser?.email ?? '',
                        ),
                       ),
                    );
                  },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF833ab4),
                      minimumSize: Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Map with route
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 500,
                      child: FlutterMap(
                        options: MapOptions(
                          center: LatLng((lat + volunteerLat) / 2, (lon + volunteerLon) / 2),
                          zoom: 14.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                            subdomains: const ['a', 'b', 'c'],
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(lat, lon),
                                width: 80,
                                height: 80,
                                child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                              ),
                              Marker(
                                point: LatLng(volunteerLat, volunteerLon),
                                width: 80,
                                height: 80,
                                child: Icon(Icons.directions_walk, color: Colors.green, size: 35),
                              ),
                            ],
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [LatLng(volunteerLat, volunteerLon), LatLng(lat, lon)],
                                strokeWidth: 4.0,
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Button on top of map
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.navigation, color: Colors.white),
                      label: Text("Start Journey", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        // Navigate to Google Maps or tracking logic
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
