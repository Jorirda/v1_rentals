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
  String pickupLocation; // Pickup location
  String dropoffLocation; // Drop-off location
  int totalPrice; // Total price of the booking
  String status; // Booking status (e.g., confirmed, canceled)
  bool paymentStatus; // Payment status (true if paid, false if pending)
  String paymentMethod;
  Timestamp createdAt; // Timestamp of when the booking was created

  Booking({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.pickupDate,
    required this.pickupTime,
    required this.dropoffDate,
    required this.dropoffTime,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
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
      pickupLocation: data['pickupLocation'] ?? '',
      dropoffLocation: data['dropoffLocation'] ?? '',
      totalPrice: data['totalPrice'] ?? 0,
      status: data['status'] ?? '',
      paymentStatus: data['paymentStatus'] ?? false,
      paymentMethod: data['paymentMethod'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  // Convert Booking object to Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'vehicleId': vehicleId,
      'pickupDate': pickupDate.toIso8601String().substring(0, 10),
      'pickupTime': getFormattedTime(pickupTime),
      'dropoffDate': dropoffDate.toIso8601String().substring(0, 10),
      'dropoffTime': getFormattedTime(dropoffTime),
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt,
    };
  }

  // Method to format time
  String getFormattedTime(TimeOfDay time) {
    final int hour = time.hourOfPeriod;
    final String amPm = time.period == DayPeriod.am ? 'AM' : 'PM';
    final String hourString = hour == 0 ? '12' : hour.toString();
    final String minuteString = time.minute.toString().padLeft(2, '0');
    return '$hourString:$minuteString $amPm';
  }
}
