import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/Auth/login.dart';
import '../main_layout.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? user;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  
  List<TextEditingController> emergencyContacts = List.generate(5, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  // Fetch user data from Firebase
  Future<void> getUserData() async {
    user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _firestore.collection("users").doc(user!.uid).get();
      if (userData.exists) {
        setState(() {
          nameController.text = userData["name"] ?? "";
          emailController.text = user!.email ?? "";
          phoneController.text = userData["phone"] ?? "";
          
          List<dynamic> contacts = userData["emergencyContacts"] ?? [];
          for (int i = 0; i < contacts.length && i < 5; i++) {
            emergencyContacts[i].text = contacts[i];
          }
        });
      }
    }
  }

  // Save user data to Firebase
  Future<void> saveUserData() async {
    if (user != null) {
      await _firestore.collection("users").doc(user!.uid).set({
        "name": nameController.text,
        "phone": phoneController.text,
        "emergencyContacts": emergencyContacts.map((c) => c.text).toList(),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully"), backgroundColor: Colors.green)
      );
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close dialog
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close dialog first
              await _deleteAccount();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Delete user account
  Future<void> _deleteAccount() async {
    try {
      if (user != null) {
        String uid = user!.uid;

        // First delete user document from Firestore
        await _firestore.collection("users").doc(uid).delete();

        // Then delete Firebase Auth account
        await user!.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully"), backgroundColor: Colors.red)
        );

        // Optional: Navigate to login page or splash after deletion
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
      }
    } catch (e) {
      print("Error deleting account: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete account"), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Color(0xFFE91E63), Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              // Profile Picture
              Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_outline, size: 50, color: Colors.black),
                ),
              ),
              const SizedBox(height: 20),
              // Name Field
              buildTextField("Full Name", nameController, isEditable: false),
              const SizedBox(height: 10),
              // Email Field (Non-Editable)
              buildTextField("Email", emailController, isEditable: false),
              const SizedBox(height: 10),
              // Phone Field
              buildTextField("Phone Number", phoneController),
              const SizedBox(height: 20),
              const Text("Emergency Contacts", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // Emergency Contacts
              Column(
                children: [
                  for (int i = 0; i < 5; i++) ...[
                    buildTextField("Contact ${i + 1}", emergencyContacts[i]),
                    const SizedBox(height: 10),
                  ]
                ],
              ),
              const SizedBox(height: 10),
              // Save Button
              ElevatedButton(
                onPressed: saveUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
              const SizedBox(height: 10),
              // Delete Account Button
              ElevatedButton(
                onPressed: () {
                  _showDeleteConfirmationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Delete Account", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Text Field Widget
  Widget buildTextField(String label, TextEditingController controller, {bool isEditable = true}) {
    return TextField(
      controller: controller,
      readOnly: !isEditable,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
