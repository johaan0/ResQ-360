import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  final Widget body;
  const MainLayout({super.key, required this.body});

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different screens based on index
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

  void _logout(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToSOS(BuildContext context) {
    Navigator.pushNamed(context, '/sos');
  }

  void _volunteerRegister(BuildContext context) {
    Navigator.pushNamed(context, '/volunteer_registration');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
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
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text("User Name", style: TextStyle(fontSize: 18, color: Colors.white)),
                  Text("user@example.com", style: TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context), // Just close the drawer
            ),
            ListTile(
              leading: const Icon(Icons.sos),
              title: const Text('SOS'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                _navigateToSOS(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: const Text('Become a Volunteer'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                _volunteerRegister(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_sharp),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                _logout(context);
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
        onTap: _onItemTapped,
      ),
    );
  }
}

