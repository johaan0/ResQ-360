import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/volunteer/communication.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:flutter_slidable/flutter_slidable.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  Future<String> _getPlaceName(double lat, double lon) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.locality}, ${place.administrativeArea}";
      }
    } catch (e) {
      print("Geocoding error: $e");
    }
    return "Location Unavailable";
  }

  void _showDetailsPopup(
      BuildContext context, Map<String, dynamic> data, String docId) async {
    String place = "Location Unavailable";

    // Safely check and convert latitude and longitude
    if (data['location'] != null) {
      try {
        final GeoPoint point = data['location'];
        final lat = point.latitude;
        final lon = point.longitude;
        print("GeoPoint: $lat, $lon");
        place = await _getPlaceName(lat, lon);
      } catch (e) {
        print("GeoPoint error: $e");
      }
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(data['type_of_support'] ?? "Support Request"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Requested by: ${data['username'] ?? 'User'}"),
            Text("Email: ${data['email'] ?? 'Not Provided'}"),
            Text("Description: ${data['description']}"),
            Text("Location: $place"),
            Text("Status: ${data['status'] ?? 'Unknown'}"),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Decline"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("Accept"),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await FirebaseFirestore.instance
                    .collection('help_request')
                    .doc(docId)
                    .update(
                        {'assigned_volunteer': user.displayName ?? user.email});
              }
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunicationPage(requestData: data),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF833ab4), Color(0xFFfd1d1d)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
        automaticallyImplyLeading: true,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Notifications",
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
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('help_request')
            .orderBy('timestamp', descending: true)
            .limit(5)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(doc.id),
                direction: DismissDirection.horizontal,
                onDismissed: (direction) {},
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    onTap: () => _showDetailsPopup(context, data, doc.id),
                    leading: const Icon(Icons.warning_amber_rounded,
                        color: Colors.red),
                    title: Text(data['type_of_support'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text("Requested by ${data['username'] ?? 'User'}"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
