import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_application_1/User/about.dart';
import 'package:flutter_application_1/Places/help_line.dart';
import 'package:flutter_application_1/Places/police.dart';
import 'package:flutter_application_1/Places/hospital.dart';
import 'package:flutter_application_1/User/request_support.dart';
import 'package:flutter_application_1/User/user_requests_screen.dart';
import 'package:flutter_application_1/volunteer/volunteer_registration.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../main_layout.dart';
import 'location.dart';
import 'sos.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<bool> _isVisible = List.generate(10, (_) => false);
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> imagePaths = [
    'assets/poster1.png',
    'assets/poster2.png',
    'assets/poster3.png',
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_pageController.page!.round() + 1) % imagePaths.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.run_circle_rounded, 'label': "Request Volunteer Support"},
      {'icon': Icons.check_circle_outline_rounded, 'label': "Requested Supports"},
      {'icon': Icons.phone, 'label': "HelpLine"},
      {'icon': Icons.local_hospital, 'label': "Medical"},
      {'icon': Icons.local_police, 'label': "Police"},
      {'icon': Icons.volunteer_activism, 'label': "Become a Volunteer"},
      {'icon': Icons.location_pin, 'label': "Location"},
      {'icon': Icons.sos, 'label': "SOS"},
      {'icon': Icons.help, 'label': "About"},
    ];

    return MainLayout(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              VisibilityDetector(
                key: const Key("carousel_card"),
                onVisibilityChanged: (visibilityInfo) {
                  if (visibilityInfo.visibleFraction > 0.1) {
                    setState(() {
                      _isVisible[0] = true;
                    });
                  }
                },
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _isVisible[0] ? 1.0 : 0.0,
                  child: _buildImageCarouselCard(),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(items.length, (index) {
                final buttonIndex = index + 1;
                return VisibilityDetector(
                  key: Key("item_$index"),
                  onVisibilityChanged: (visibilityInfo) {
                    if (visibilityInfo.visibleFraction > 0.1) {
                      setState(() {
                        _isVisible[buttonIndex] = true;
                      });
                    }
                  },
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: _isVisible[buttonIndex] ? 1.0 : 0.0,
                    child: _buildEmergencyButton(
                      items[index]['icon'] as IconData,
                      items[index]['label'] as String,
                      buttonIndex,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

 Widget _buildImageCarouselCard() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias, // Ensures the image is clipped within the card shape
    child: SizedBox(
      height: 200,
      child: PageView.builder(
        controller: _pageController,
        itemCount: imagePaths.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          return Image.asset(
            imagePaths[index],
            fit: BoxFit.cover,
            width: double.infinity,
          );
        },
      ),
    ),
  );
}



  Widget _buildEmergencyButton(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();

        if (label == "Location") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserLocationMap()));
        }
        if (label == "SOS") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SOSPage()));
        }
        if (label == "Request Volunteer Support") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => RequestSupportPage()));
        }
        if (label == "HelpLine") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HelplineUserPage()));
        }
        if (label == "Medical") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NearbyHospitalsPage()));
        }
        if (label == "Become a Volunteer") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => VolunteerRegistrationPage()));
        }
        if (label == "About") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
        }
        if (label == "Police") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NearbyPoliceStationsPage()));
        }
        if (label == "Requested Supports") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserRequestsScreen()));
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 6,
        shadowColor: Colors.black38,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFF56040)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, size: 48, color: Colors.white)
                  .animate(target: _isVisible[index] ? 1 : 0)
                  .scale(delay: 200.ms, duration: 500.ms)
                  .shake(hz: 3, curve: Curves.easeInOut),
              const SizedBox(width: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ).animate(target: _isVisible[index] ? 1 : 0)
                  .fadeIn(delay: 300.ms, duration: 500.ms),
            ],
          ),
        ),
      ).animate(target: _isVisible[index] ? 1 : 0).slide(
            begin: index.isEven ? const Offset(-1.5, 0) : const Offset(1.5, 0),
            duration: 600.ms,
            curve: Curves.easeOut,
          ),
    );
  }
}
