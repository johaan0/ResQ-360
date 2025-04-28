import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main_layout.dart';

class HelplineUserPage extends StatefulWidget {
  @override
  _HelplineUserPageState createState() => _HelplineUserPageState();
}

class _HelplineUserPageState extends State<HelplineUserPage> {
  Map<String, String> helplines = {};
  Map<String, String> filteredHelplines = {};
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchHelplines();
    _searchController.addListener(_filterHelplines);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void fetchHelplines() async {
    final doc = await FirebaseFirestore.instance
        .collection('helpline_numbers')
        .doc('emergency')
        .get();
    if (doc.exists) {
      setState(() {
        helplines = Map<String, String>.from(doc.data()!);
        filteredHelplines = helplines;
      });
    }
  }

  void _filterHelplines() {
  final query = _searchController.text.toLowerCase();
  setState(() {
    filteredHelplines = Map.fromEntries(
      helplines.entries.where((entry) {
        return entry.key.toLowerCase().contains(query) ||
               entry.value.toLowerCase().contains(query);
      }),
    );
  });
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
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF833ab4), Color(0xFFfd1d1d), Color(0xFFfcb045)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search helplines...',
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: filteredHelplines.isEmpty
                    ? Center(child: CircularProgressIndicator(color: Colors.white))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: filteredHelplines.length,
                        itemBuilder: (context, index) {
                          final purpose = filteredHelplines.keys.elementAt(index);
                          final number = filteredHelplines[purpose]!;

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
            ],
          ),
        ),
      ),
    );
  }
}
