import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleExpansion;

  @override
void initState() {
  super.initState();

  _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  );

  _circleExpansion = Tween<double>(begin: 0.0, end: 2.0).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
  );

  _controller.forward();

  Timer(const Duration(seconds: 5), () async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

     final volunteerDoc = await FirebaseFirestore.instance
    .collection('volunteers')
    .doc(user.uid)
    .get();

if (volunteerDoc.exists) {
  final status = volunteerDoc.data()?['status'];
  if (status == 'approved') {
    await FirebaseMessaging.instance.subscribeToTopic("volunteers");
    print("✅ Subscribed to volunteers topic");
  }
  // No else -> don't unsubscribe here blindly
}

      if (userDoc.exists && userDoc.data()!['role'] == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  });
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with purple fill expanding circle from center
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: CircleExpandPainter(
                    color: Color(0xFF6A1B9A),
                    radiusScale: _circleExpansion.value,
                  ),
                );
              },
            ),
          ),
         

          // Centered Logo, Slogan, and Loader
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/app_icon.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  '"Empowering communities, saving lives."',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Bebas',
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Lottie.asset(
                  'assets/animations/loader4.json',
                  width: 100,
                  height: 100,
                ),
              ],
            ),
          ),

          // Footer
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Developed by Johan MZ",
                style: TextStyle(
                  fontFamily: 'Bebas',
                  fontSize: 16,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircleExpandPainter extends CustomPainter {
  final Color color;
  final double radiusScale;

  CircleExpandPainter({required this.color, required this.radiusScale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * radiusScale;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
