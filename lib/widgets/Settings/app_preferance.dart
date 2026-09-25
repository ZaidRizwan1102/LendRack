import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/main.dart';
import 'package:wallet/services/currency_service.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/currency_dropdown.dart';

class AppPreferance extends StatefulWidget {
  const AppPreferance({super.key});

  @override
  State<AppPreferance> createState() => _AppPreferanceState();
}

class _AppPreferanceState extends State<AppPreferance> {
  @override
  void initState() {
    super.initState();
    CurrencyService.loadUserCurrency();
  }

  Future<void> _saveThemePreference(bool isDark) async {
    // 1. Instant local disk save
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);

    // 2. Cloud sync to Firestore
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'isDarkMode': isDark,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving theme preference to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return Container(
      width: size.widthPerc(85),
      constraints: BoxConstraints(minHeight: size.heightPerc(13.5)),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(size.widthPerc(3)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: size.widthPerc(0.2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: size.widthPerc(4)),
            leading: Icon(Icons.mode_night_outlined, size: size.widthPerc(6)),
            title: const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "Dark Mode / Theme",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
            trailing: ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, currentMode, child) {
                final isDarkMode = currentMode == ThemeMode.dark;

                return Switch.adaptive(
                  value: isDarkMode,
                  onChanged: (bool newVal) {
                    themeNotifier.value = newVal
                        ? ThemeMode.dark
                        : ThemeMode.light;
                    _saveThemePreference(newVal);
                  },
                );
              },
            ),
          ),
          Divider(
            height: 1,
            indent: size.widthPerc(5),
            endIndent: size.widthPerc(5),
            thickness: 1,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: size.widthPerc(4)),
            leading: Icon(
              Icons.attach_money_rounded,
              size: size.widthPerc(6.5),
            ),
            title: const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "Currency",
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
            trailing: CurrencyDropdown(
              selectedCurrency: CurrencyService.selectedCurrency,
              onChanged: (newValue) {
                if (newValue != null) {
                  CurrencyService.updateCurrency(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}