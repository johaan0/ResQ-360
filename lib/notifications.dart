import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  final List<Map<String, String>> notifications = const [
    {
      "title": "🚨 Emergency Alert",
      "body": "A user nearby needs medical assistance!"
    },
    {
      "title": "🔥 Fire Warning",
      "body": "Potential fire hazard detected in the area."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
              title: Text(notif['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(notif['body'] ?? ''),
            ),
          );
        },
      ),
    );
  }
}


