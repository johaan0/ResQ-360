import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HelpRequestsPage extends StatefulWidget {
  @override
  _HelpRequestsPageState createState() => _HelpRequestsPageState();
}

class _HelpRequestsPageState extends State<HelpRequestsPage> {
  late Future<List<Map<String, dynamic>>> helpRequests;
  List<Map<String, dynamic>> displayedRequests = [];

  Future<List<Map<String, dynamic>>> fetchHelpRequests() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('help_request')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        'id': doc.id, // For unique identification
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    helpRequests = fetchHelpRequests().then((data) {
      displayedRequests = data;
      return data;
    });
  }

  void removeRequest(String id) {
    setState(() {
      displayedRequests.removeWhere((req) => req['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Help Requests'),
        backgroundColor: Colors.purple,
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

          if (displayedRequests.isEmpty) {
            return const Center(child: Text("No help requests found."));
          }

          return ListView.builder(
            itemCount: displayedRequests.length,
            itemBuilder: (context, index) {
              final req = displayedRequests[index];
              final location = req['location'] ?? {};
              final lat = location['latitude'] ?? 'N/A';
              final lon = location['longitude'] ?? 'N/A';

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Username: ${req['username'] ?? 'Anonymous'}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text("Email: ${req['email'] ?? 'N/A'}"),
                            Text("Type of Support: ${req['type_of_support'] ?? ''}"),
                            Text("Description: ${req['description'] ?? ''}"),
                            Text("Location: ($lat, $lon)"),
                            Text("Time: ${req['timestamp'] ?? 'N/A'}"),
                            Text("Status: ${req['status']}"),
                            Text("Volunteer: ${req['assigned_volunteer'] ?? 'Not assigned'}"),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => removeRequest(req['id']),
                        ),
                      ),
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
