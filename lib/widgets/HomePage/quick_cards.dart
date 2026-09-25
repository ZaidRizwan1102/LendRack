import 'package:flutter/material.dart';
import 'package:wallet/models/record_model.dart';
import 'package:wallet/services/database_service.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/currency_dropdown.dart';

class QuickCard extends StatelessWidget {
  final bool isCurrencyCard;
  final String? peopleCount;
  final VoidCallback? onChevronTap;
  final ValueNotifier<String>? selectedCurrency;
  final ValueChanged<String?>? onCurrencyChanged;

  const QuickCard({
    super.key,
    required this.isCurrencyCard,
    this.peopleCount,
    this.onChevronTap,
    this.selectedCurrency,
    this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return Expanded(
      child: Container(
        // 1. Replaced hardcoded height with flexible minHeight
        constraints: BoxConstraints(minHeight: size.widthPerc(34)),
        padding: EdgeInsets.all(size.widthPerc(3.5)),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Dynamic Icon + Title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(size.widthPerc(2)),
                  decoration: BoxDecoration(
                    color: const Color(0xFF001540).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCurrencyCard
                        ? Icons.currency_exchange_rounded
                        : Icons.people_outline_rounded,
                    size: size.widthPerc(6),
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(width: size.widthPerc(2)),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      isCurrencyCard ? "Currency" : "Individual Records",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: size.heightPerc(1)),

            // Bottom Content: Chevron/Count OR Currency Dropdown
            isCurrencyCard
                ? (selectedCurrency != null && onCurrencyChanged != null)
                      ? CurrencyDropdown(
                          selectedCurrency: selectedCurrency!,
                          onChanged: onCurrencyChanged!,
                        )
                      : const SizedBox.shrink()
                : _buildPeopleCountContent(context, size),
          ],
        ),
      ),
    );
  }

  /// Always calculates live unique people count directly from local storage
  Widget _buildPeopleCountContent(BuildContext context, Responsive size) {
    return StreamBuilder<List<RecordModel>>(
      stream: DatabaseService().getRecords(),
      initialData: DatabaseService().currentRecords,
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];

        // Compute unique person count dynamically
        final uniquePeopleCount = records
            .map((r) => r.contactName.trim().toLowerCase())
            .where((name) => name.isNotEmpty)
            .toSet()
            .length;

        final displayCount =
            "$uniquePeopleCount ${uniquePeopleCount == 1 ? 'Person' : 'People'}";

        return _buildPeopleRow(context, size, displayCount);
      },
    );
  }

  Widget _buildPeopleRow(
    BuildContext context,
    Responsive size,
    String countText,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.widthPerc(1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            countText,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            splashRadius: size.widthPerc(5),
            icon: Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            onPressed: onChevronTap,
          ),
        ],
      ),
    );
  }
}
