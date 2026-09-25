import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/services/auth.dart';
import 'package:wallet/services/currency_service.dart';
import 'package:wallet/services/notification_service.dart';
import 'package:wallet/utils/main_layout.dart';
import 'firebase_options.dart';

// Global notifier for application-wide theme switching
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Helper function to listen to theme changes in Firestore and update local storage
void setupThemeListener() {
  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((doc) async {
            if (doc.exists && doc.data() != null) {
              final data = doc.data()!;
              if (data.containsKey('isDarkMode')) {
                final bool isDark = data['isDarkMode'] as bool;
                
                // Update live state
                themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                
                // Keep local cache synced with cloud changes
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isDarkMode', isDark);
              }
            }
          });
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. READ LOCAL CACHE FIRST (Instant load before frame 1)
  final prefs = await SharedPreferences.getInstance();
  final bool savedIsDark = prefs.getBool('isDarkMode') ?? false; // Default to Light if clean install
  themeNotifier.value = savedIsDark ? ThemeMode.dark : ThemeMode.light;

  // 2. Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase already initialized natively: $e");
  }

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  try {
    await AuthService().initializeAuth();
  } catch (e) {
    debugPrint("Offline startup notice (Auth initialization): $e");
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // 3. Start remote Firestore listener for cloud sync
  setupThemeListener();
  await CurrencyService.loadUserCurrency();
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // ================= LIGHT THEME =================
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8F8FF),
            cardColor: Colors.white,
            shadowColor: Colors.black.withValues(alpha: 1),

            colorScheme: const ColorScheme.light(
              primary: Color(0xFF001540),
              secondary: Color(0xFF047857),
              surface: Colors.white,
              error: Color(0xFFB91C1C),
              errorContainer: Color(0xFFEF4444),
              tertiary: Color(0xFF047857),
              tertiaryContainer: Color(0xFF10B981),
            ),

            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return Colors.blueGrey;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF001540);
                }
                return Colors.white;
              }),
              trackOutlineColor: WidgetStateProperty.all(Colors.blueGrey),
            ),

            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Color(0xFFECF6FF),
            ),
            textTheme: TextTheme(
              headlineSmall: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              bodyLarge: const TextStyle(color: Colors.black),
              bodyMedium: const TextStyle(color: Colors.black),
              bodySmall: TextStyle(color: Colors.black.withValues(alpha: 0.56)),
            ),
          ),

          // ================= DARK THEME (OLED & ORANGE ACCENT) =================
          darkTheme: ThemeData(
            useMaterial3: true, 
            scaffoldBackgroundColor: const Color(0xFF0b1014),
            cardColor: const Color(0xFF161E2E),
            shadowColor: Colors.white,

            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFFF6B00),
              secondary: Color(0xFF34D399),
              surface: Color(0xFF001540),
              error: Color(0xFFF87171),
              errorContainer: Color(0xFFEF4444),
              tertiary: Color(0xFF34D399),
              tertiaryContainer: Color(0xFF10B981),
            ),

            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.white;
                return Colors.grey.shade500;
              }),
              trackColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFFFF6B00);
                }
                return const Color(0xFF27272A);
              }),
              trackOutlineColor: WidgetStateProperty.all(Colors.white),
            ),

            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Color(0xFFECF6FF),
            ),
            textTheme: TextTheme(
              headlineSmall: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              bodyLarge: const TextStyle(color: Colors.white),
              bodyMedium: const TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white.withValues(alpha: 0.60)),
            ),
          ),

          home: const MainLayout(),
        );
      },
    );
  }
}