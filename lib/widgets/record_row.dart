import 'package:flutter/material.dart';
import 'package:wallet/screens/activity.dart';
import 'package:wallet/services/currency_service.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/update_delete.dart';

class RecordRow extends StatelessWidget {
  final ActivityItem item;
  final Function(ActivityItem) onUpdate;
  final VoidCallback onDelete;

  const RecordRow({
    super.key,
    required this.item,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.widthPerc(4),
        vertical: size.heightPerc(1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: size.widthPerc(10),
            height: size.widthPerc(10),
            decoration: BoxDecoration(
              color: item.isLended
                  ? Colors.red.shade100
                  : Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isLended
                  ? Icons.north_east_rounded
                  : Icons.south_west_rounded,
              color: item.isLended
                  ? Colors.red.shade600
                  : Colors.green.shade700,
              size: size.widthPerc(5),
            ),
          ),
          SizedBox(width: size.widthPerc(3.5)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (item.description != null &&
                    item.description!.isNotEmpty) ...[
                  SizedBox(height: size.heightPerc(0.3)),
                  Text(
                    item.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(width: size.widthPerc(2)),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: CurrencyService.selectedCurrency,
                builder: (context, currentCurrency, _) {
                  // Strips out non-numeric characters (e.g. "Rs 60" -> "60") safely
                  final cleanAmountStr = item.amount
                      .toString()
                      .replaceAll(RegExp(r'[^0-9.]'), '');
                  final numericAmount =
                      double.tryParse(cleanAmountStr) ?? 0.0;

                  final formatted = CurrencyService.formatAmount(
                    numericAmount,
                    targetCurrency: currentCurrency,
                  );
                  return Text(
                    '${item.isLended ? '-' : '+'}$formatted',
                    style: TextStyle(
                      color:
                          item.isLended ? Colors.red : Colors.green.shade700,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              SizedBox(width: size.widthPerc(5)),

              UpdateDelete(
                item: item,
                onSave: (updatedItem) => onUpdate(updatedItem),
                onDelete: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}