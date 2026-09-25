import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';
import 'package:wallet/widgets/Notifications/person_rule.dart';

class PersonSpecificRules extends StatelessWidget {
  const PersonSpecificRules({super.key});

  // Add new rule document to Firestore
  Future<void> _addNewRule() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final newRule = PersonRuleItem(
      id: '',
      selectedPerson: "Select the Person",
      isEnabled: true,
      ruleType: "Lended Deadline",
      selectedNumber: 3,
      selectedUnit: "Days before",
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('person_rules')
          .add(newRule.toMap());
    } catch (e) {
      debugPrint("Error adding person rule: $e");
    }
  }

  // Delete rule document from Firestore
  Future<void> _removeRule(String ruleId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || ruleId.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('person_rules')
          .doc(ruleId)
          .delete();
    } catch (e) {
      debugPrint("Error deleting person rule: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    const headingStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 20);
    final subtitleStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).textTheme.bodySmall?.color,
    );

    if (userId == null) return const SizedBox.shrink();

    // Stream 1: Fetch actual people from user transactions
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .snapshots(),
      builder: (context, txSnapshot) {
        final List<String> availablePeople = [];
        if (txSnapshot.hasData && txSnapshot.data != null) {
          final Set<String> nameSet = {};
          for (var doc in txSnapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>?;
            final personName = (data?['personName'] as String?)?.trim() ?? '';
            if (personName.isNotEmpty) {
              nameSet.add(personName);
            }
          }
          availablePeople.addAll(nameSet.toList()..sort());
        }

        // Stream 2: Fetch saved person rules from Firestore
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('person_rules')
              .snapshots(),
          builder: (context, rulesSnapshot) {
            final List<PersonRuleItem> rules = [];
            if (rulesSnapshot.hasData && rulesSnapshot.data != null) {
              for (var doc in rulesSnapshot.data!.docs) {
                rules.add(PersonRuleItem.fromFirestore(doc));
              }
            }

            return Container(
              width: size.widthPerc(85),
              padding: EdgeInsets.all(size.widthPerc(4.5)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Person-Specific Rules", style: headingStyle),
                  SizedBox(height: size.heightPerc(0.5)),
                  Text(
                    "Override general settings for specific people.",
                    style: subtitleStyle,
                  ),
                  SizedBox(height: size.heightPerc(2)),

                  if (rules.isNotEmpty)
                    Column(
                      children: [
                        for (int i = 0; i < rules.length; i++) ...[
                          PersonRuleCard(
                            rule: rules[i],
                            availablePeople: availablePeople,
                            onRemove: () => _removeRule(rules[i].id),
                          ),
                          if (i < rules.length - 1)
                            SizedBox(height: size.heightPerc(1.5)),
                        ],
                      ],
                    ),

                  if (rules.isNotEmpty) SizedBox(height: size.heightPerc(1.5)),

                  // Add Rule Button
                  GestureDetector(
                    onTap: _addNewRule,
                    child: CustomPaint(
                      painter: DashedBorderPainter(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: size.widthPerc(2.5),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: size.heightPerc(1.4),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: size.widthPerc(1.5)),
                            Text(
                              "Add Person Rule",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    const double dashWidth = 6.0;
    const double dashSpace = 4.0;

    for (final PathMetric measure in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < measure.length) {
        dashPath.addPath(
          measure.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
