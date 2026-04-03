import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/psu_card.dart';
import '../repositories/notification_repository.dart';

class NotificationFeedScreen extends ConsumerStatefulWidget {
  const NotificationFeedScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationFeedScreen> createState() => _NotificationFeedScreenState();
}

class _NotificationFeedScreenState extends ConsumerState<NotificationFeedScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Watch the real-time stream from Firestore
    final notificationsAsyncValue = ref.watch(notificationsStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search PSU or Role...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
            icon: Icon(Icons.search, color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (value) {
            setState(() {
              _searchQuery = value.toLowerCase();
            });
          },
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: notificationsAsyncValue.when(
        data: (notifications) {
          // Filter logic
          final filteredList = notifications.where((note) {
            return note.psuName.toLowerCase().contains(_searchQuery) ||
                note.role.toLowerCase().contains(_searchQuery);
          }).toList();

          if (filteredList.isEmpty) {
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
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                return PsuCard(notification: filteredList[index]);
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