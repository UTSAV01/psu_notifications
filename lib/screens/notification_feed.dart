import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/psu_card.dart';
import '../repositories/notification_repository.dart';

class NotificationFeedScreen extends ConsumerWidget {
  const NotificationFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the real-time stream from Firestore
    final notificationsAsyncValue = ref.watch(notificationsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('PSU Tracker'),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: notificationsAsyncValue.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No PSU notifications found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(notificationsStreamProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return PsuCard(notification: notifications[index]);
              },
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: 6, // Show 6 skeleton cards
          itemBuilder: (context, index) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const SizedBox(
                  height: 160,
                  width: double.infinity,
                ),
              ),
            );
          },
        ),
        error: (error, stackTrace) => Center(
          child: Text(
            'Error loading alerts: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}