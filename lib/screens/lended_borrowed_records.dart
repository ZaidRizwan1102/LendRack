import 'package:flutter/material.dart';
import 'package:wallet/models/record_model.dart';
import 'package:wallet/screens/activity.dart';
import 'package:wallet/services/database_service.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/activity_dismissible.dart';
import 'package:wallet/widgets/record_row.dart';

class LendedBorrowedRecords extends StatelessWidget {
  final bool isBorrowed;

  const LendedBorrowedRecords({super.key, required this.isBorrowed});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final move = AppHandler(context);
    final title = isBorrowed ? "Borrowed Records" : "Lended Records";

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER BAR
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.widthPerc(2),
                vertical: size.heightPerc(1),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => move.goBack(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: size.widthPerc(12)),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.heightPerc(2)),

            // LOCAL OFFLINE STREAMED RECORDS
            Expanded(
              child: StreamBuilder<List<RecordModel>>(
                stream: DatabaseService().getRecords(),
                initialData: DatabaseService().currentRecords,
                builder: (context, snapshot) {
                  final records = snapshot.data ?? [];

                  // Filter for Lended or Borrowed records
                  final filteredRecords = records.where((record) {
                    final bool isRecordLended = record.type == 'lending';
                    return isBorrowed ? !isRecordLended : isRecordLended;
                  }).toList();

                  if (filteredRecords.isEmpty) {
                    return _buildEmptyState(context, size, title);
                  }

                  // Convert RecordModels to ActivityItems
                  final items = filteredRecords
                      .map((record) => ActivityItem.fromRecord(record))
                      .toList();

                  return SingleChildScrollView(
                    child: Center(
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
                          children: items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final isLast = index == items.length - 1;

                            return Column(
                              children: [
                                ActivityDismissible(
                                  item: item,
                                  onDelete: () {
                                    DatabaseService().deleteRecord(item.id);
                                  },
                                  child: RecordRow(
                                    item: item,
                                    onUpdate: (updatedItem) {},
                                    onDelete: () {
                                      DatabaseService().deleteRecord(item.id);
                                    },
                                  ),
                                ),
                                if (!isLast)
                                  Divider(
                                    height: size.widthPerc(1),
                                    indent: size.widthPerc(4),
                                    endIndent: size.widthPerc(4),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Responsive size, String title) {
    return Center(
      child: Container(
        width: size.widthPerc(85),
        padding: EdgeInsets.all(size.widthPerc(8)),
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
            Icon(
              Icons.receipt_long_outlined,
              size: size.widthPerc(12),
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            SizedBox(height: size.heightPerc(1)),
            Text(
              "No $title found",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
