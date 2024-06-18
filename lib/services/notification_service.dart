import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:v1_rentals/models/notification_model.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  Future<void> initialize() async {
    await Firebase.initializeApp();
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification payload: ${response.payload}');
      },
    );

    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received a foreground message: ${message.messageId}');
        if (message.notification != null) {
          _showNotification(
            message.notification!.title,
            message.notification!.body,
            message.data,
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message clicked!');
        if (message.data != null) {
          // Handle the notification click
        }
      });
    }
  }

  Future<void> _showNotification(
      String? title, String? body, Map<String, dynamic> data) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel', // id
      'Default Channel', // title
      channelDescription: 'This is the default channel for notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: data[
          'payload'], // Optional payload for onDidReceiveNotificationResponse
    );
  }

  Future<void> sendNotification(
      String title, String body, String fcmToken) async {
    try {
      // Load the service account key from environment variables
      final serviceAccountKeyString = dotenv.env['FCM_SERVICE_ACCOUNT_KEY'];
      if (serviceAccountKeyString == null) {
        throw Exception(
            'Service account key not found in environment variables');
      }
      final serviceAccountKey = jsonDecode(serviceAccountKeyString);

      // Define the scopes required for the FCM API
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      // Create a service account client
      final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(serviceAccountKey),
        scopes,
      );

      // Define the FCM endpoint
      final url =
          'https://fcm.googleapis.com/v1/projects/v1-rentals-test/messages:send';

      // Create the payload
      final payload = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
        },
      };

      // Send the notification
      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification: ${response.statusCode}');
        print('Response: ${response.body}');
      }

      client.close();
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  Future<void> sendUserNotification(
      String userId, String title, String body) async {
    try {
      String? fcmToken = await _getUserFcmToken(userId);
      if (fcmToken != null) {
        await sendNotification(
          title,
          body,
          fcmToken,
        );
        print('Notification sent to user');
      } else {
        print('User FCM Token is null');
      }
    } catch (e) {
      print('Error sending user notification: $e');
    }
  }

  Future<void> sendVendorNotification(
      String vendorId, String title, String body) async {
    try {
      String? fcmToken = await _getUserFcmToken(vendorId);
      if (fcmToken != null) {
        await sendNotification(
          title,
          body,
          fcmToken,
        );
        print('Notification sent to vendor');
      } else {
        print('Vendor FCM Token is null');
      }
    } catch (e) {
      print('Error sending vendor notification: $e');
    }
  }

  Future<String?> _getUserFcmToken(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      // Cast the result to Map<String, dynamic>
      Map<String, dynamic>? userData =
          userSnapshot.data() as Map<String, dynamic>?;
      // Use null-aware operator to safely access the 'fcmToken'
      return userData?['fcmToken'] as String?;
    } catch (e) {
      print('Error getting user FCM token: $e');
      return null;
    }
  }

  Future<void> createAndSendNotification(
    String userId,
    String vendorId,
    String bookingId,
    String userImageURL,
    String vendorImageURL,
    String vehicleImageURL,
    String status,
  ) async {
    // Define titles and bodies based on the status
    String userTitle = '';
    String userBody = '';
    String vendorTitle = '';
    String vendorBody = '';

    switch (status) {
      case 'sent':
        userTitle = 'Booking Request Successfully sent';
        userBody =
            'Your booking request has been sent to the vendor for confirmation.';
        vendorTitle = 'New Booking';
        vendorBody = 'You have received a new booking from a client.';
        break;
      case 'accepted':
        userTitle = 'Booking Accepted';
        userBody =
            'Your booking has been accepted by the vendor. Please complete the payment to proceed.';
        vendorTitle = 'Booking Accepted';
        vendorBody = 'You have accepted the booking.';
        break;
      case 'inProgress':
        userTitle = 'Booking Confirmed';
        userBody =
            'Your payment was successful and your booking is now confirmed.';
        vendorTitle = 'Booking Confirmed';
        vendorBody = 'A booking has been confirmed after payment.';
        break;
      case 'completed':
        userTitle = 'Booking Completed';
        userBody = 'Your booking has been completed by the vendor.';
        vendorTitle = 'Booking Completed';
        vendorBody = 'You have completed the booking.';
        break;
      case 'cancelled':
        userTitle = 'Booking Cancelled';
        userBody = 'Your booking has been cancelled.';
        vendorTitle = 'Booking Cancelled';
        vendorBody = 'A booking has been cancelled by the user.';
        break;
      default:
        return;
    }

    // Create notification models
    NotificationModel userNotification = NotificationModel(
      title: userTitle,
      body: userBody,
      timestamp: DateTime.now(),
      userImageURL: vendorImageURL,
      vehicleImageURL: vehicleImageURL,
      bookingId: bookingId,
      id: '',
    );

    NotificationModel vendorNotification = NotificationModel(
      title: vendorTitle,
      body: vendorBody,
      timestamp: DateTime.now(),
      userImageURL: userImageURL,
      vehicleImageURL: vehicleImageURL,
      bookingId: bookingId,
      id: '',
    );

    // Add notifications to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(userNotification.toMap());

    await FirebaseFirestore.instance
        .collection('users')
        .doc(vendorId)
        .collection('notifications')
        .add(vendorNotification.toMap());

    // Send push notifications
    await sendUserNotification(userId, userTitle, userBody);
    await sendVendorNotification(vendorId, vendorTitle, vendorBody);
  }
}

final pushNotificationService = PushNotificationService();
