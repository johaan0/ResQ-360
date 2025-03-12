import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_layout.dart';

class VolunteerRegistrationPage extends StatefulWidget {
  const VolunteerRegistrationPage({super.key});

  @override
  _VolunteerRegistrationPageState createState() => _VolunteerRegistrationPageState();
}

class _VolunteerRegistrationPageState extends State<VolunteerRegistrationPage> {
  bool consentGiven = false;
  String? selectedRole;
  String? selectedLocation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> volunteerRoles = [
    "Emergency Response",
    "Logistics Support",
    "Food & Water Distribution",
    "Medical Assistance",
    "Shelter Management",
    "Rescue Operations"
  ];

  final List<String> locations = [
    "Kasaragod", 
    "Kannur", 
    "Wayanad", 
    "Kozhikode",
    "Malappuram",
    "Palakkad", 
    "Thrissur", 
    "Ernakulam", 
    "Idukki",
    "Kottayam"
  ];

  Future<void> _registerVolunteer() async {
    if (!consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You must agree to the consent before registering."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedRole == null || selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required details."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Store volunteer details in Firestore
      await _firestore.collection('volunteers').add({
        'role': selectedRole,
        'location': selectedLocation,
        'volunteer': true, // Mark volunteer status as true
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You are now a registered volunteer!"),
          backgroundColor: Colors.green,
        ),
      );

      // Clear selections after successful registration
      setState(() {
        consentGiven = false;
        selectedRole = null;
        selectedLocation = null;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Registration failed: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
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
                      child: Text(
                        "Volunteer Registration",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
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
                      title: const Text(
                        "I have read and agree to the terms and conditions.",
                        style: TextStyle(color: Colors.black),
                      ),
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
                      dropdownColor: Colors.white,
                      value: selectedRole,
                      hint: const Text("Select Role", style: TextStyle(color: Colors.black54)),
                      items: volunteerRoles.map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role, style: const TextStyle(color: Colors.black)),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      dropdownColor: Colors.white,
                      value: selectedLocation,
                      hint: const Text("Select Location", style: TextStyle(color: Colors.black54)),
                      items: locations.map((loc) => DropdownMenuItem(
                        value: loc,
                        child: Text(loc, style: const TextStyle(color: Colors.black)),
                      )).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedLocation = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
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
