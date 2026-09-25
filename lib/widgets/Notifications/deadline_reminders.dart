import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet/services/notification_service.dart';
import 'package:wallet/utils/responsive.dart';

class DeadlineReminders extends StatelessWidget {
  const DeadlineReminders({super.key});

  final List<int> _numbers = const [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
  ];

  final List<String> _deadlineUnits = const [
    "Days before",
    "Weeks before",
    "Months before",
  ];

  final List<String> _noDeadlineUnits = const [
    "Days",
    "Weeks",
    "Months",
  ];

  Future<void> _updateSetting(
    String sectionKey,
    String field,
    dynamic value,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      await docRef.update({'deadlineReminders.$sectionKey.$field': value});
    } catch (e) {
      await docRef.set({
        'deadlineReminders': {
          sectionKey: {field: value},
        },
      }, SetOptions(merge: true));
    }

    // Sync notification schedules after updating global reminder settings
    await NotificationService().syncAllNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    const headingStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 20);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userId != null
          ? FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        Map<String, dynamic>? data;
        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final docData = snapshot.data!.data();
          if (docData != null && docData.containsKey('deadlineReminders')) {
            data = docData['deadlineReminders'] as Map<String, dynamic>?;
          }
        }

        // 1. Lended State (Defaults to false)
        final lended = data?['lended'] as Map<String, dynamic>?;
        final bool lendedEnabled = lended?['enabled'] as bool? ?? false;
        final int lendedNumber = (lended?['number'] as num?)?.toInt() ?? 3;
        final String lendedUnit = (lended?['unit'] as String?) ?? "Days before";

        // 2. Borrowed State (Defaults to false)
        final borrowed = data?['borrowed'] as Map<String, dynamic>?;
        final bool borrowedEnabled = borrowed?['enabled'] as bool? ?? false;
        final int borrowedNumber = (borrowed?['number'] as num?)?.toInt() ?? 3;
        final String borrowedUnit =
            (borrowed?['unit'] as String?) ?? "Days before";

        // 3. No Deadline State (Defaults to false)
        final noDeadline = data?['noDeadline'] as Map<String, dynamic>?;
        final bool noDeadlineEnabled = noDeadline?['enabled'] as bool? ?? false;
        final int noDeadlineNumber =
            (noDeadline?['number'] as num?)?.toInt() ?? 2;
        final String noDeadlineUnit =
            (noDeadline?['unit'] as String?) ?? "Weeks";

        return Container(
          width: size.widthPerc(85),
          padding: EdgeInsets.all(size.widthPerc(4.5)),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Deadline Reminders", style: headingStyle),
              SizedBox(height: size.heightPerc(1)),
              Divider(
                color: Theme.of(context).textTheme.bodySmall?.color,
                thickness: 1,
              ),
              SizedBox(height: size.heightPerc(1.5)),

              // 1. Lended Deadlines Section
              _buildReminderSection(
                context: context,
                title: "Lended Deadlines",
                subtitle: "Notify me before someone needs to pay me.",
                headingStyle: headingStyle,
                isEnabled: lendedEnabled,
                onToggle: (val) => _updateSetting('lended', 'enabled', val),
                label: "Remind me",
                selectedNumber: lendedNumber,
                onNumberChanged: (val) {
                  if (val != null) _updateSetting('lended', 'number', val);
                },
                selectedUnit: lendedUnit,
                unitOptions: _deadlineUnits,
                onUnitChanged: (val) {
                  if (val != null) _updateSetting('lended', 'unit', val);
                },
                size: size,
              ),

              Divider(
                color: Theme.of(context).textTheme.bodySmall?.color,
                thickness: 1,
              ),
              SizedBox(height: size.heightPerc(1.5)),

              // 2. Borrowed Deadlines Section
              _buildReminderSection(
                context: context,
                title: "Borrowed Deadlines",
                subtitle: "Notify me before I need to pay someone.",
                headingStyle: headingStyle,
                isEnabled: borrowedEnabled,
                onToggle: (val) => _updateSetting('borrowed', 'enabled', val),
                label: "Remind me",
                selectedNumber: borrowedNumber,
                onNumberChanged: (val) {
                  if (val != null) _updateSetting('borrowed', 'number', val);
                },
                selectedUnit: borrowedUnit,
                unitOptions: _deadlineUnits,
                onUnitChanged: (val) {
                  if (val != null) _updateSetting('borrowed', 'unit', val);
                },
                size: size,
              ),

              Divider(
                color: Theme.of(context).textTheme.bodySmall?.color,
                thickness: 1,
              ),
              SizedBox(height: size.heightPerc(1.5)),

              // 3. Records with No Deadline Section
              _buildReminderSection(
                context: context,
                title: "Records with no deadline",
                subtitle: "Periodic check-ins for open debts.",
                headingStyle: headingStyle,
                isEnabled: noDeadlineEnabled,
                onToggle: (val) => _updateSetting('noDeadline', 'enabled', val),
                label: "Remind me every",
                selectedNumber: noDeadlineNumber,
                onNumberChanged: (val) {
                  if (val != null) _updateSetting('noDeadline', 'number', val);
                },
                selectedUnit: noDeadlineUnit,
                unitOptions: _noDeadlineUnits,
                onUnitChanged: (val) {
                  if (val != null) _updateSetting('noDeadline', 'unit', val);
                },
                size: size,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required TextStyle headingStyle,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    required String label,
    required int selectedNumber,
    required ValueChanged<int?> onNumberChanged,
    required String selectedUnit,
    required List<String> unitOptions,
    required ValueChanged<String?> onUnitChanged,
    required Responsive size,
  }) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: headingStyle.copyWith(fontSize: 18)),
                  SizedBox(height: size.heightPerc(0.4)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(value: isEnabled, onChanged: onToggle),
          ],
        ),

        if (isEnabled) ...[
          SizedBox(height: size.heightPerc(1.5)),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: size.widthPerc(2),
            runSpacing: size.heightPerc(1),
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              _buildDropdownContainer(
                context: context,
                child: DropdownButton<int>(
                  value: _numbers.contains(selectedNumber)
                      ? selectedNumber
                      : _numbers[0],
                  underline: const SizedBox(),
                  isDense: true,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  dropdownColor: Theme.of(context).cardColor,
                  items: _numbers.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        value.toString(),
                        style: TextStyle(color: textColor),
                      ),
                    );
                  }).toList(),
                  onChanged: onNumberChanged,
                ),
              ),
              _buildDropdownContainer(
                context: context,
                child: DropdownButton<String>(
                  value: unitOptions.contains(selectedUnit)
                      ? selectedUnit
                      : unitOptions[0],
                  underline: const SizedBox(),
                  isDense: true,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  dropdownColor: Theme.of(context).cardColor,
                  items: unitOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: textColor)),
                    );
                  }).toList(),
                  onChanged: onUnitChanged,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownContainer({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).shadowColor.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }
}