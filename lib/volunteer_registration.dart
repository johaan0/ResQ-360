import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VolunteerRegistrationPage extends StatefulWidget {
  const VolunteerRegistrationPage({super.key});

  @override
  _VolunteerRegistrationPageState createState() => _VolunteerRegistrationPageState();
}

class _VolunteerRegistrationPageState extends State<VolunteerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  File? _kycFile;
  String? selectedRole;
  final List<String> volunteerRoles = [
    "Logistics",
    "Food Assistance",
    "Medical Support",
    "Emergency Rescue",
    "Shelter Management",
    "Other"
  ];

  Future<void> _pickKycDocument() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _kycFile = File(pickedFile.path);
      });
    }
  }

  void _showVolunteerDutiesPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Volunteer Duties", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(
            "Thank you for registering! As a volunteer, you will be responsible for assisting in emergency situations based on your chosen role. Be prepared to respond swiftly and coordinate with emergency teams for effective relief efforts.",
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Got it", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _kycFile != null) {
      _showVolunteerDutiesPopup();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteer Registration"),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Full Name", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextFormField(
                  validator: (value) => value!.isEmpty ? "Enter your name" : null,
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
                SizedBox(height: 10),
                
                Text("Volunteer Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownSearch<String>(
                  items: volunteerRoles,
                  popupProps: PopupProps.menu(),
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(border: OutlineInputBorder()),
                  ),
                  onChanged: (value) => selectedRole = value,
                  selectedItem: "Select a role",
                ),
                SizedBox(height: 10),

                Text("Upload KYC Document (Government ID)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickKycDocument,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text("Choose File", style: TextStyle(color: Colors.white)),
                    ),
                    SizedBox(width: 10),
                    _kycFile != null ? Text("File Selected") : Text("No File Chosen"),
                  ],
                ),
                SizedBox(height: 20),
                
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: Text("Register", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
