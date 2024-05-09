import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Booking {
  String id; // Unique booking ID
  String userId; // ID of the user who made the booking
  String vehicleId; // ID of the booked vehicle
  DateTime pickupDate; // Pickup date
  TimeOfDay pickupTime; // Pickup time
  DateTime dropoffDate; // Drop-off date
  TimeOfDay dropoffTime; // Drop-off time
  int totalPrice; // Total price of the booking
  String status; // Booking status (e.g., confirmed, canceled)
  bool paymentStatus; // Payment status (true if paid, false if pending)
  Timestamp createdAt; // Timestamp of when the booking was created

  Booking({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.pickupDate,
    required this.pickupTime,
    required this.dropoffDate,
    required this.dropoffTime,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
  });

  // Convert DocumentSnapshot to Booking object
  factory Booking.fromSnapshot(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      pickupDate: (data['pickupDate'] as Timestamp).toDate(),
      pickupTime:
          TimeOfDay.fromDateTime((data['pickupTime'] as Timestamp).toDate()),
      dropoffDate: (data['dropoffDate'] as Timestamp).toDate(),
      dropoffTime:
          TimeOfDay.fromDateTime((data['dropoffTime'] as Timestamp).toDate()),
      totalPrice: data['totalPrice'] ?? 0,
      status: data['status'] ?? '',
      paymentStatus: data['paymentStatus'] ?? false,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Convert Booking object to Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'pickupDate': pickupDate,
      'pickupTime': Timestamp.fromDate(DateTime(
          pickupDate.year,
          pickupDate.month,
          pickupDate.day,
          pickupTime.hour,
          pickupTime.minute)),
      'dropoffDate': dropoffDate,
      'dropoffTime': Timestamp.fromDate(DateTime(
          dropoffDate.year,
          dropoffDate.month,
          dropoffDate.day,
          dropoffTime.hour,
          dropoffTime.minute)),
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
    };
  }
}
