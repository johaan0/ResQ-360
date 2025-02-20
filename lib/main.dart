import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file is generated using `flutterfire configure`
import 'login.dart'; // Import your login page

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is initialized before Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQ 360',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 32, 96, 206),
        ),
        useMaterial3: true,
        fontFamily: 'Bebas',
      ),
      home: const LoginPage(),
    );
  }
}
