import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pdfviewrscreen.dart';

class AdminVolunteerRequestsPage extends StatefulWidget {
  const AdminVolunteerRequestsPage({super.key});

  @override
  _AdminVolunteerRequestsPageState createState() => _AdminVolunteerRequestsPageState();
}

class _AdminVolunteerRequestsPageState extends State<AdminVolunteerRequestsPage> {
  final CollectionReference volunteers = FirebaseFirestore.instance.collection('volunteers');
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> updateStatus(String docId, String status) async {
    bool confirmed = await _showConfirmationDialog(status);
    if (confirmed) {
      await volunteers.doc(docId).update({'status': status});
    }
  }

  Future<bool> _showConfirmationDialog(String action) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Confirm ${action == "approved" ? "Approval" : "Rejection"}'),
            content: Text('Are you sure you want to ${action == "approved" ? "approve" : "decline"} this volunteer?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                child: Text('Yes'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<Map<String, dynamic>?> _getUserData(String name) async {
    var snapshot = await users.where('name', isEqualTo: name).get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data() as Map<String, dynamic>;
    }
    return null;
  }

  void _showVolunteerDetails(Map<String, dynamic> volunteerData) async {
    String? name = volunteerData['name'];
   var userData = name != null ? await _getUserData(name) : null;


    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Volunteer Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (userData != null) ...[
                Text("Name: ${userData['name'] ?? 'Not available'}"),
                Text("Email: ${userData['email'] ?? 'Not available'}"),
              ],
              Text("Place: ${volunteerData['location'] ?? 'Not provided'}"),

              Text("Support Type: ${volunteerData['role'] ?? 'Not provided'}"),
              SizedBox(height: 10),
              (volunteerData['kycUrl'] ?? '').toString().isNotEmpty
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
        ),
        actions: [
          TextButton(child: Text("Close"), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  automaticallyImplyLeading: true,
  leading: BackButton(color: Colors.white),
  title: Text(
    "Volunteer Requests",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: volunteers.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var volunteerList = snapshot.data!.docs;

          return ListView.builder(
            itemCount: volunteerList.length,
            itemBuilder: (context, index) {
              var volunteer = volunteerList[index];
              var volunteerData = volunteer.data() as Map<String, dynamic>;
              final status = volunteerData['status'] ?? 'pending';

              Color cardColor;
              if (status == 'approved') {
                cardColor = Colors.green.shade100;
              } else if (status == 'declined') {
                cardColor = Colors.red.shade100;
              } else {
                cardColor = Colors.white;
              }

              return GestureDetector(
                onTap: () => _showVolunteerDetails(volunteerData),
                child: Card(
                  color: cardColor,
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(volunteerData['name'] ?? 'No name'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Email: ${volunteerData['email']}"),
                        Text("Phone: ${volunteerData['phone']}"),
                        Text("Status: $status"),
                      ],
                    ),
                    trailing: status == 'pending'
                        ? Row(
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
                          )
                        : null,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _viewKycDocument(String url) {
    bool isImage = url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png');
    bool isPdf = url.endsWith('.pdf');

    if (isImage) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("KYC Document"),
          content: Image.network(url, fit: BoxFit.contain),
          actions: [
            TextButton(child: Text("Close"), onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
    } else if (isPdf) {
      _openPdf(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unsupported file format")),
      );
    }
  }

  void _openPdf(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open PDF file")),
      );
    }
  }
}

