import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/psu_card.dart';
import '../repositories/notification_repository.dart';
import '../providers/bookmark_provider.dart';

class SavedJobsScreen extends ConsumerWidget {
  const SavedJobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsyncValue = ref.watch(notificationsStreamProvider);
    final savedJobs = ref.watch(bookmarkProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Saved Alerts 📌'),
        backgroundColor: Colors.teal[800],
        elevation: 0,
      ),
      body: notificationsAsyncValue.when(
        data: (notifications) {
          final bookmarkedNotifications = notifications
              .where((note) => savedJobs.contains(note.id))
              .toList();

          if (bookmarkedNotifications.isEmpty) {
            return const Center(
              child: Text(
                'No saved alerts yet. Tap the bookmark icon to save a job!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: bookmarkedNotifications.length,
            itemBuilder: (context, index) {
              return PsuCard(notification: bookmarkedNotifications[index]);
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(12.0),
          itemCount: 3,
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
            'Error loading saves: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
