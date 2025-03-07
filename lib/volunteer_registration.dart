import 'package:flutter/material.dart';
import 'main_layout.dart';

class VolunteerRegistrationPage extends StatefulWidget {
  const VolunteerRegistrationPage({super.key});

  @override
  _VolunteerRegistrationPageState createState() =>
      _VolunteerRegistrationPageState();
}

class _VolunteerRegistrationPageState extends State<VolunteerRegistrationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? selectedRole;
  
  final List<String> volunteerRoles = [
    "Emergency Response",
    "Logistics Support",
    "Food & Water Distribution",
    "Medical Assistance",
    "Shelter Management",
    "Rescue Operations"
  ];

  void _showVolunteerResponsibilities() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Volunteer Responsibilities",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            "As a volunteer, you will be assisting in emergency response, logistics, food distribution, medical support, and rescue operations. "
            "Your efforts will help save lives and provide aid to those in need.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Got it",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF833AB4).withOpacity(0.5), // Instagram theme
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Volunteer Registration",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),

              // Full Name Input
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Full Name",
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 15),

              // Phone Number Input
              TextField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 15),

              // Role Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white70),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: Colors.black,
                    value: selectedRole,
                    hint: const Text(
                      "Select Role",
                      style: TextStyle(color: Colors.white70),
                    ),
                    items: volunteerRoles.map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(
                          role,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Registration Submitted!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _showVolunteerResponsibilities();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Submit",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

