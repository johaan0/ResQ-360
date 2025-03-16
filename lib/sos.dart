import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'main_layout.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  void _triggerSOS() async {
    if (!isAnimating) {
      setState(() {
        isAnimating = true;
      });
      _animationController.forward();
    }

   try {
    // Load and play the audio file
    await _audioPlayer.stop(); // Stop any previously playing audio
    await _audioPlayer.setSource(AssetSource('audio/test.mp3')); // Load the file
    await _audioPlayer.resume(); // Play the file
  } catch (e) {
   Fluttertoast.showToast(
        msg: "Error loading audio",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
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
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: const Duration(milliseconds: 800),
      child: MainLayout(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Emergency SOS",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF833AB4)),
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
                ],
              ),
            ),
            // Chat Widget at the bottom-right corner
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  // Chat functionality to be implemented
                },
                backgroundColor: const Color(0xFF833AB4),
                child: const Icon(Icons.chat, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
