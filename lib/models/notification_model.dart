import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String userImageURL;
  final String vehicleImageURL;
  final String bookingId;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.userImageURL,
    required this.vehicleImageURL,
    required this.bookingId,
    required this.timestamp,
  });

  factory NotificationModel.fromMap(
      Map<String, dynamic> data, String documentId) {
    return NotificationModel(
      id: documentId,
      title: data['title'] ?? 'No Title', // Provide a default value if null
      body: data['body'] ?? 'No Body', // Provide a default value if null
      userImageURL:
          data['userImageURL'] ?? '', // Provide a default value if null
      vehicleImageURL:
          data['vehicleImageURL'] ?? '', // Provide a default value if null
      bookingId: data['bookingId'] ?? '', // Provide a default value if null
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'userImageURL': userImageURL,
      'vehicleImageURL': vehicleImageURL,
      'bookingId': bookingId,
      'timestamp': timestamp,
    };
  }
}
