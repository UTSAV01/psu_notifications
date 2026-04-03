import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/psu_notification.dart';
import '../providers/bookmark_provider.dart';

class PsuCard extends ConsumerWidget {
  final PsuNotification notification;

  const PsuCard({Key? key, required this.notification}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedJobs = ref.watch(bookmarkProvider);
    final isSaved = savedJobs.contains(notification.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final url = Uri.parse(notification.notificationLink);
          try {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } catch (e) {
            debugPrint("Could not launch URL: $e");
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      notification.psuName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(
                          notification.isStatePsu ? 'State' : 'Central',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        backgroundColor: notification.isStatePsu
                            ? Colors.teal[400]
                            : Colors.orange[400],
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? Colors.blue[800] : Colors.grey,
                        ),
                        onPressed: () {
                          ref.read(bookmarkProvider.notifier).toggleBookmark(notification.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.role,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    notification.location,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notification.advtNo != "Not Specified") ...[
                          Text(
                            'Advt: ${notification.advtNo}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          'Posted: ${notification.datePosted}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Deadline: ${notification.deadline}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final url = Uri.parse(notification.notificationLink);
                      try {
                        final launched = await launchUrl(
                            url, mode: LaunchMode.externalApplication);
                        if (!launched && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Could not launch ${notification.notificationLink}')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid link format!')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('View Alert'),
                  ),
                ],
              )
            ],
          ),
        ),
      ), // InkWell perfectly closed here!
    ); // Card perfectly closed here!
  }
}