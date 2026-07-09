import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/add_record.dart';
import 'package:wallet/widgets/lend_borrow.dart';
import 'package:wallet/widgets/header.dart';
import 'package:wallet/widgets/recent_records.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Header(),
                SizedBox(height: size.heightPerc(3)),
                LendBorrow(),
                SizedBox(height: size.heightPerc(2)),
                AddRecord(),
                SizedBox(height: size.heightPerc(2)),
                Padding(
                  padding: EdgeInsets.only(left: size.widthPerc(4)),
                  child: Text("Recent Records:",
                  style:TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold
                  )),
                ),
                RecentRecords()
              ],
            )
        ),
      )
      );
  }
}
    