import 'package:flutter/material.dart';
import 'login.dart';
import 'sos.dart';
import 'volunteer_registration.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _navigateToSOS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SOSPage()),
    );
  }

  void _volunteerRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VolunteerRegistrationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ResQ 360"),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red.shade700,
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
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.sos),
              title: const Text('SOS'),
              onTap: () => _navigateToSOS(context),
            ),
            ListTile(
              leading: const Icon(Icons.volunteer_activism),
              title: const Text('Become a Volunteer'),
              onTap: () => _volunteerRegister(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout_sharp),
              title: const Text('Logout'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildEmergencyButton(context, Icons.local_police, "Police"),
              _buildEmergencyButton(context, Icons.local_fire_department, "Fire"),
              _buildEmergencyButton(context, Icons.local_hospital, "Medical"),
              _buildEmergencyButton(context, Icons.waves, "Disaster"),
              _buildEmergencyButton(context, Icons.woman, "Women"),
              _buildEmergencyButton(context, Icons.child_care, "Child"),
              _buildEmergencyButton(context, Icons.train, "Railway"),
              _buildEmergencyButton(context, Icons.sos, "SOS"),
              _buildEmergencyButton(context, Icons.help, "Others"),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sos), label: 'SOS'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Volunteer'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {}, // Define actions for each button
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 5,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [const Color.fromARGB(255, 158, 30, 30), const Color.fromARGB(255, 202, 24, 24)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: label,
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}

