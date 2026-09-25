import 'package:cloud_firestore/cloud_firestore.dart';

class RecordModel {
  final String? id;
  final String type; // 'lending' or 'borrowing'
  final double amount;
  final String contactName;
  final String? reason; // Optional
  final DateTime date;
  final DateTime? returnDate; // Optional
  final String status; // Default: 'pending'
  final DateTime createdAt;

  RecordModel({
    this.id,
    required this.type,
    required this.amount,
    required this.contactName,
    this.reason,
    required this.date,
    this.returnDate,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'contactName': contactName,
      'reason': reason,
      'date': Timestamp.fromDate(date),
      'returnDate': returnDate != null ? Timestamp.fromDate(returnDate!) : null,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory RecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecordModel(
      id: doc.id,
      type: data['type'] ?? 'lending',
      amount: (data['amount'] ?? 0.0).toDouble(),
      contactName: data['contactName'] ?? '',
      reason: data['reason'],
      date: (data['date'] as Timestamp).toDate(),
      returnDate: data['returnDate'] != null
          ? (data['returnDate'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}