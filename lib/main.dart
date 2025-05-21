import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:project_akhir_app/dashboard_user.dart';
import 'package:project_akhir_app/kelas.dart';
import 'package:project_akhir_app/materi.dart';
import 'package:project_akhir_app/tentang_kami.dart';
import 'package:project_akhir_app/profil.dart';
import 'package:project_akhir_app/login.dart';
import 'package:project_akhir_app/hubungi_kami.dart';
import 'package:project_akhir_app/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iamport_webview_flutter/iamport_webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setUrlStrategy(PathUrlStrategy());
  setWebViewPlatform();
  runApp(const MyApp());
}

void setWebViewPlatform() {
  WebView.platform = SurfaceAndroidWebView();
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
        '/list-kelas': (context) => const TokenLoaderPage(),
        '/materi-kembali': (context) => const CourseListPage(),
        '/profil': (context) => ProfilScreen(),
        '/tentang': (context) => const TentangScreen(),
        '/hubungi': (context) => const HubungiKamiPage(),
        '/kelas': (context) => const KelasPage(),
        '/materi': (context) => const VideoLessonPage(
              courseName: '',
              title: '',
              description: '',
              videoUrl: '',
              hasAccess: false,
            ),
      },
    );
  }
}

class TokenLoaderPage extends StatefulWidget {
  const TokenLoaderPage({super.key});

  @override
  State<TokenLoaderPage> createState() => _TokenLoaderPageState();
}

class _TokenLoaderPageState extends State<TokenLoaderPage> {
  @override
  void initState() {
    super.initState();
    _loadTokenAndNavigate();
  }

  Future<void> _loadTokenAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CourseHomePage(token: token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
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
    final token = prefs.getString('token');

    if (token != null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
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
