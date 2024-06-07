import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/providers/auth_provider.dart';
import 'package:v1_rentals/providers/booking_provider.dart';
import 'package:v1_rentals/providers/notification_provider.dart';
import 'package:v1_rentals/screens/clients/client_booking_details.dart';
import 'package:v1_rentals/screens/vendors/vendor_booking_details.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  Future<Booking?> fetchBooking(BuildContext context, String bookingId) async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    try {
      Booking? booking = await bookingProvider.getBookingById(bookingId);
      return booking;
    } catch (e) {
      print('Error fetching booking: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationProvider.markAsRead();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('${S.of(context).notifications}\u{1F514}'),
        actions: [
          TextButton(
            onPressed: () {
              notificationProvider.markAsRead();
            },
            child: Text(
              S.of(context).mark_as_read,
              style: TextStyle(),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notificationProvider.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationProvider.notifications[index];
          final leadingImageURL = currentUser?.userType == UserType.client
              ? notification.userImageURL
              : notification.userImageURL;

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(leadingImageURL),
              radius: 35,
            ),
            title: Text(
              notification.title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.body),
                Text(
                  timeAgo(notification.timestamp),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            trailing: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: notification.vehicleImageURL,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            isThreeLine: true,
            onTap: () async {
              Booking? booking =
                  await fetchBooking(context, notification.bookingId);
              if (booking != null) {
                if (currentUser?.userType == UserType.client) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ClientBookingDetailsScreen(booking: booking),
                    ),
                  );
                } else if (currentUser?.userType == UserType.vendor) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VendorBookingDetailsScreen(booking: booking),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error fetching booking details')),
                );
              }
            },
          );
        },
      ),
    );
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
