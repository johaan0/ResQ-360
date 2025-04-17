import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/admin/heatmap.dart';
import 'adminVolunteerRequests.dart'; // Volunteer requests page
import 'help_requests.dart';
import 'helpline_admin.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isAdmin = false;
  int userCount = 0;
  int approvedVolunteers = 0;
  int declinedVolunteers = 0;

  @override
  void initState() {
    super.initState();
    checkAdmin();
    fetchUserCount();
    fetchVolunteerStatus();
  }

  void checkAdmin() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      setState(() {
        isAdmin = userDoc.exists && userDoc.get("role") == "admin";
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> fetchUserCount() async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection("users").get();
      setState(() {
        userCount = usersSnapshot.docs.length;
      });
    } catch (e) {
      print("Error fetching user count: $e");
    }
  }

  Future<void> fetchVolunteerStatus() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('volunteers')
          .get();

      int approved = 0;
      int declined = 0;

      for (var doc in snapshot.docs) {
        String status = doc['status'];
        if (status == 'approved') approved++;
        if (status == 'declined') declined++;
      }

      setState(() {
        approvedVolunteers = approved;
        declinedVolunteers = declined;
      });
    } catch (e) {
      print("Error fetching volunteer data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'ResQ 360 Admin Dashboard',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
  PopupMenuButton<String>(
    onSelected: (value) {
      if (value == 'logout') {
        _logout();
      } else if (value == 'refresh') {
        fetchUserCount(); // Re-fetch users
        fetchVolunteerStatus(); // Re-fetch volunteers
        setState(() {}); // Refresh UI
      }
    },
    itemBuilder: (BuildContext context) {
      return [
        const PopupMenuItem<String>(
          value: 'refresh',
          child: ListTile(
            leading: Icon(Icons.refresh),
            title: Text('Refresh'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
          ),
        ),
      ];
            },
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFF56040)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: isAdmin
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Welcome, Admin!',
                    style: TextStyle( color: Color(0xFF833AB4),fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    title: "Total Registered Users",
                    value: userCount.toString(),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildCard(
                    title: "Volunteers",
                    value:
                        "Approved: $approvedVolunteers\nDeclined: $declinedVolunteers",
                    color: Colors.deepPurple,
                  ),
                  const SizedBox(height: 24),
                  _buildButton(
                    icon: Icons.volunteer_activism,
                    label: "Volunteer Requests",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AdminVolunteerRequestsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    icon: Icons.help,
                    label: "Help Requests",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HelpRequestsPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    icon: Icons.map,
                    label: "Heatmap",
                    onPressed: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HelpRequestHeatmapPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildButton(
                    icon: Icons.phone,
                    label: "Edit Helpline Numbers",
                    onPressed: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HelplineEditorPage()),
                      );
                    },
                  ),
                ],
              ),
            )
          : const Center(child: Text('Access Denied')),
    );
  }

  Widget _buildCard({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({required IconData icon, required String label, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF833AB4),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
    );
  }
}
