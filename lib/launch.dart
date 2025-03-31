import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<LaunchPage> createState() => _LaunchPageState();
}

class _LaunchPageState extends State<LaunchPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Lottie.asset('assets/animations/rescue.json', width: 200, height: 200),
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
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
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

