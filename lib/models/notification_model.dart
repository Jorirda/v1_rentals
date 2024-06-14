import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id; // Add this line
  final String title;
  final String body;
  final String userImageURL;
  final String vehicleImageURL;
  final String bookingId;
  final DateTime timestamp;

  NotificationModel({
    required this.id, // Add this line
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
      id: documentId, // Add this line
      title: data['title'],
      body: data['body'],
      userImageURL: data['userImageURL'],
      vehicleImageURL: data['vehicleImageURL'],
      bookingId: data['bookingId'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
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
