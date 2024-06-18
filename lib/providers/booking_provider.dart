import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/services/notification_service.dart';

class BookingProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final PushNotificationService _pushNotificationService =
      PushNotificationService();
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

  Future<void> updateBookingStatusAndNotify(String bookingId,
      BookingStatus status, String userId, String vendorId) async {
    try {
      await updateBookingStatus(bookingId, status);

      // Prepare notification messages
      String userTitle = '';
      String userBody = '';
      String vendorTitle = '';
      String vendorBody = '';

      if (status == BookingStatus.cancelled) {
        userTitle = 'Booking Cancelled';
        userBody = 'Your booking has been cancelled.';
        vendorTitle = 'Booking Cancelled';
        vendorBody = 'A booking has been cancelled by the user.';
      } else if (status == BookingStatus.pending) {
        userTitle = 'Booking Updated';
        userBody = 'Your booking details have been updated.';
        vendorTitle = 'Booking Updated';
        vendorBody = 'A booking has been updated by the user.';
      } else if (status == BookingStatus.inProgress) {
        userTitle = 'Booking Confirmed';
        userBody =
            'Your payment was successful and your booking is now confirmed.';
        vendorTitle = 'Booking Confirmed';
        vendorBody = 'A booking has been confirmed after payment.';
      } else if (status == BookingStatus.accepted) {
        userTitle = 'Booking Accepted';
        userBody =
            'Your booking has been accepted by the vendor. Please complete the payment to proceed.';
        vendorTitle = 'Booking Accepted';
        vendorBody = 'You have accepted the booking.';
      } else if (status == BookingStatus.completed) {
        userTitle = 'Booking Completed';
        userBody = 'Your booking has been completed by the vendor.';
        vendorTitle = 'Booking Completed';
        vendorBody = 'You have completed the booking.';
      }

      // Send notifications to user and vendor
      if (userTitle.isNotEmpty && userBody.isNotEmpty) {
        await createAndSendNotification(
          bookingId: bookingId,
          title: userTitle,
          body: userBody,
          recipientId: userId,
        );
      }

      if (vendorTitle.isNotEmpty && vendorBody.isNotEmpty) {
        await createAndSendNotification(
          bookingId: bookingId,
          title: vendorTitle,
          body: vendorBody,
          recipientId: vendorId,
        );
      }
    } catch (e) {
      print('Error updating booking status and sending notifications: $e');
      throw e;
    }
  }

  Future<void> createAndSendNotification({
    required String bookingId,
    required String title,
    required String body,
    required String recipientId,
  }) async {
    try {
      // Fetch the booking to get the vehicle image URL
      Booking? booking = await getBookingById(bookingId);
      if (booking == null) throw Exception('Booking not found');

      // Fetch recipient user data to get the user image URL
      var recipient = await _authService.getUserData(recipientId);
      if (recipient == null) throw Exception('User not found');

      // Create notification data
      final notificationData = {
        'title': title,
        'body': body,
        'userImageURL': recipient.imageURL,
        'vehicleImageURL': booking.imageUrl,
        'bookingId': bookingId,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add the notification to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientId)
          .collection('notifications')
          .add(notificationData);

      // Send FCM notification
      await _pushNotificationService.sendNotification(
        title,
        body,
        recipient.fcmToken!,
      );
    } catch (e) {
      print('Error creating and sending notification: $e');
    }
  }
}
