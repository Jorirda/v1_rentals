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
  String id;
  String userId;
  String? userEmail;
  String userFullName;
  String vehicleId;
  String vehicleDescription;
  String vendorId;
  String? vendorEmail;
  String vendorBusinessName;
  String? vendorContactInformation;
  DateTime pickupDate;
  TimeOfDay pickupTime;
  DateTime dropoffDate;
  TimeOfDay dropoffTime;
  String pickupLocation;
  String dropoffLocation;
  int totalPrice;
  BookingStatus status;
  String imageUrl;
  bool paymentStatus;
  String paymentMethod;
  DateTime createdAt;
  String clientImageURL; // Add this field
  String vendorImageURL; // Add this field

  // Date and time format
  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat timeFormat = DateFormat('HH:mm:ss');

  Booking({
    required this.id,
    required this.userId,
    this.userEmail,
    required this.userFullName,
    required this.vehicleId,
    required this.vehicleDescription,
    required this.vendorId,
    this.vendorEmail,
    required this.vendorBusinessName,
    this.vendorContactInformation,
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
    required this.clientImageURL, // Initialize this field
    required this.vendorImageURL, // Initialize this field
  });

  factory Booking.fromSnapshot(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userFullName: data['userFullName'] ?? '',
      vehicleId: data['vehicleId'] ?? '',
      vehicleDescription: data['vehicleDescription'] ?? '',
      vendorId: data['vendorId'] ?? '',
      vendorEmail: data['vendorEmail'] ?? '',
      vendorBusinessName: data['vendorBusinessName'] ?? '',
      vendorContactInformation: data['vendorContactInformation'] ?? '',
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
      clientImageURL: data['clientImageURL'] ?? '', // Retrieve this field
      vendorImageURL: data['vendorImageURL'] ?? '', // Retrieve this field
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
      'userEmail': userEmail,
      'userFullName': userFullName,
      'vehicleId': vehicleId,
      'vehicleDescription': vehicleDescription,
      'vendorId': vendorId,
      'vendorEmail': vendorEmail,
      'vendorBusinessName': vendorBusinessName,
      'vendorContactInformation': vendorContactInformation,
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
      'clientImageURL': clientImageURL, // Add this field
      'vendorImageURL': vendorImageURL, // Add this field
    };
  }

  String getBookingStatusString() {
    return status.getTranslation();
  }
}
