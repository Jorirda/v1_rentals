import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  String title;
  String body;
  DateTime timestamp;
  String userImageURL;
  String vehicleImageURL;
  String bookingId; // Add this field

  NotificationModel({
    required this.title,
    required this.body,
    required this.timestamp,
    required this.userImageURL,
    required this.vehicleImageURL,
    required this.bookingId, // Initialize this field
  });

  factory NotificationModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userImageURL: data['userImageURL'] ?? '',
      vehicleImageURL: data['vehicleImageURL'] ?? '',
      bookingId: data['bookingId'] ?? '', // Retrieve this field
    );
  }

  factory NotificationModel.fromMap(Map<String, dynamic> data) {
    return NotificationModel(
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      userImageURL: data['userImageURL'] ?? '',
      vehicleImageURL: data['vehicleImageURL'] ?? '',
      bookingId: data['bookingId'] ?? '', // Retrieve this field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'userImageURL': userImageURL,
      'vehicleImageURL': vehicleImageURL,
      'bookingId': bookingId, // Add this field
    };
  }
}
