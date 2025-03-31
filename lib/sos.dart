import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'main_layout.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:telephony_sms/telephony_sms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/location.dart';

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
  final _telephonySMS = TelephonySMS();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocationService _locationService = LocationService();



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

  Future<void> _triggerSOS() async {
    if (!isAnimating) {
      setState(() {
        isAnimating = true;
      });
      _animationController.forward();
    }

    // Play emergency sound
    await _audioPlayer.stop();
    await _audioPlayer.setSource(AssetSource('audio/test.mp3'));
    await _audioPlayer.resume();

    // Fetch user location
    Map<String, double>? locationData = await _locationService.getCurrentLocation();
    String locationMessage = locationData != null
        ? "My location: https://www.google.com/maps/search/?api=1&query=${locationData["latitude"]}%2C${locationData["longitude"]}"
        : "Location unavailable";

    // Fetch emergency contacts from Firestore
    String message = messageController.text.trim().isNotEmpty
        ? messageController.text
        : "Emergency! I need help!";
    message += "\n$locationMessage";

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        Fluttertoast.showToast(
          msg: "User not logged in!",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      String userEmail = user.email!;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Fluttertoast.showToast(
          msg: "No user found in the database!",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      DocumentSnapshot userDoc = querySnapshot.docs.first;
      List<dynamic>? contacts = userDoc.get('emergencyContacts');

      if (contacts != null && contacts.isNotEmpty) {
        List<Future<void>> smsFutures = [];

        for (String phoneNumber in contacts) {
          smsFutures
              .add(_telephonySMS.sendSMS(phone: phoneNumber, message: message));
        }
        await Future.wait(smsFutures); // Wait for all SMS tasks to complete

        Fluttertoast.showToast(
          msg: "SOS message sent to emergency contacts!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: "No emergency contacts found!",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error sending SOS: $e",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }

    // Stop animation after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
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
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF833AB4)),
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
          Positioned(
              bottom: 20,
              left: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  await _telephonySMS.requestPermission();
                },
                backgroundColor: const Color(0xFF833AB4),
                child: const Icon(Icons.approval, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
