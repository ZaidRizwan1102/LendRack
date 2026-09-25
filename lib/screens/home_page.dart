import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:wallet/screens/add_record.dart';
import 'package:wallet/screens/individual_records.dart';
import 'package:wallet/services/currency_service.dart'; // <--- Added CurrencyService
import 'package:wallet/utils/handler.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/HomePage/lend_borrow.dart';
import 'package:wallet/widgets/HomePage/lended_vs_borrowed.dart';
import 'package:wallet/widgets/HomePage/quick_cards.dart';
import 'package:wallet/widgets/custom_button.dart';
import 'package:wallet/widgets/header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 1. Fetch saved currency from Firestore when HomePage loads
    CurrencyService.loadUserCurrency();
  }

  @override
  Widget build(BuildContext context) {
    final move = AppHandler(context);
    final size = Responsive(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Header(),
              SizedBox(height: size.heightPerc(2)),

              // Lend & Borrow Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.widthPerc(7.5)),
                child: Row(
                  children: [
                    const LendBorrow(isBorrowed: true),
                    SizedBox(width: size.widthPerc(4)),
                    const LendBorrow(isBorrowed: false),
                  ],
                ),
              ),

              SizedBox(height: size.heightPerc(4)),

              CustomButton(
                buttonText: "Add Record",
                moveTo: () {
                  move.toPage(const AddRecord());
                },
                buttonIcon: Icons.add_box_outlined,
              ),

              SizedBox(height: size.heightPerc(3)),

              // Quick Overview Heading
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.widthPerc(7.5)),
                child: Text(
                  "QUICK OVERVIEW",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              SizedBox(height: size.heightPerc(2)),
             
              // Quick Cards Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.widthPerc(7.5)),
                child: Row(
                  children: [
                    // Box 1: People & Balance
                    StreamBuilder<QuerySnapshot>(
                      stream: userId != null
                          ? FirebaseFirestore.instance
                                .collection('users')
                                .doc(userId)
                                .collection('transactions')
                                .snapshots()
                          : const Stream.empty(),
                      builder: (context, snapshot) {
                        String countText = "0 People";

                        if (snapshot.hasData && snapshot.data != null) {
                          final docs = snapshot.data!.docs;

                          final uniquePeople = docs
                              .map((doc) {
                                final data =
                                    doc.data() as Map<String, dynamic>?;
                                return data?['personName'] as String? ?? '';
                              })
                              .where((name) => name.isNotEmpty)
                              .toSet();

                          final totalCount = uniquePeople.isNotEmpty
                              ? uniquePeople.length
                              : docs.length;

                          countText =
                              "$totalCount ${totalCount == 1 ? 'Person' : 'People'}";
                        }

                        return QuickCard(
                          isCurrencyCard: false,
                          peopleCount: countText,
                          onChevronTap: () {
                            move.toPage(const IndividualRecords());
                          },
                        );
                      },
                    ),

                    SizedBox(width: size.widthPerc(4)),

                    // Box 2: Currency Selector connected to Global Notifier & Firestore
                    QuickCard(
                      isCurrencyCard: true,
                      selectedCurrency: CurrencyService.selectedCurrency,
                      onCurrencyChanged: (newValue) {
                        if (newValue != null) {
                          CurrencyService.updateCurrency(newValue);
                        }
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.heightPerc(2)),
              const LendedVSBorrowed(),
            ],
          ),
        ),
      ),
    );
  }
}
