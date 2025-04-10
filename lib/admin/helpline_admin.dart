import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HelplineEditorPage extends StatefulWidget {
  @override
  _HelplineEditorPageState createState() => _HelplineEditorPageState();
}

class _HelplineEditorPageState extends State<HelplineEditorPage> {
  List<Map<String, String>> helplines = [];

  final docRef =
      FirebaseFirestore.instance.collection('helpline_numbers').doc('emergency');

  @override
  void initState() {
    super.initState();
    fetchHelplines();
  }

  void fetchHelplines() async {
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      setState(() {
        helplines = data.entries
            .map((entry) => {"purpose": entry.key, "number": entry.value.toString()})
            .toList();
      });
    }
  }

  void saveHelplines() async {
    Map<String, String> dataToSave = {
      for (var item in helplines)
        if (item['purpose']!.trim().isNotEmpty && item['number']!.trim().isNotEmpty)
          item['purpose']!: item['number']!,
    };

    await docRef.set(dataToSave);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Helpline numbers updated successfully!')),
    );
  }

  void addNewHelpline() {
    setState(() {
      helplines.add({"purpose": "", "number": ""});
    });
  }

  void deleteHelpline(int index) {
    setState(() {
      helplines.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Helpline Numbers'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveHelplines,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: helplines.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: helplines[index]['purpose'],
                    decoration: InputDecoration(labelText: 'Purpose'),
                    onChanged: (val) => helplines[index]['purpose'] = val,
                  ),
                  TextFormField(
                    initialValue: helplines[index]['number'],
                    decoration: InputDecoration(labelText: 'Number'),
                    keyboardType: TextInputType.phone,
                    onChanged: (val) => helplines[index]['number'] = val,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => deleteHelpline(index),
                      icon: Icon(Icons.delete, color: Colors.red),
                      label: Text('Remove', style: TextStyle(color: Colors.red)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addNewHelpline,
        icon: Icon(Icons.add),
        label: Text('Add New'),
      ),
    );
  }
}
