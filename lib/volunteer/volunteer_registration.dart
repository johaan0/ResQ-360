import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../main_layout.dart';
import '../Service/cloudinary_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lottie/lottie.dart'; // Add this package to pubspec.yaml

class VolunteerRegistrationPage extends StatefulWidget {
  const VolunteerRegistrationPage({super.key});

  @override
  _VolunteerRegistrationPageState createState() => _VolunteerRegistrationPageState();
}

class _VolunteerRegistrationPageState extends State<VolunteerRegistrationPage> {
  bool consentGiven = false;
  String? selectedRole;
  String? selectedLocation;
  String? userName;
  File? kycFile;
  bool isUploading = false;
  String? approvalStatus;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final List<String> volunteerRoles = [
    "Emergency Response", "Logistics Support", "Food & Water Distribution",
    "Medical Assistance", "Shelter Management", "Rescue Operations"
  ];

  final List<String> locations = [
    "Kasaragod", "Kannur", "Wayanad", "Kozhikode",
    "Malappuram", "Palakkad", "Thrissur",
    "Ernakulam", "Idukki", "Kottayam"
  ];

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyRegistered();
  }

  Future<void> _checkIfAlreadyRegistered() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        userName = userDoc.get('name');
      });

      QuerySnapshot volunteerSnap = await _firestore
          .collection('volunteers')
          .where('name', isEqualTo: userDoc.get('name'))
          .get();

      if (volunteerSnap.docs.isNotEmpty) {
        setState(() {
          approvalStatus = volunteerSnap.docs.first['status'];
        });
      }
    }
  }

  Future<void> _registerVolunteer() async {
    if (!consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must agree to the consent before registering."), backgroundColor: Colors.red),
      );
      return;
    }

    if (selectedRole == null || selectedLocation == null || kycFile == null || userName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required details and upload KYC document."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      String kycUrl = await _uploadKyc();

      await _firestore.collection('volunteers').add({
        'name': userName,
        'role': selectedRole,
        'location': selectedLocation,
        'kycUrl': kycUrl,
        'status': "pending",
        'volunteer': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _messaging.subscribeToTopic("volunteers");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your registration is being analyzed! We will get to you soon"), backgroundColor: Colors.green),
      );

      setState(() {
        consentGiven = false;
        selectedRole = null;
        selectedLocation = null;
        kycFile = null;
        isUploading = false;
        approvalStatus = "Pending";
      });
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  Future<String> _uploadKyc() async {
    CloudinaryService cloudinaryService = CloudinaryService();
    return await cloudinaryService.uploadFile(kycFile!);
  }

  Future<void> _pickKycDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        kycFile = File(result.files.single.path!);
      });
    }
  }

  Widget _buildStatusMessage() {
    String message = "";
    Widget? animation;

    switch (approvalStatus) {
      case "approved":
        message = "You're an  approved volunteer! You'll receive notifications when a user needs your help.";
        animation = Lottie.asset("assets/animations/tick.json", width: 500, repeat: false);
        break;
      case "declined":
        message = "Unfortunately, your registration was declined. But you can still request help when needed.";
        animation = Lottie.asset("assets/animations/reject1.json", width: 200, repeat: false);
        break;
      default:
        message = "Thankyou for registering! Your request is being reviewed.";
        animation = Lottie.asset("assets/animations/pending.json", width: 200, repeat: false);
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.pink, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              animation,
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: approvalStatus != null
          ? _buildStatusMessage()
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pink, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text("Volunteer Registration", 
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)
                            ),
                          ),
                          const SizedBox(height: 15),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "By registering as a volunteer, you agree to actively participate in emergency response activities, "
                              "assist in disaster relief operations, follow safety protocols, and provide humanitarian support when needed. "
                              "You also acknowledge the potential risks involved and confirm that you are physically and mentally prepared for volunteering.",
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            title: const Text("I have read and agree to the terms and conditions.", style: TextStyle(color: Colors.black)),
                            value: consentGiven,
                            onChanged: (value) {
                              setState(() {
                                consentGiven = value ?? false;
                              });
                            },
                            activeColor: Colors.redAccent,
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: selectedRole,
                            hint: const Text("Select Role", style: TextStyle(color: Colors.black54)),
                            items: volunteerRoles.map((role) => DropdownMenuItem(value: role, child: Text(role))).toList(),
                            onChanged: (value) => setState(() { selectedRole = value; }),
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: selectedLocation,
                            hint: const Text("Select Location", style: TextStyle(color: Colors.black54)),
                            items: locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
                            onChanged: (value) => setState(() { selectedLocation = value; }),
                            decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                          ),
                          const SizedBox(height: 15),
                          TextButton.icon(
                            onPressed: _pickKycDocument,
                            icon: const Icon(Icons.upload_file, color: Colors.black),
                            label: const Text("Upload KYC Document with Photo", style: TextStyle(color: Colors.black)),
                          ),
                          if (kycFile != null) const Text("KYC Document Selected", style: TextStyle(color: Colors.green)),
                          const SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: _registerVolunteer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: consentGiven && selectedRole != null && selectedLocation != null
                                    ? Colors.redAccent
                                    : Colors.grey,
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("Register", style: TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
