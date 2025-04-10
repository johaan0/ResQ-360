import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/about.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/launch.dart';
import 'package:flutter_application_1/notifications.dart';
import 'package:flutter_application_1/sos.dart';
import 'package:flutter_application_1/volunteer_registration.dart';
import 'firebase_options.dart'; // Ensure this file is generated using `flutterfire configure`
import 'login.dart'; // Import your login page
import 'profile.dart';
import 'location.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();



void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensures Flutter is initialized before Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ask for notification permission (important for iOS, optional but useful for Android 13+)
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Optional: subscribe to a topic
  await messaging.subscribeToTopic('volunteers');

  // Background notification tap handling
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Tapped Notification: ${message.notification?.title}');
    // Navigate to notifications page
    navigatorKey.currentState?.pushNamed('/notifications');
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, 
      debugShowCheckedModeBanner: false,
      title: 'ResQ 360',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 32, 96, 206),
        ),
        useMaterial3: true,
        fontFamily: 'Bebas',
      ),
      initialRoute: '/', // Define the initial route
      routes: {
        '/': (context) => const LaunchPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/sos': (context) => SOSPage(),
        '/volunteer_registration': (context) => VolunteerRegistrationPage(),
        '/profile': (context) => ProfilePage(),
        '/about': (context) => AboutPage(),
        '/location': (context) => UserLocationMap(),
        '/notifications':(context)=>NotificationsPage()
      },
    );
  }
}
