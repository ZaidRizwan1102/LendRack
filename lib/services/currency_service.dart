import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static ValueNotifier<String> selectedCurrency = ValueNotifier<String>('PKR (Rs)');

  static const List<String> currencies = [
    'PKR (Rs)',
    'USD (\$)',
    'EUR (€)',
    'GBP (£)',
    'INR (₹)',
    'CAD (C\$)',
    'CNY (¥)',
    'AED (AED)',
    'SAR (SAR)',
    'AUD (A\$)',
    'JPY (¥)',
  ];

  // Fallback rates relative to 1 USD
  static Map<String, double> _rates = {
    'USD': 1.0,
    'PKR': 278.5,
    'EUR': 0.92,
    'GBP': 0.78,
    'INR': 83.2,
    'CAD': 1.36,
    'CNY': 7.23,
    'AED': 3.67,
    'SAR': 3.75,
    'AUD': 1.51,
    'JPY': 155.0,
  };

  // Fetch live exchange rates (No API Key Required)
  static Future<void> fetchExchangeRates() async {
    try {
      final response = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/USD'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == 'success' && data['rates'] != null) {
          final Map<String, dynamic> rawRates = data['rates'];
          _rates = rawRates.map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          );
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch live currency rates, using cached/fallback: $e");
    }
  }

  // Load stored currency & fetch live exchange rates
  static Future<void> loadUserCurrency() async {
    // 1. Fetch live rates in background
    fetchExchangeRates();

    // 2. Load preferred currency
    final prefs = await SharedPreferences.getInstance();
    final localCurrency = prefs.getString('userCurrency');

    if (localCurrency != null && currencies.contains(localCurrency)) {
      selectedCurrency.value = localCurrency;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists && doc.data()?.containsKey('currency') == true) {
        final remoteCurrency = doc.data()?['currency'] as String?;
        if (remoteCurrency != null && currencies.contains(remoteCurrency)) {
          selectedCurrency.value = remoteCurrency;
          await prefs.setString('userCurrency', remoteCurrency);
        }
      }
    } catch (e) {
      debugPrint("Error loading currency preference: $e");
    }
  }

  static Future<void> updateCurrency(String newCurrency) async {
    if (!currencies.contains(newCurrency)) return;

    selectedCurrency.value = newCurrency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userCurrency', newCurrency);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'currency': newCurrency,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating currency: $e");
    }
  }

  // Extract ISO Code (e.g. "PKR (Rs)" -> "PKR")
  static String getIsoCode(String currencyString) {
    return currencyString.split(' ').first;
  }

  // Extract Symbol (e.g. "USD ($)" -> "$")
  static String getSymbol(String currencyString) {
    if (currencyString.contains('(') && currencyString.contains(')')) {
      return currencyString.substring(
        currencyString.indexOf('(') + 1,
        currencyString.indexOf(')'),
      );
    }
    return 'Rs';
  }

  /// Math Conversion: Converts [amount] from [fromCurrency] to [toCurrency]
  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    final fromCode = getIsoCode(fromCurrency);
    final toCode = getIsoCode(toCurrency);

    final fromRate = _rates[fromCode] ?? 1.0;
    final toRate = _rates[toCode] ?? 1.0;

    // Convert to USD base first, then convert to target currency
    final amountInUSD = amount / fromRate;
    return amountInUSD * toRate;
  }

  // Format amount string using active target currency
  static String formatAmount(
    double rawAmount, {
    String? targetCurrency,
    String baseCurrency = 'PKR (Rs)', // Original currency stored in DB
  }) {
    final activeCurrency = targetCurrency ?? selectedCurrency.value;
    
    // Calculate actual converted value
    final convertedValue = convert(
      amount: rawAmount,
      fromCurrency: baseCurrency,
      toCurrency: activeCurrency,
    );

    final symbol = getSymbol(activeCurrency);
    final formattedNum = convertedValue % 1 == 0
        ? convertedValue.toInt().toString()
        : convertedValue.toStringAsFixed(2);

    return '$symbol $formattedNum';
  }
}