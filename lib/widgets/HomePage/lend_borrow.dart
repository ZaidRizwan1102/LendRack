import 'package:flutter/material.dart';
import 'package:wallet/models/record_model.dart';
import 'package:wallet/screens/lended_borrowed_records.dart';
import 'package:wallet/services/currency_service.dart';
import 'package:wallet/services/database_service.dart';
import 'package:wallet/utils/responsive.dart';

class LendBorrow extends StatelessWidget {
  final bool isBorrowed;

  const LendBorrow({super.key, required this.isBorrowed});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    final accentColor = isBorrowed
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.errorContainer;

    final badgeBgColor = isBorrowed
        ? Colors.green.shade100
        : Colors.red.shade100;

    return Expanded(
      child: Container(
        height: size.widthPerc(34),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size.widthPerc(3)),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(width: size.widthPerc(2), color: accentColor),
              ),
            ),
            padding: EdgeInsets.all(size.widthPerc(3.5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(size.widthPerc(1.8)),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(size.widthPerc(2)),
                      ),
                      child: Icon(
                        isBorrowed
                            ? Icons.south_west_rounded
                            : Icons.north_east_rounded,
                        size: size.widthPerc(5),
                        color: accentColor,
                      ),
                    ),
                    SizedBox(width: size.widthPerc(2)),
                    Text(
                      isBorrowed ? 'Borrowed' : 'Lended',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                StreamBuilder<List<RecordModel>>(
                  stream: DatabaseService().getRecords(),
                  initialData: DatabaseService().currentRecords,
                  builder: (context, snapshot) {
                    final records = snapshot.data ?? [];
                    double total = 0.0;

                    for (var record in records) {
                      final bool isRecordLended = record.type == 'lending';

                      if (isBorrowed && !isRecordLended) {
                        total += record.amount;
                      } else if (!isBorrowed && isRecordLended) {
                        total += record.amount;
                      }
                    }

                    if (total == 0) {
                      final playfulText = isBorrowed
                          ? "All settled up! Zero debts"
                          : "Nothing out on loan!";

                      return Text(
                        playfulText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      );
                    }

                    return ValueListenableBuilder<String>(
                      valueListenable: CurrencyService.selectedCurrency,
                      builder: (context, currentCurrency, _) {
                        return Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  CurrencyService.formatAmount(
                                    total,
                                    targetCurrency: currentCurrency,
                                  ),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LendedBorrowedRecords(
                                      isBorrowed: isBorrowed,
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.chevron_right_sharp,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                size: size.widthPerc(6.5),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}