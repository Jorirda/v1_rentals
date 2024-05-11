import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum BookingStatus {
  all,
  completed,
  cancelled,
  pending,
  inProgress,
}

class Booking {
  String id; // Unique booking ID
  String userId; // ID of the user who made the booking
  String vehicleId; // ID of the booked vehicle
  String vendorId; // ID of the vendor providing the vehicle
  DateTime pickupDate; // Pickup date
  TimeOfDay pickupTime; // Pickup time
  DateTime dropoffDate; // Drop-off date
  TimeOfDay dropoffTime; // Drop-off time
  String pickupLocation; // Pickup location
  String dropoffLocation; // Drop-off location
  int totalPrice; // Total price of the booking
  BookingStatus status; // Booking status (e.g., confirmed, canceled)
  String imageUrl;
  bool paymentStatus; // Payment status (true if paid, false if pending)
  String paymentMethod;
  Timestamp createdAt; // Timestamp of when the booking was created

  Booking({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.vendorId, // Add vendorId
    required this.pickupDate,
    required this.pickupTime,
    required this.dropoffDate,
    required this.dropoffTime,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.totalPrice,
    required this.status,
    required this.imageUrl,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory Booking.fromSnapshot(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      vendorId: data['vendorId'] ?? '', // Extract vendorId
      pickupDate: DateTime.parse(data['pickupDate'] ?? ''),
      pickupTime: _parseTimeOfDay(data['pickupTime'] ?? ''),
      dropoffDate: DateTime.parse(data['dropoffDate'] ?? ''),
      dropoffTime: _parseTimeOfDay(data['dropoffTime'] ?? ''),
      pickupLocation: data['pickupLocation'] ?? '',
      dropoffLocation: data['dropoffLocation'] ?? '',
      totalPrice: data['totalPrice'] ?? 0,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${data['status']}',
        orElse: () =>
            BookingStatus.pending, // Provide a default status if not found
      ),
      imageUrl: data['imageUrl'] ?? '',
      paymentStatus: data['paymentStatus'] ?? false,
      paymentMethod: data['paymentMethod'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }

  // Helper method to parse string to TimeOfDay
  static TimeOfDay _parseTimeOfDay(String timeString) {
    final List<String> parts = timeString.split(' ');
    final List<String> timeParts = parts[0].split(':');
    final int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);
    final String period = parts[1];

    return TimeOfDay(
      hour: period == 'AM' ? hour : hour + 12,
      minute: minute,
    );
  }

  // Convert Booking object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'vendorId': vendorId, // Include vendorId
      'pickupDate': pickupDate.toIso8601String().substring(0, 10),
      'pickupTime': getFormattedTime(pickupTime),
      'dropoffDate': dropoffDate.toIso8601String().substring(0, 10),
      'dropoffTime': getFormattedTime(dropoffTime),
      'pickupLocation': pickupLocation,
      'dropoffLocation': dropoffLocation,
      'totalPrice': totalPrice,
      'status': status.toString().split('.').last,
      'imageUrl': imageUrl,
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
