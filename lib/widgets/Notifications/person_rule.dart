import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wallet/utils/responsive.dart';

class PersonRuleItem {
  String id;
  String selectedPerson;
  bool isEnabled;
  String ruleType;
  int selectedNumber;
  String selectedUnit;

  PersonRuleItem({
    required this.id,
    this.selectedPerson = "Select the Person",
    this.isEnabled = false,
    this.ruleType = "Lended Deadline",
    this.selectedNumber = 3,
    this.selectedUnit = "Days before",
  });

  factory PersonRuleItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PersonRuleItem(
      id: doc.id,
      selectedPerson: data['selectedPerson'] ?? "Select the Person",
      isEnabled: data['isEnabled'] ?? false,
      ruleType: data['ruleType'] ?? "Lended Deadline",
      selectedNumber: (data['selectedNumber'] as num?)?.toInt() ?? 3,
      selectedUnit: data['selectedUnit'] ?? "Days before",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'selectedPerson': selectedPerson,
      'isEnabled': isEnabled,
      'ruleType': ruleType,
      'selectedNumber': selectedNumber,
      'selectedUnit': selectedUnit,
    };
  }
}

class PersonRuleCard extends StatelessWidget {
  final PersonRuleItem rule;
  final List<String> availablePeople;
  final VoidCallback onRemove;

  const PersonRuleCard({
    super.key,
    required this.rule,
    required this.availablePeople,
    required this.onRemove,
  });

  static const List<String> ruleTypes = [
    "Lended Deadline",
    "Borrowed Deadline",
    "No deadline",
  ];

  static final List<int> numbers = List.generate(30, (index) => index + 1);

  static const List<String> deadlineUnits = [
    "Days before",
    "Weeks before",
    "Hours before",
    "Minutes before",
  ];

  static const List<String> noDeadlineUnits = [
    "Days",
    "Weeks",
    "Months",
    "Years",
  ];

  // Helper method to sync updates to Firestore
  Future<void> _updateRuleInFirestore() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || rule.id.isEmpty) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('person_rules')
          .doc(rule.id)
          .update(rule.toMap());
    } catch (e) {
      debugPrint("Error updating person rule: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive(context);
    final isNoDeadline = rule.ruleType == "No deadline";
    final unitOptions = isNoDeadline ? noDeadlineUnits : deadlineUnits;

    // Combine default choice with real people list
    final peopleDropdownList = ["Select the Person", ...availablePeople];

    // Ensure selected value exists in options
    final effectivePerson = peopleDropdownList.contains(rule.selectedPerson)
        ? rule.selectedPerson
        : "Select the Person";

    return Container(
      padding: EdgeInsets.all(size.widthPerc(3.5)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(size.widthPerc(2.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 22,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              SizedBox(width: size.widthPerc(2)),
              Expanded(
                child: _buildDropdownContainer(
                  context: context,
                  child: DropdownButton<String>(
                    value: effectivePerson,
                    underline: const SizedBox(),
                    isDense: true,
                    borderRadius: BorderRadius.circular(12),
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    elevation: 3,
                    isExpanded: true,
                    items: peopleDropdownList.map((String person) {
                      return DropdownMenuItem<String>(
                        value: person,
                        child: Text(
                          person,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        rule.selectedPerson = val;
                        _updateRuleInFirestore();
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: size.widthPerc(2)),
              Switch.adaptive(
                value: rule.isEnabled,
                onChanged: (val) {
                  rule.isEnabled = val;
                  _updateRuleInFirestore();
                },
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline,
                  size: 22,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),

          if (rule.isEnabled) ...[
            SizedBox(height: size.heightPerc(1.5)),
            _buildDropdownContainer(
              context: context,
              child: DropdownButton<String>(
                value: rule.ruleType,
                underline: const SizedBox(),
                isDense: true,
                isExpanded: true,
                dropdownColor: Theme.of(context).colorScheme.surface,
                items: ruleTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(
                      type,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    rule.ruleType = val;
                    rule.selectedUnit = val == "No deadline"
                        ? noDeadlineUnits[0]
                        : deadlineUnits[0];
                    _updateRuleInFirestore();
                  }
                },
              ),
            ),
            SizedBox(height: size.heightPerc(1.5)),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 3,
                  height: 22,
                  margin: EdgeInsets.only(right: size.widthPerc(3)),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.3) ??
                        Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  isNoDeadline ? "Remind me every" : "Remind me",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(width: size.widthPerc(2)),
                _buildDropdownContainer(
                  context: context,
                  child: DropdownButton<int>(
                    value: rule.selectedNumber,
                    underline: const SizedBox(),
                    isDense: true,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    items: numbers.map((int val) {
                      return DropdownMenuItem<int>(
                        value: val,
                        child: Text(
                          val.toString(),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        rule.selectedNumber = val;
                        _updateRuleInFirestore();
                      }
                    },
                  ),
                ),
                SizedBox(width: size.widthPerc(1.5)),
                Flexible(
                  child: _buildDropdownContainer(
                    context: context,
                    child: DropdownButton<String>(
                      value: unitOptions.contains(rule.selectedUnit)
                          ? rule.selectedUnit
                          : unitOptions[0],
                      underline: const SizedBox(),
                      isDense: true,
                      isExpanded: true,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      items: unitOptions.map((String unit) {
                        return DropdownMenuItem<String>(
                          value: unit,
                          child: Text(
                            unit,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          rule.selectedUnit = val;
                          _updateRuleInFirestore();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownContainer({
    required BuildContext context,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.2) ??
              Colors.black.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }
}
