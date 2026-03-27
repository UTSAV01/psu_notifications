import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart'; // The file the CLI just generated!
import 'screens/notification_feed.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

// We change main() to be an async function
void main() async {
  // This tells Flutter to wait for external setups (like Firebase) before drawing the UI
  WidgetsFlutterBinding.ensureInitialized();

  // This initializes Firebase using the specific settings for Android/iOS/Web
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable offline caching so users can view previously fetched jobs without internet
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request push notification permissions (Important for iOS)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Automatically subscribe to global broadcast channel
  await messaging.subscribeToTopic('all_users');
  debugPrint("Subscribed to the all_users FCM topic!");

  runApp(const ProviderScope(child: PsuTrackerApp()));
}

class PsuTrackerApp extends StatelessWidget {
  const PsuTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PSU Alert Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home: const NotificationFeedScreen(),
    );
  }
}