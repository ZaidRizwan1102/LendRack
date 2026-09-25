import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      tz_data.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(settings: settings);
      await _requestPermissions();
      _isInitialized = true;
    } catch (e) {
      debugPrint("Error initializing NotificationService: $e");
    }
  }

  Future<void> _requestPermissions() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      try {
        await androidImplementation.requestNotificationsPermission();
      } catch (_) {}

      try {
        await androidImplementation.requestExactAlarmsPermission();
      } catch (_) {}
    }
  }

  // Calculate reminder date limited strictly to Days, Weeks, and Months
  DateTime? _calculateReminderDate(
    DateTime baseDate,
    int number,
    String unit, {
    required bool isNoDeadline,
  }) {
    final Duration duration;
    
    switch (unit) {
      case "Weeks before":
      case "Weeks":
        duration = Duration(days: number * 7);
        break;
      case "Months before":
      case "Months":
        duration = Duration(days: number * 30);
        break;
      case "Days before":
      case "Days":
      default:
        duration = Duration(days: number);
        break;
    }

    // Records with no deadline ADD time to DateTime.now()
    // Records with a deadline SUBTRACT time from the target due date
    return isNoDeadline ? baseDate.add(duration) : baseDate.subtract(duration);
  }

  // Main method to evaluate rules and reschedule all notifications for current user
  Future<void> syncAllNotifications() async {
    if (!_isInitialized) {
      await init();
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Clear previous scheduled notifications safely
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint("Error clearing notifications: $e");
    }

    try {
      final db = FirebaseFirestore.instance;

      // 1. Fetch user document for global deadlineReminders settings
      final userDoc = await db.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};
      final globalReminders =
          userData['deadlineReminders'] as Map<String, dynamic>? ?? {};

      // 2. Fetch person-specific rules
      final personRulesSnapshot = await db
          .collection('users')
          .doc(userId)
          .collection('person_rules')
          .get();

      final List<Map<String, dynamic>> personRules = personRulesSnapshot.docs
          .map((d) => {...d.data(), 'id': d.id})
          .toList();

      // 3. Fetch all active (unsettled) records
      final recordsSnapshot =
          await db.collection('users').doc(userId).collection('records').get();

      for (var doc in recordsSnapshot.docs) {
        final record = doc.data();
        final isSettled = record['isSettled'] as bool? ?? false;
        if (isSettled) continue; // Skip completed debts

        final recordId = doc.id;
        final notificationId = recordId.hashCode.abs() % 2147483647;

        final personName = (record['personName'] ??
                record['person_name'] ??
                record['person'] ??
                record['name'] as String?)
            ?.trim();
        final recordType = (record['type'] as String?) ?? 'Lended'; // 'Lended' or 'Borrowed'
        final rawDueDate = record['dueDate'];

        DateTime? dueDate;
        if (rawDueDate is Timestamp) {
          dueDate = rawDueDate.toDate();
        } else if (rawDueDate is String) {
          dueDate = DateTime.tryParse(rawDueDate);
        }

        bool isEnabled = false;
        int number = 3;
        String unit = "Days before";

        // Check for active person-specific rule override
        Map<String, dynamic>? matchingPersonRule;
        if (personName != null && personName.isNotEmpty) {
          for (var rule in personRules) {
            final selectedPerson = rule['selectedPerson'] as String?;
            if (rule['isEnabled'] == true &&
                selectedPerson != null &&
                selectedPerson != "Select the Person" &&
                selectedPerson == personName) {
              final ruleType = rule['ruleType'] as String?;
              if ((dueDate != null &&
                      ((recordType == 'Lended' && ruleType == 'Lended Deadline') ||
                          (recordType == 'Borrowed' &&
                              ruleType == 'Borrowed Deadline'))) ||
                  (dueDate == null && ruleType == 'No deadline')) {
                matchingPersonRule = rule;
                break;
              }
            }
          }
        }

        if (matchingPersonRule != null) {
          isEnabled = matchingPersonRule['isEnabled'] ?? false;
          number = (matchingPersonRule['selectedNumber'] as num?)?.toInt() ?? 3;
          unit = matchingPersonRule['selectedUnit'] ?? "Days before";
        } else {
          // Fall back to Global Settings
          if (dueDate != null) {
            final key = recordType == 'Lended' ? 'lended' : 'borrowed';
            final globalSetting = globalReminders[key] as Map<String, dynamic>?;
            isEnabled = globalSetting?['enabled'] as bool? ?? false;
            number = (globalSetting?['number'] as num?)?.toInt() ?? 3;
            unit = globalSetting?['unit'] as String? ?? "Days before";
          } else {
            final globalSetting = globalReminders['noDeadline'] as Map<String, dynamic>?;
            isEnabled = globalSetting?['enabled'] as bool? ?? false;
            number = (globalSetting?['number'] as num?)?.toInt() ?? 2;
            unit = globalSetting?['unit'] as String? ?? "Weeks";
          }
        }

        if (!isEnabled) continue;

        final isNoDeadline = dueDate == null;
        final baseDate = dueDate ?? DateTime.now();
        final scheduledDate = _calculateReminderDate(
          baseDate,
          number,
          unit,
          isNoDeadline: isNoDeadline,
        );

        if (scheduledDate != null && scheduledDate.isAfter(DateTime.now())) {
          final amount = record['amount']?.toString() ?? '0';
          final title = recordType == 'Lended'
              ? 'Lended Payment Due: ${personName ?? "Contact"}'
              : 'Borrowed Payment Due: ${personName ?? "Contact"}';
          final body = recordType == 'Lended'
              ? '${personName ?? "Contact"} owes you \$$amount.'
              : 'You owe ${personName ?? "Contact"} \$$amount.';

          await _scheduleNotification(
            id: notificationId,
            title: title,
            body: body,
            scheduledDate: scheduledDate,
          );
        }
      }
    } catch (e) {
      debugPrint("Error syncing notifications: $e");
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      await _notifications.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'lendrack_deadlines',
            'Deadline Reminders',
            channelDescription: 'Notifications for lended and borrowed deadlines',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint("Error scheduling notification $id: $e");
    }
  }
}