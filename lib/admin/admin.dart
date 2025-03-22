import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    checkAdmin();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ResQ 360 Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFF56040)], // Instagram theme
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFE1306C), Color(0xFFF56040)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF833AB4), Color(0xFFF56040)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 40,
                      child: Icon(Icons.admin_panel_settings, size: 40, color: Color(0xFF833AB4)),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Admin Panel",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.volunteer_activism, color: Colors.white),
                title: const Text("Volunteer Requests", style: TextStyle(color: Colors.white)),
                onTap: () {
                  // Navigate to volunteer requests page
                },
              ),
              const Divider(color: Colors.white54),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text("Logout", style: TextStyle(color: Colors.white)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: isAdmin
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome, Admin!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to volunteer requests page
                    },
                    icon: const Icon(Icons.volunteer_activism),
                    label: const Text("Volunteer Requests"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF833AB4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: Text('Access Denied')),
    );
  }
}


