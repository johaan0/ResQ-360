import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendHelpRequest() async {
  final url = Uri.parse("https://resq360-backend.onrender.com/send_notification");


  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "title": "🚨 Emergency Alert",
      "body": "A user nearby needs your help!"
    }),
  );

  if (response.statusCode == 200) {
    print("Notification sent!");
  } else {
    print("Failed: ${response.body}");
  }
}

