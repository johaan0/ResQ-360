import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/User/notifications.dart';

class MainLayout extends StatefulWidget {
  final Widget body;
  const MainLayout({super.key, required this.body});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  String userName = "Loading...";
  String userEmail = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc.get('name') ?? "Unknown User";
            userEmail = userDoc.get('email') ?? "No Email";
          });
          print("Fetched User: $userName, $userEmail"); // Debugging
        } else {
          print("User document does not exist");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    } else {
      print("No user logged in");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/sos');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  void _home(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/home');
  }

 void _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut(); // Sign out the user
  Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
}

  void _navigateToSOS(BuildContext context) {
    Navigator.pushNamed(context, '/sos');
  }

  void _volunteerRegister(BuildContext context) {
    Navigator.pushNamed(context, '/volunteer_registration');
  }

  void _about(BuildContext context) {
    Navigator.pushNamed(context, '/about');
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFF56040)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
  title: const Text(
    "ResQ 360",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  backgroundColor: Colors.transparent,
  elevation: 0,
  iconTheme: const IconThemeData(
    color: Color(0xFFFFFFFF), // Change this to any color you like
  ),
  actions: [
    IconButton(
  icon: const Icon(Icons.notifications, color: Colors.white),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
  },
),

  ],
),

        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF833AB4),
                    Color(0xFFF56040),
                    Color(0xFFFFC837),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.account_circle, size: 50, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(userName, style: const TextStyle(fontSize: 18, color: Colors.white)),
                  Text(userEmail, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                _home(context);
              }
            ),
            ListTile(
              leading: const Icon(Icons.sos),
              title: const Text('SOS'),
              onTap: () {
                Navigator.pop(context);
                _navigateToSOS(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: const Text('Become a Volunteer'),
              onTap: () {
                Navigator.pop(context);
                _volunteerRegister(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_sharp),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                _about(context);
              },
            ),
            
          ],
        ),
      ),
      body: widget.body,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sos), label: 'SOS'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF833AB4),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        selectedIconTheme: const IconThemeData(color: Color(0xFF833AB4)),
      ),
    );
  }
}