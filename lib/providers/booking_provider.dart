import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/booking_model.dart';

class BookingProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  Stream<List<Booking>> getCurrentUserBookingsStream(BookingStatus status) {
    return _authService.getCurrentUserBookingsStream(status);
  }

  Stream<List<Booking>> getVendorBookingsStream(BookingStatus status) {
    return _authService.getVendorBookingsStream(status);
  }

  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    await _authService.updateBookingStatus(bookingId, status);
  }

  Future<void> updateBookingDetails(Booking booking) async {
    await _authService.updateBookingDetails(booking);
  }

  Future<Booking?> getBookingById(String bookingId) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .get();
      if (snapshot.exists) {
        return Booking.fromSnapshot(snapshot);
      } else {
        print('Booking with ID $bookingId does not exist.');
        return null;
      }
    } catch (e) {
      print('Error fetching booking details for ID $bookingId: $e');
      return null;
    }
  }
}
