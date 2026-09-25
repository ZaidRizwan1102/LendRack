import 'package:flutter/material.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/main_layout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache image to prevent any rendering flicker on launch
    precacheImage(const AssetImage('assets/images/logo_dark.png'), context);
  }

  Future<void> _initializeApp() async {
    // 1. Perform initialization tasks
    await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      // _fetchUserData(),
      // _loadSettings(),
    ]);

    // 2. Ensure widget is still mounted before using BuildContext
    if (!mounted) return;

    // 3. Initialize handler and navigate with fresh context
    final handler = AppHandler(context);
    handler.toPage(const MainLayout());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Image.asset(
          isDark 
          ? 'assets/images/logo_dark.png'  // Logo for dark mode (e.g., white text)
          : 'assets/images/logo_light.png',
          width: 160,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
