import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/psu_notification.dart';

// Provide the Firestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provide the NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.watch(firestoreProvider));
});

// Stream provider to listen to notifications collection automatically
final notificationsStreamProvider = StreamProvider<List<PsuNotification>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotificationsStream();
});

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository(this._firestore);

  Stream<List<PsuNotification>> getNotificationsStream() {
    return _firestore
        .collection('notifications')
        .orderBy('datePosted', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PsuNotification.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}
