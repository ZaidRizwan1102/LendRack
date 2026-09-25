import 'package:flutter/material.dart';
import 'package:wallet/screens/notifications.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/screens/help_support.dart';

class OtherSettings extends StatelessWidget {
  const OtherSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final move = AppHandler(context);

    return Container(
      width: size.widthPerc(85),
      // 1. Replaced fixed height with minHeight baseline so content never clips
      constraints: BoxConstraints(minHeight: size.heightPerc(13.5)),
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
        mainAxisSize:
            MainAxisSize.min, // Allows column to fit content dynamically
        children: [
          // 2. Whole row is now clickable via ListTile onTap
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: size.widthPerc(4)),
            leading: Icon(
              Icons.notifications_none_rounded,
              size: size.widthPerc(6),
            ),
            title: const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "Notifications",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => move.toPage(Notifications()),
          ),
          Divider(
            height: 1,
            indent: size.widthPerc(5),
            endIndent: size.widthPerc(5),
            thickness: 1,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: size.widthPerc(4)),
            leading: Icon(Icons.support_agent_rounded, size: size.widthPerc(6)),
            title: const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "Help & Support",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => move.toPage(HelpSupport()),
          ),
        ],
      ),
    );
  }
}
