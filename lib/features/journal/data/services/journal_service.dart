import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/journal_constants.dart';
import '../../domain/models/journal_entry.dart';

class JournalService {
  final FirebaseFirestore _firestore;

  JournalService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  String generateId() {
    return _firestore.collection(JournalConstants.collectionName).doc().id;
  }

  Stream<List<JournalEntry>> getUserEntriesStream(String userId) {
    return _firestore
        .collection(JournalConstants.collectionName)
        .where(JournalConstants.fieldUserId, isEqualTo: userId)
        .orderBy(JournalConstants.fieldDate, descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => JournalEntry.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> saveEntry(JournalEntry entry) async {
    await _firestore
        .collection(JournalConstants.collectionName)
        .doc(entry.id)
        .set(entry.toMap());
  }

  Future<void> deleteEntry(String entryId) async {
    await _firestore
        .collection(JournalConstants.collectionName)
        .doc(entryId)
        .delete();
  }
}
