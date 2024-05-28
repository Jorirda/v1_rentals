import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:v1_rentals/models/enum_extensions.dart';

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
  DateTime createdAt; // Timestamp of when the booking was created

  // Date and time format
  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat timeFormat = DateFormat('HH:mm:ss');

  Booking({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.vendorId,
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
      vendorId: data['vendorId'] ?? '',
      pickupDate: DateTime.parse(data['pickupDate'] ?? ''),
      pickupTime: _parseTimeOfDay(data['pickupTime'] ?? ''),
      dropoffDate: DateTime.parse(data['dropoffDate'] ?? ''),
      dropoffTime: _parseTimeOfDay(data['dropoffTime'] ?? ''),
      pickupLocation: data['pickupLocation'] ?? '',
      dropoffLocation: data['dropoffLocation'] ?? '',
      totalPrice: data['totalPrice'] ?? 0,
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${data['status']}',
        orElse: () => BookingStatus.pending,
      ),
      imageUrl: data['imageUrl'] ?? '',
      paymentStatus: data['paymentStatus'] ?? false,
      paymentMethod: data['paymentMethod'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final DateTime parsedTime = timeFormat.parse(timeString);
    return TimeOfDay(hour: parsedTime.hour, minute: parsedTime.minute);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'vendorId': vendorId,
      'pickupDate': dateFormat.format(pickupDate),
      'pickupTime': timeFormat
          .format(DateTime(1, 1, 1, pickupTime.hour, pickupTime.minute)),
      'dropoffDate': dateFormat.format(dropoffDate),
      'dropoffTime': timeFormat
          .format(DateTime(1, 1, 1, dropoffTime.hour, dropoffTime.minute)),
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

  String getBookingStatusString() {
    return status.getTranslation();
  }
}
