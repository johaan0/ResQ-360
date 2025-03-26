import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'main_layout.dart';
import 'cloudinary_service.dart';
import 'package:file_picker/file_picker.dart';

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> volunteerRoles = [
    "Emergency Response",
    "Logistics Support",
    "Food & Water Distribution",
    "Medical Assistance",
    "Shelter Management",
    "Rescue Operations"
  ];

  final List<String> locations = [
    "Kasaragod", "Kannur", "Wayanad", "Kozhikode",
    "Malappuram", "Palakkad", "Thrissur",
    "Ernakulam", "Idukki", "Kottayam"
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        userName = userDoc.get('name'); // Assuming 'name' is stored in 'users' collection
      });
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
      // Upload KYC document to Firebase Storage
      String kycUrl = await _uploadKyc();

      // Store volunteer details in Firestore
      await _firestore.collection('volunteers').add({
        'name': userName, // Foreign key reference to users collection
        'role': selectedRole,
        'location': selectedLocation,
        'kycUrl': kycUrl, // Store KYC document URL
        'approval': "pending", // Default approval status
        'volunteer': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your registration is being analyzed! We will get to you soon"), backgroundColor: Colors.green),
      );

      // Clear selections after successful registration
      setState(() {
        consentGiven = false;
        selectedRole = null;
        selectedLocation = null;
        kycFile = null;
        isUploading = false;
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
    allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'], // Allow both images and PDFs
  );

  if (result != null) {
    setState(() {
      kycFile = File(result.files.single.path!);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Container(
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
                      label: const Text("Upload KYC Document", style: TextStyle(color: Colors.black)),
                    ),
                    if (kycFile != null) Text("KYC Document Selected", style: TextStyle(color: Colors.green)),
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
