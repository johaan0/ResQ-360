import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Subscribe to 'volunteers' topic (TEMP for testing)
  FirebaseMessaging.instance.subscribeToTopic("volunteers");

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      // Check Firebase auth session
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home'); // or your main page
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
          // Background Animation
          Positioned.fill(
            child: Lottie.asset(
              'assets/animations/background.json',
              fit: BoxFit.cover,
            ),
          ),

          // Foreground Content
          Center(
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'ResQ 360',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Bebas',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 40),
                    Lottie.asset(
                      'assets/animations/loader.json',
                      width: 100,
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
          ),

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
                  color: const Color.fromARGB(255, 93, 41, 142),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
