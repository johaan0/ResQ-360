import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main_layout.dart';

class HelplineUserPage extends StatefulWidget {
  @override
  _HelplineUserPageState createState() => _HelplineUserPageState();
}

class _HelplineUserPageState extends State<HelplineUserPage> {
  Map<String, String> helplines = {};

  @override
  void initState() {
    super.initState();
    fetchHelplines();
  }

  void fetchHelplines() async {
    final doc = await FirebaseFirestore.instance
        .collection('helpline_numbers')
        .doc('emergency')
        .get();
    if (doc.exists) {
      setState(() {
        helplines = Map<String, String>.from(doc.data()!);
      });
    }
  }

  void _callNumber(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot launch dialer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      //title: "Helpline Numbers", // if your MainLayout supports it
      body: Padding(
        // <-- CHANGED from `child:` to `body:`
        padding: const EdgeInsets.all(0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF833ab4), Color(0xFFfd1d1d), Color(0xFFfcb045)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: helplines.isEmpty
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: helplines.length,
                  itemBuilder: (context, index) {
                    final purpose = helplines.keys.elementAt(index);
                    final number = helplines[purpose]!;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white.withOpacity(0.9),
                      margin: EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          purpose,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        subtitle: Text(
                          number,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.call, color: Colors.green),
                          onPressed: () => _callNumber(number),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
