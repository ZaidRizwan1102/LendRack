import 'package:flutter/material.dart';
import 'package:wallet/services/notification_service.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/Notifications/deadline_reminders.dart';
import 'package:wallet/widgets/Notifications/person_specific_rules.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) {
    final move = AppHandler(context);
    final size = Responsive(context);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Fail-safe sync when navigating back (swipe gesture or hardware back)
          NotificationService().syncAllNotifications();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(overscroll: false),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          NotificationService().syncAllNotifications();
                          move.goBack();
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      SizedBox(width: size.widthPerc(12)),
                      const Text(
                        "Notifications",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.heightPerc(1)),
                  const DeadlineReminders(),
                  SizedBox(height: size.heightPerc(3)),
                  const PersonSpecificRules(),
                  SizedBox(height: size.heightPerc(5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}