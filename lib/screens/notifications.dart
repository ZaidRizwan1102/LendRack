import 'package:flutter/material.dart';
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

    return Scaffold(
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
                      onPressed: () => move.goBack(),
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
    );
  }
}
