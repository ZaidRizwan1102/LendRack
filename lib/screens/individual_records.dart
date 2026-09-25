import 'package:flutter/material.dart';
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/IndividualRecords/people_overview.dart';

class IndividualRecords extends StatelessWidget {
  const IndividualRecords({super.key});

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final move = AppHandler(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Bar with Back Action
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.widthPerc(4),
                  vertical: size.heightPerc(1),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => move.goBack(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    SizedBox(width: size.widthPerc(2)),
                    const Text(
                      "Individual Records",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.heightPerc(1.5)),

              // Render Real-time Dynamic People Overview Component
              const PeopleOverview(),
            ],
          ),
        ),
      ),
    );
  }
}
