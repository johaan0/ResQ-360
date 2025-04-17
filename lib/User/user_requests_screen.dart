import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../volunteer/chat_screen.dart';

class UserRequestsScreen extends StatelessWidget {
  const UserRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF833ab4), Color(0xFFFD1D1D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "My Help Requests",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('help_request')
            .where('email', isEqualTo: currentUserEmail)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(child: Text("No help requests found."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;

              final supportType = data['type_of_support'] ?? '';
              final description = data['description'] ?? '';
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final formattedTime = timestamp != null
                  ? "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}"
                  : 'N/A';

              final assignedVolunteer = data['assigned_volunteer'];
              final isFulfilled = data['status'] == 'fulfilled';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Type: $supportType", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text("Description: $description"),
                      const SizedBox(height: 6),
                      Text("Requested on: $formattedTime"),
                      const SizedBox(height: 12),

                      if (assignedVolunteer != null && assignedVolunteer.toString().isNotEmpty) ...[
                        FutureBuilder<QuerySnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('users')
                              .where('email', isEqualTo: assignedVolunteer)
                              .limit(1)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text("Loading volunteer details...");
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Text("Volunteer data not found.");
                            }

                            final volunteerData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                            final volunteerName = volunteerData['name'] ?? 'Unnamed';
                            final volunteerPhone = volunteerData['phone'] ?? '';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Volunteer: $volunteerName", style: const TextStyle(color: Colors.green)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF833ab4),
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.chat, color: Colors.white),
                                      label: const Text("Chat"),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ChatScreen(
                                              userEmail: currentUserEmail!,
                                              volunteerEmail: assignedVolunteer!,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.call, color: Colors.white),
                                      label: const Text("Call"),
                                      onPressed: () async {
                                        final Uri uri = Uri(scheme: 'tel', path: volunteerPhone);
                                        if (await canLaunchUrl(uri)) {
                                          await launchUrl(uri);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Could not launch phone app.")),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ] else ...[
                        const Text("Volunteer not assigned yet.", style: TextStyle(color: Colors.orange)),
                      ],

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text("Delete Request", style: TextStyle(color: Colors.red)),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Request"),
                                  content: const Text("Are you sure you want to delete this request?"),
                                  actions: [
                                    TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context, false)),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      child: const Text("Delete"),
                                      onPressed: () => Navigator.pop(context, true),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await FirebaseFirestore.instance.collection('help_request').doc(doc.id).delete();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Help request deleted.")));
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFulfilled ? Colors.green : Colors.red,
                            ),
                            icon: Icon(isFulfilled ? Icons.check_circle : Icons.done),
                            label: Text(isFulfilled ? "Marked as Fulfilled" : "Mark as Fulfilled"),
                            onPressed: isFulfilled
                                ? null
                                : () async {
                                    await FirebaseFirestore.instance
                                        .collection('help_request')
                                        .doc(doc.id)
                                        .update({'status': 'fulfilled'});

                                    // Show popup
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text("Marked as Fulfilled"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Text("Hope your need was fulfilled."),
                                            SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.star, color: Colors.amber),
                                                Icon(Icons.star, color: Colors.amber),
                                                Icon(Icons.star, color: Colors.amber),
                                                Icon(Icons.star, color: Colors.amber),
                                                Icon(Icons.star, color: Color.fromARGB(255, 138, 138, 138)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Close"),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                          ),
                        ],
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

