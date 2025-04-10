import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/animation.dart';
import 'push_notification_service.dart';
import 'main_layout.dart';

class RequestSupportPage extends StatefulWidget {
  const RequestSupportPage({super.key});

  @override
  State<RequestSupportPage> createState() => _RequestSupportPageState();
}

class _RequestSupportPageState extends State<RequestSupportPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _selectedSupport = "Emergency Response";
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  final List<String> supportOptions = [
    "Emergency Response",
    "Logistics Support",
    "Food & Water Distribution",
    "Medical Assistance",
    "Shelter Management",
    "Rescue Operations"
  ];

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideAnimation = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = doc.data() ?? {};

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      await FirebaseFirestore.instance.collection("help_request").add({
        "type_of_support": _selectedSupport,
        "description": _descriptionController.text.trim(),
        "assigned_volunteer": null,
        "location": {
          "latitude": position.latitude,
          "longitude": position.longitude,
        },
        "status": "not fulfilled",
        "username": userData['name'],
        "email": user.email ?? "No Email",
        "timestamp": FieldValue.serverTimestamp(),
      });

      await sendHelpRequest();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request submitted and notification sent!")),
      );

      _descriptionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
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
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8), // Semi-transparent
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Request Volunteer Support",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Support Type Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: DropdownButtonFormField<String>(
                          value: _selectedSupport,
                          decoration: const InputDecoration(border: InputBorder.none, labelText: "Type of Support"),
                          items: supportOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
                          onChanged: (value) => setState(() => _selectedSupport = value!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Description Box
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: "Description",
                          ),
                          maxLines: 4,
                          validator: (value) => value!.isEmpty ? "Description required" : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Request Volunteer", style: TextStyle(color: Colors.white)),
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
