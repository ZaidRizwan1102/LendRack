import 'package:flutter/material.dart';
import 'package:wallet/models/record_model.dart';
import 'package:wallet/screens/person_record.dart';
import 'package:wallet/services/database_service.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';

// Data model for calculated Person Summary
class PersonSummary {
  final String name;
  final double netBalance; // positive = owes you, negative = you owe

  PersonSummary({required this.name, required this.netBalance});
}

class PeopleOverview extends StatelessWidget {
  const PeopleOverview({super.key});

  // Empty state container builder
  Widget _buildEmptyState(BuildContext context, Responsive size) {
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: size.widthPerc(12),
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            SizedBox(height: size.heightPerc(1)),
            Text(
              "No one to be found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final move = AppHandler(context);

    return StreamBuilder<List<RecordModel>>(
      stream: DatabaseService().getRecords(),
      initialData: DatabaseService().currentRecords,
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];

        if (records.isEmpty) {
          return _buildEmptyState(context, size);
        }

        // Process local offline records and aggregate balances per person
        final Map<String, double> balanceMap = {};

        for (var record in records) {
          final personName = record.contactName.trim();
          if (personName.isEmpty) continue;

          final type = record.type.trim().toLowerCase();
          final bool isLended = type == 'lending' || type == 'lend';
          final double amount = record.amount;

          final change = isLended ? amount : -amount;
          balanceMap[personName] = (balanceMap[personName] ?? 0) + change;
        }

        // Return Empty State if no valid names exist in records
        if (balanceMap.isEmpty) {
          return _buildEmptyState(context, size);
        }

        final people = balanceMap.entries
            .map(
              (entry) =>
                  PersonSummary(name: entry.key, netBalance: entry.value),
            )
            .toList();

        return Center(
          child: Container(
            width: size.widthPerc(85),
            clipBehavior: Clip.antiAlias,
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
              children: people.asMap().entries.map((entry) {
                final index = entry.key;
                final person = entry.value;
                final isLast = index == people.length - 1;
                final owesYou = person.netBalance >= 0;

                return Column(
                  children: [
                    InkWell(
                      onTap: () {
                        // TODO: Navigate to individual ledger history page
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: size.widthPerc(4),
                          vertical: size.heightPerc(0.5),
                        ),
                        leading: Container(
                          width: size.widthPerc(10),
                          height: size.widthPerc(10),
                          decoration: BoxDecoration(
                            color: owesYou
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              person.name.isNotEmpty
                                  ? person.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: owesYou
                                    ? Colors.green.shade800
                                    : Colors.red.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          person.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Text(
                          owesYou ? "Owes you" : "You owe",
                          style: TextStyle(
                            fontSize: 17,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${person.netBalance.abs().toStringAsFixed(2)}',
                              style: TextStyle(
                                color: owesYou
                                    ? Colors.green.shade700
                                    : Colors.red.shade600,
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: size.widthPerc(1)),
                            IconButton(
                              onPressed: () {
                                move.toPage(PersonRecords(personName: person.name));
                              },
                              icon: const Icon(Icons.chevron_right_rounded),
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: size.widthPerc(2),
                        indent: size.widthPerc(6),
                        endIndent: size.widthPerc(6),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}