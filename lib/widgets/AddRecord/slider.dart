import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';

class SlideWidget extends StatefulWidget {
  final ValueChanged<String>? onTypeChanged;

  const SlideWidget({super.key, this.onTypeChanged});

  @override
  State<SlideWidget> createState() => _SlideWidgetState();
}

class _SlideWidgetState extends State<SlideWidget> {
  bool isLendingSelected = true;

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    return Padding(
      padding: EdgeInsets.all(size.widthPerc(5)),
      child: Container(
        width: size.widthPerc(65),
        height: size.heightPerc(6),
        decoration: BoxDecoration(
          color: const Color(0xFFECF6FF),
          boxShadow: [
            BoxShadow(color: Colors.blueGrey, blurRadius: size.widthPerc(0.15)),
          ],
          borderRadius: BorderRadius.circular(size.widthPerc(1)),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              alignment: isLendingSelected
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 250),
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size.widthPerc(1)),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (!isLendingSelected) {
                        setState(() {
                          isLendingSelected = true;
                        });
                        widget.onTypeChanged?.call('lending');
                      }
                    },
                    child: Center(
                      child: Text(
                        "Lending",
                        style: TextStyle(
                          color: isLendingSelected
                              ? Theme.of(context).colorScheme.surface
                              : Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (isLendingSelected) {
                        setState(() {
                          isLendingSelected = false;
                        });
                        widget.onTypeChanged?.call('borrowing');
                      }
                    },
                    child: Center(
                      child: Text(
                        "Borrowing",
                        style: TextStyle(
                          color: isLendingSelected
                              ? Colors.black
                              : Theme.of(context).colorScheme.surface,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
