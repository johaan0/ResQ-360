import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'main_layout.dart'; // Import MainLayout

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(9, (index) {
              final items = [
                {'icon': Icons.local_police, 'label': "Police"},
                {'icon': Icons.local_fire_department, 'label': "Fire"},
                {'icon': Icons.local_hospital, 'label': "Medical"},
                {'icon': Icons.waves, 'label': "Disaster"},
                {'icon': Icons.woman, 'label': "Women"},
                {'icon': Icons.child_care, 'label': "Child"},
                {'icon': Icons.train, 'label': "Railway"},
                {'icon': Icons.sos, 'label': "SOS"},
                {'icon': Icons.help, 'label': "Others"},
              ];
              
              return _buildEmergencyButton(
                items[index]['icon'] as IconData,
                items[index]['label'] as String,
                index,
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
        HapticFeedback.lightImpact(); // Subtle vibration feedback
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 48, color: Colors.white)
                  .animate()
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
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            ],
          ),
        ),
      )
      .animate()
      .slide(
        begin: index.isEven ? Offset(-1.5, 0) : Offset(1.5, 0),
        duration: 600.ms,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationController.forward(); // Trigger slide animation on page load
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}