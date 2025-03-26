import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';


class AdminVolunteerRequestsPage extends StatefulWidget {
  @override
  _AdminVolunteerRequestsPageState createState() => _AdminVolunteerRequestsPageState();
}

class _AdminVolunteerRequestsPageState extends State<AdminVolunteerRequestsPage> {
  final CollectionReference volunteers = FirebaseFirestore.instance.collection('volunteers');

  // Function to update volunteer status
  Future<void> updateStatus(String docId, String status) async {
    await volunteers.doc(docId).update({'status': status});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Volunteer Requests")),
      body: StreamBuilder<QuerySnapshot>(
        stream: volunteers.where("approval", isEqualTo: "pending").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var volunteerList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: volunteerList.length,
            itemBuilder: (context, index) {
              var volunteer = volunteerList[index];
              var volunteerData = volunteer.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(volunteerData['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Email: ${volunteerData['email']}"),
                      Text("Phone: ${volunteerData['phone']}"),
                      SizedBox(height: 5),
                      Text("KYC Document:"),
                      volunteerData['kycUrl'] != null
                          ? GestureDetector(
                              onTap: () => _viewKycDocument(volunteerData['kycUrl']),
                              child: Text(
                                "View KYC",
                                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                              ),
                            )
                          : Text("No KYC uploaded"),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () => updateStatus(volunteer.id, "approved"),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => updateStatus(volunteer.id, "declined"),
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

  // Function to open the KYC document in the browser
 void _viewKycDocument(String url) {
  bool isImage = url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png');
  bool isPdf = url.endsWith('.pdf');

  if (isImage) {
    // Show image in an AlertDialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("KYC Document"),
        content: Image.network(url, fit: BoxFit.contain),
        actions: [
          TextButton(
            child: Text("Close"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  } else if (isPdf) {
    // Open PDF in an external browser or PDF viewer
    _openPdf(url);
  } else {
    // Handle unsupported file types
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unsupported file format")),
    );
  }
}

// Function to open PDF in the browser
void _openPdf(String url) async {
  Uri uri = Uri.parse(url); // Convert string URL to Uri

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication); 
  } else {
    throw 'Could not open PDF file: $url';
  }
}
}
