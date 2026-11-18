import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getItems() {
    return _db.collection('items').snapshots();
  }

  Future<void> addItem({
    required String itemName,
    required String category,
    required String code,
    required String status,
    required String image,
    required String specification,
  }) async {
    DocumentReference doc = _db.collection('items').doc();

    await doc.set({
      'item_id': doc.id,
      'item_name': itemName,
      'category': category,
      'code': code,
      'status': status,
      'image': image,
      'spesification': specification,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateItem({
    required String id,
    required String itemName,
    required String category,
    required String code,
    required String status,
    required String image,
    required String specification,
  }) async {
    await _db.collection('items').doc(id).update({
      'item_name': itemName,
      'category': category,
      'code': code,
      'status': status,
      'image': image,
      'spesification': specification,
    });
  }

  Future<void> deleteItem(String id) async {
    await _db.collection('items').doc(id).delete();
  }

  Future<void> borrowItem({
    required String itemId,
    required String itemName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Silakan login terlebih dahulu');
    }

    final itemRef = _db.collection('items').doc(itemId);

    final borrowingRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('borrowings')
        .doc();

    await _db.runTransaction((transaction) async {
      final itemSnapshot = await transaction.get(itemRef);

      if (!itemSnapshot.exists) {
        throw Exception('Alat tidak ditemukan');
      }

      final status = itemSnapshot.data()?['status'];

      if (status != 'Available') {
        throw Exception('Alat sedang tidak tersedia');
      }

      transaction.update(itemRef, {'status': 'Borrowed'});

      transaction.set(borrowingRef, {
        'borrow_id': borrowingRef.id,
        'item_id': itemId,
        'item_name': itemName,
        'borrow_date': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<QuerySnapshot> getBorrowings(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('borrowings')
        .orderBy('borrow_date', descending: true)
        .snapshots();
  }
}
