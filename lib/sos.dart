import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'main_layout.dart';

class SOSPage extends StatefulWidget {
  const SOSPage({super.key});

  @override
  _SOSPageState createState() => _SOSPageState();
}

class _SOSPageState extends State<SOSPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  TextEditingController messageController = TextEditingController();
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  void _triggerSOS() {
    if (!isAnimating) {
      setState(() {
        isAnimating = true;
      });
      _animationController.forward();
    }

    // Show popup message
    Future.delayed(const Duration(seconds: 1), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("SOS Alert Sent!"),
          content: const Text("Help is on the way! Stay calm."),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    });

    // Stop animation after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        isAnimating = false;
      });
      _animationController.reset();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Emergency SOS",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF833AB4)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: messageController,
              style: const TextStyle(color: Color(0xFF833AB4)),
              decoration: InputDecoration(
                labelText: "Enter Emergency Message",
                labelStyle: const TextStyle(color: Color(0xFF833AB4)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF833AB4)),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.redAccent),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _triggerSOS,
              child: ZoomIn(
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Container(
                      width: 150 * _animation.value,
                      height: 150 * _animation.value,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 15,
                            spreadRadius: isAnimating ? 20 : 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "SOS",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text(
                "Go Back",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
