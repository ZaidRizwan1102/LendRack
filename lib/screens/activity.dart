import 'package:flutter/material.dart';
import 'package:wallet/models/record_model.dart';
import 'package:wallet/services/database_service.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/activity_dismissible.dart';
import 'package:wallet/widgets/record_row.dart';
import 'package:wallet/widgets/custom_snackbar.dart';
import 'package:wallet/widgets/header.dart';

// View model for individual activity items
class ActivityItem {
  final String id;
  final String name;
  final String? description;
  final String amount;
  final bool isLended;
  final RecordModel rawRecord;

  ActivityItem({
    required this.id,
    required this.name,
    this.description,
    required this.amount,
    required this.isLended,
    required this.rawRecord,
  });

  factory ActivityItem.fromRecord(RecordModel record) {
    return ActivityItem(
      id: record.id ?? '',
      name: record.contactName,
      description: record.reason,
      amount: "\$${record.amount.toStringAsFixed(2)}",
      isLended: record.type == 'lending',
      rawRecord: record,
    );
  }
}

// Data model for grouped date sections
class ActivityGroup {
  final String dateTitle;
  final List<ActivityItem> items;

  ActivityGroup({required this.dateTitle, required this.items});
}

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity>
    with AutomaticKeepAliveClientMixin {
  // 1. Declare cached stream instance
  late final Stream<List<RecordModel>> _recordsStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 2. Instantiate stream ONCE when widget is mounted
    _recordsStream = DatabaseService().getRecords();
  }

  // Helper to format date headers ("TODAY", "YESTERDAY", or "10 JUN 2026")
  String _getGroupTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return "TODAY";
    if (checkDate == yesterday) return "YESTERDAY";

    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  // Groups records chronologically
  List<ActivityGroup> _groupRecords(List<RecordModel> records) {
    final Map<String, List<ActivityItem>> groupedMap = {};

    for (var record in records) {
      final title = _getGroupTitle(record.date);
      final item = ActivityItem.fromRecord(record);

      groupedMap.putIfAbsent(title, () => []).add(item);
    }

    return groupedMap.entries
        .map((entry) => ActivityGroup(dateTitle: entry.key, items: entry.value))
        .toList();
  }

  Future<void> _deleteActivityItem(ActivityItem item) async {
    if (item.id.isEmpty) return;

    try {
      await DatabaseService().deleteRecord(item.id);

      if (!mounted) return;

      CustomSnackBar.show(
        context,
        message: "${item.name}'s record deleted",
        actionLabel: "Undo",
        onAction: () async {
          await DatabaseService().addRecord(item.rawRecord);
        },
      );
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(context, message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = Responsive(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              SizedBox(height: size.heightPerc(2)),

              // Screen Title Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.widthPerc(7.5)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Activity",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.heightPerc(0.5)),
                    Text(
                      "Track your complete payment timeline",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.heightPerc(2)),

              // Firestore Real-time Stream
              StreamBuilder<List<RecordModel>>(
                stream: _recordsStream, // 3. Pass cached stream instance
                builder: (context, snapshot) {
                  // 4. Only show spinner on initial cold load before data exists
                  if (!snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.only(top: size.heightPerc(20)),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }

                  final records = snapshot.data ?? [];

                  if (records.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: size.heightPerc(20)),
                      child: Center(
                        child: Text(
                          "No Record Added Yet",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    );
                  }

                  final activityGroups = _groupRecords(records);

                  return Column(
                    children: activityGroups.map((group) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: size.widthPerc(7.5),
                              top: size.heightPerc(1.5),
                              bottom: size.heightPerc(1),
                            ),
                            child: Text(
                              group.dateTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              width: size.widthPerc(85),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(
                                  size.widthPerc(3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).shadowColor,
                                    blurRadius: size.widthPerc(0.2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: group.items.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  final isLast =
                                      index == group.items.length - 1;

                                  return Column(
                                    children: [
                                      ActivityDismissible(
                                        item: item,
                                        onDelete: () =>
                                            _deleteActivityItem(item),
                                        child: RecordRow(
                                          item: item,
                                          onUpdate: (updatedItem) {},
                                          onDelete: () =>
                                              _deleteActivityItem(item),
                                        ),
                                      ),
                                      if (!isLast)
                                        Divider(
                                          height: size.widthPerc(2),
                                          indent: size.widthPerc(6),
                                          endIndent: size.widthPerc(6),
                                          thickness: size.widthPerc(0.4),
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
              SizedBox(height: size.heightPerc(10)),
            ],
          ),
        ),
      ),
    );
  }
}
