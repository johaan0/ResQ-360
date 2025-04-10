import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/about.dart';
import 'package:flutter_application_1/help_line.dart';
import 'package:flutter_application_1/police.dart';
import 'package:flutter_application_1/send_notification_button.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'main_layout.dart';
import 'location.dart'; // Import Location Page
import 'sos.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<bool> _isVisible = List.generate(10, (_) => false);

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(10, (index) {
              final items = [
                {'icon': Icons.run_circle_rounded, 'label': "Request Volunteer Support"},
                {'icon': Icons.phone, 'label': "HelpLine"},
                {'icon': Icons.local_hospital, 'label': "Medical"},
                {'icon': Icons.local_police, 'label': "Police"},
                {'icon': Icons.woman, 'label': "Women"},
                {'icon': Icons.child_care, 'label': "Child"},
                {'icon': Icons.location_pin, 'label': "Location"},
                {'icon': Icons.train, 'label': "Railway"},
                {'icon': Icons.sos, 'label': "SOS"},
                {'icon': Icons.help, 'label': "About"},
              ];

              return VisibilityDetector(
                key: Key("item_$index"),
                onVisibilityChanged: (visibilityInfo) {
                  if (visibilityInfo.visibleFraction > 0.1) {
                    setState(() {
                      _isVisible[index] = true;
                    });
                  }
                },
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: _isVisible[index] ? 1.0 : 0.0,
                  child: _buildEmergencyButton(
                    items[index]['icon'] as IconData,
                    items[index]['label'] as String,
                    index,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact(); // Vibration feedback
        if (label == "Location") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserLocationMap ()),
          );
        }
      
        HapticFeedback.lightImpact(); // Vibration feedback
        if (label == "SOS") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SOSPage ()),
          );
        }

         HapticFeedback.lightImpact(); // Vibration feedback
        if (label == "Request Volunteer Support") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RequestSupportPage() ),
          );
        }
        HapticFeedback.lightImpact(); // Vibration feedback
        if (label == "HelpLine") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HelplineUserPage() ),
          );
        }
        HapticFeedback.lightImpact(); // Vibration feedback
        if (label == "About") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AboutPage() ),
          );
        }
         HapticFeedback.lightImpact(); // Vibration feedback
        if (label == "Police") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NearbyPoliceStationsPage() ),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: Colors.black38,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFF56040)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 48, color: Colors.white)
                  .animate(target: _isVisible[index] ? 1 : 0)
                  .scale(delay: 200.ms, duration: 500.ms)
                  .shake(hz: 3, curve: Curves.easeInOut),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ).animate(target: _isVisible[index] ? 1 : 0)
                  .fadeIn(delay: 300.ms, duration: 500.ms),
            ],
          ),
        ),
      ).animate(target: _isVisible[index] ? 1 : 0).slide(
            begin: index.isEven ? Offset(-1.5, 0) : Offset(1.5, 0),
            duration: 600.ms,
            curve: Curves.easeOut,
          ),
    );
  }
}
