import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wallet/models/record_model.dart';

class DatabaseService {
  // Singleton instance to ensure a single shared local cache
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Local In-Memory Cache (Primary Single Source of Truth)
  final List<RecordModel> _localRecords = [];

  // Stream controller that feeds all UI screens with instant updates
  final StreamController<List<RecordModel>> _recordsController =
      StreamController<List<RecordModel>>.broadcast();

  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  DatabaseService._internal() {
    _initFirestoreListener();

    // Re-bind listener if auth status changes
    _auth.authStateChanges().listen((_) {
      _initFirestoreListener();
    });
  }

  String? get _uid => _auth.currentUser?.uid;

  /// Background listener that populates local memory whenever Firestore receives data
  void _initFirestoreListener() {
    _firestoreSubscription?.cancel();

    if (_uid == null) return;

    _firestoreSubscription = _db
        .collection('users')
        .doc(_uid)
        .collection('records')
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        final remoteRecords = snapshot.docs
            .map((doc) => RecordModel.fromFirestore(doc))
            .toList();

        // Sync Firestore data into local cache
        _localRecords.clear();
        _localRecords.addAll(remoteRecords);
        _notifyListeners();
      },
      onError: (error) {
        debugPrint("Background Firestore sync warning: $error");
      },
    );
  }

  void _notifyListeners() {
    if (!_recordsController.isClosed) {
      _recordsController.add(List.unmodifiable(_localRecords));
    }
  }

  // 1. FETCH REAL-TIME STREAM OF RECORDS (Instant 0ms local stream)
  Stream<List<RecordModel>> getRecords() {
    // Immediately emit current cached state upon subscription
    Future.microtask(() => _notifyListeners());
    return _recordsController.stream;
  }

  /// Synchronous direct access to cached records
  List<RecordModel> get currentRecords => List.unmodifiable(_localRecords);

  // 2. ADD A NEW RECORD (Instant local update + Silent background sync)
Future<void> addRecord(RecordModel record) async {
    // Step 1: Instant local UI update
    _localRecords.insert(0, record);
    _notifyListeners();

    // Step 2: Non-blocking background sync to Firestore
    if (_uid != null) {
      final recordsRef =
          _db.collection('users').doc(_uid).collection('records');

      // If ID is null or empty, recordsRef.doc() generates a auto-ID reference
      final docRef = (record.id == null || record.id!.isEmpty)
          ? recordsRef.doc()
          : recordsRef.doc(record.id);

      docRef.set(record.toMap()).catchError((e) {
        debugPrint("Firestore background add failed: $e");
      });
    }
  }

  // 3. UPDATE AN EXISTING RECORD BY ID (Instant local update + Silent background sync)
  Future<void> updateRecord(String recordId, RecordModel record) async {
    // Step 1: Instant local UI update
    final index = _localRecords.indexWhere((r) => r.id == recordId);
    if (index != -1) {
      _localRecords[index] = record;
      _notifyListeners();
    }

    // Step 2: Non-blocking background sync to Firestore
    if (_uid != null) {
      _db
          .collection('users')
          .doc(_uid)
          .collection('records')
          .doc(recordId)
          .update(record.toMap())
          .catchError((e) {
        debugPrint("Firestore background update failed: $e");
      });
    }
  }

  // 4. DELETE A RECORD BY ID (Instant local update + Silent background sync)
  Future<void> deleteRecord(String recordId) async {
    // Step 1: Instant local UI update
    _localRecords.removeWhere((r) => r.id == recordId);
    _notifyListeners();

    // Step 2: Non-blocking background sync to Firestore
    if (_uid != null) {
      _db
          .collection('users')
          .doc(_uid)
          .collection('records')
          .doc(recordId)
          .delete()
          .catchError((e) {
        debugPrint("Firestore background delete failed: $e");
      });
    }
  }
}