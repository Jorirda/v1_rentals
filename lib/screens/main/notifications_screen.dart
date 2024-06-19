import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/models/notification_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/providers/auth_provider.dart';
import 'package:v1_rentals/providers/booking_provider.dart';
import 'package:v1_rentals/providers/notification_provider.dart';
import 'package:v1_rentals/screens/clients/client_booking_details.dart';
import 'package:v1_rentals/screens/vendors/vendor_booking_details.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:v1_rentals/widgets/shimmer_widget.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

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
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationProvider.markAsRead();
    });

    // Categorize notifications based on timestamp
    List<NotificationModel> newNotifications = [];
    List<NotificationModel> todayNotifications = [];
    List<NotificationModel> last7DaysNotifications = [];
    List<NotificationModel> last30DaysNotifications = [];

    // Group notifications
    for (var notification in notificationProvider.notifications) {
      final difference = DateTime.now().difference(notification.timestamp);

      if (difference.inHours < 24) {
        newNotifications.add(notification);
      } else if (notification.timestamp.day == DateTime.now().day) {
        todayNotifications.add(notification);
      } else if (difference.inDays < 7) {
        last7DaysNotifications.add(notification);
      } else if (difference.inDays < 30) {
        last30DaysNotifications.add(notification);
      }
    }

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
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildCategoryList(context, S.of(context).new_title, newNotifications,
              notificationProvider),
          _buildCategoryList(context, S.of(context).today, todayNotifications,
              notificationProvider),
          _buildCategoryList(context, S.of(context).last_7_days,
              last7DaysNotifications, notificationProvider),
          _buildCategoryList(context, S.of(context).last_30_days,
              last30DaysNotifications, notificationProvider),
        ],
      ),
    );
  }

  Widget _buildCategoryList(
      BuildContext context,
      String categoryTitle,
      List<NotificationModel> notifications,
      NotificationProvider notificationProvider) {
    if (notifications.isEmpty) {
      return SizedBox.shrink();
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            categoryTitle,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final leadingImageURL = currentUser?.userType == UserType.client
                ? notification.userImageURL
                : notification.userImageURL;

            return Dismissible(
              key: Key(notification.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (DismissDirection direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(S.of(context).confirm),
                      content: Text(S.of(context).confirm_delete_notification),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(S.of(context).cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(S.of(context).delete),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) {
                // This function will be called if the user confirms deletion in the AlertDialog
                notificationProvider.removeNotification(notification.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(S.of(context).notification_deleted)),
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(leadingImageURL ?? ''),
                  radius: 35,
                ),
                title: Text(
                  notification.title ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.body ?? ''),
                    Text(
                      timeAgo(context, notification.timestamp),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                trailing: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: notification.vehicleImageURL ?? '',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => ShimmerWidget(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                isThreeLine: true,
                onTap: () async {
                  await handleNotificationTap(context, notification);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  String timeAgo(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return S.of(context).just_now;
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${S.of(context).minutes_ago}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${S.of(context).hours_ago}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${S.of(context).days_ago}';
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return '${days} ${days == 1 ? S.of(context).days_ago : S.of(context).days_ago}';
    } else {
      final months = (difference.inDays / 30).floor();
      return '${months} ${months == 1 ? S.of(context).month_ago : S.of(context).months_ago}';
    }
  }

  Future<void> handleNotificationTap(
      BuildContext context, NotificationModel notification) async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    final currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser;

    Booking? booking =
        await bookingProvider.getBookingById(notification.bookingId);
    if (booking != null) {
      if (currentUser?.userType == UserType.client) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientBookingDetailsScreen(booking: booking),
          ),
        );
      } else if (currentUser?.userType == UserType.vendor) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorBookingDetailsScreen(booking: booking),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).error_fetching_bookings)),
      );
    }
  }
}
