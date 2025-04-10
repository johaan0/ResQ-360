import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HelpRequestsPage extends StatefulWidget {
  @override
  _HelpRequestsPageState createState() => _HelpRequestsPageState();
}

class _HelpRequestsPageState extends State<HelpRequestsPage> {
  late Future<List<Map<String, dynamic>>> helpRequests;

  Future<List<Map<String, dynamic>>> fetchHelpRequests() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('help_request').get();

    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    helpRequests = fetchHelpRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Help Requests'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: helpRequests,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(child: Text("No help requests found."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              final location = req['location'] ?? {};
              final lat = location['latitude'] ?? 'N/A';
              final lon = location['longitude'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 Username: ${req['username'] ?? 'Anonymous'}",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("📧 Email: ${req['email'] ?? 'N/A'}"),
                      Text("🆘 Type of Support: ${req['type_of_support'] ?? ''}"),
                      Text("📝 Description: ${req['description'] ?? ''}"),
                      Text("📍 Location: ($lat, $lon)"),
                      Text("📅 Time: ${req['timestamp'] ?? 'N/A'}"),
                      Text("✅ Status: ${req['status']}"),
                      Text("👮 Volunteer: ${req['assigned_volunteer'] ?? 'Not assigned'}"),
                    ],
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
