import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'main_layout.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF833AB4), Color(0xFFF56040), Color(0xFFFFC837)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: const Icon(Icons.shield_rounded, size: 100, color: Colors.white),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: const Text(
                    "About ResQ 360",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 15),
                FadeInUp(
                  duration: const Duration(milliseconds: 1200),
                  child: const Text(
                    "ResQ 360 is an advanced Emergency Response System designed to connect affected individuals, emergency services, and volunteers in times of crisis. Our platform ensures quick response to disasters, accidents, and medical emergencies through real-time location sharing, SOS alerts, and volunteer coordination.",
                    style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 25),
                FadeInLeft(
                  duration: const Duration(milliseconds: 1300),
                  child: _buildFeatureTile(Icons.sos, "Instant SOS Alerts",
                      "Send emergency alerts with real-time location to responders."),
                ),
                FadeInRight(
                  duration: const Duration(milliseconds: 1400),
                  child: _buildFeatureTile(Icons.location_on, "Live Tracking",
                      "Track emergency responders and volunteers in real-time."),
                ),
                FadeInLeft(
                  duration: const Duration(milliseconds: 1500),
                  child: _buildFeatureTile(Icons.volunteer_activism, "Volunteer Network",
                      "Mobilize local volunteers for immediate assistance."),
                ),
                FadeInRight(
                  duration: const Duration(milliseconds: 1600),
                  child: _buildFeatureTile(Icons.notifications_active, "Real-time Alerts",
                      "Receive critical updates and emergency notifications."),
                ),
                const SizedBox(height: 20),
                /*FadeInUp(
                  duration: const Duration(milliseconds: 1800),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text("Back to Home", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30, color: Colors.white),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 5),
                Text(description, style: const TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
