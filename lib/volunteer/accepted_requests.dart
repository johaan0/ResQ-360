import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AcceptedRequestsPage extends StatefulWidget {
  const AcceptedRequestsPage({Key? key}) : super(key: key);

  @override
  State<AcceptedRequestsPage> createState() => _AcceptedRequestsPageState();
}

class _AcceptedRequestsPageState extends State<AcceptedRequestsPage> {
  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email; // Get email instead of uid

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: BackButton(color: Colors.white), // White color for back button
        title: const Text(
          'Accepted Requests',
          style: TextStyle(
            color: Colors.white, // White color for title
            fontWeight: FontWeight.bold, // Bold font for title
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.pinkAccent, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('help_request')
            .where('assigned_volunteer', isEqualTo: userEmail) // Filter by email
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No accepted requests found.', style: TextStyle(fontSize: 16)),
            );
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final supportType = request['type_of_support'] ?? '';
              final username = request['username'] ?? '';
              final status = request['status'] ?? 'not fulfilled';

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text('Support Type: $supportType', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Requested by: $username'),
                      const SizedBox(height: 5),
                      Text('Status: ${status.toUpperCase()}',
                          style: TextStyle(
                              color: status == 'fulfilled' ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  //trailing: const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
                  // Remove onTap to prevent navigation
                ),
              );
            },
          );
        },
      ),
    );
  }
}

