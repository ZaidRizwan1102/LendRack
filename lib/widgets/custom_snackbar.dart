import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final size = Responsive(context);

    // Clears any currently active snackbars before showing new one
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
        margin: EdgeInsets.only(
          left: size.widthPerc(7.5),
          right: size.widthPerc(7.5),
          bottom: size.heightPerc(2),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.widthPerc(3)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: size.widthPerc(4),
          vertical: size.heightPerc(1.5),
        ),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onAction != null) ...[
              SizedBox(width: size.widthPerc(2)),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  onAction();
                },
                child: Text(
                  actionLabel ?? "Undo",
                  style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
