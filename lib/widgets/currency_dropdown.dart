import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:wallet/utils/responsive.dart';

class CurrencyDropdown extends StatelessWidget {
  final ValueNotifier<String> selectedCurrency;
  final List<String> currencies;
  final ValueChanged<String?> onChanged;

  const CurrencyDropdown({
    super.key,
    required this.selectedCurrency,
    this.currencies = const [
      'PKR (Rs)', // Pakistani Rupee (Default)
      'USD (\$)', // US Dollar
      'EUR (€)', // Euro
      'GBP (£)', // British Pound
      'INR (₹)', // Indian Rupee
      'CAD (C\$)', // Canadian Dollar
      'CNY (¥)', // Chinese Yuan
      'AED (AED)', // UAE Dirham
      'SAR (SAR)', // Saudi Riyal
      'AUD (A\$)', // Australian Dollar
      'JPY (¥)', // Japanese Yen
    ],
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        buttonStyleData: const ButtonStyleData(padding: EdgeInsets.zero),
        dropdownStyleData: DropdownStyleData(
          maxHeight: size.heightPerc(35),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(size.widthPerc(3)),
          ),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.chevron_right_rounded),
        ),
        valueListenable: selectedCurrency,
        items: currencies.map((String item) {
          // Replaced DropdownMenuItem with DropdownItem
          return DropdownItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
