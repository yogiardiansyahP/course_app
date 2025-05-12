import 'package:flutter/material.dart';
import 'package:project_akhir_app/dashboard_user.dart';
// import 'package:project_akhir_app/tentang_kami.dart';
import 'package:project_akhir_app/profil.dart';
import 'package:project_akhir_app/login.dart';
import 'package:project_akhir_app/hubungi_kami.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const CourseListPage(),
        '/profil': (context) => ProfilScreen(),
        // '/tentang': (context) => const TentangScreen(),
        '/hubungi': (context) => const HubungiKamiPage(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');  // Fetch token from shared preferences

    if (token != null) {
      // If token exists, navigate to the dashboard
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // If no token, navigate to login screen
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'CodeIn Course',
              style: TextStyle(
                fontSize: 24,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ilmu Tumbuh, Karier Melaju',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
