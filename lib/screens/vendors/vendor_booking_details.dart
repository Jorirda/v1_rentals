import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/auth/notification_service.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/main/car_details.dart';
import 'package:v1_rentals/generated/l10n.dart';

class VendorBookingDetailsScreen extends StatefulWidget {
  final Booking booking;

  const VendorBookingDetailsScreen({super.key, required this.booking});

  @override
  _VendorBookingDetailsScreenState createState() =>
      _VendorBookingDetailsScreenState();
}

class _VendorBookingDetailsScreenState
    extends State<VendorBookingDetailsScreen> {
  late Future<DocumentSnapshot> _vehicleFuture;
  late Future<CustomUser?> _vendorFuture;
  late Future<CustomUser?> _clientFuture;

  @override
  void initState() {
    super.initState();
    _vehicleFuture = AuthService().getVehicleDocument(widget.booking.vehicleId);
    _vendorFuture = AuthService().getUserData(widget.booking.vendorId);
    _clientFuture = AuthService().getUserData(widget.booking.userId);
  }

  // Method to update booking status and send notifications
  Future<void> updateBookingStatusAndNotify(
      String bookingId, BookingStatus status) async {
    try {
      await AuthService().updateBookingStatus(bookingId, status);

      // Send notifications to user and vendor upon confirming cancel or accepting booking
      if (status == BookingStatus.cancelled ||
          status == BookingStatus.inProgress) {
        String userTitle = '';
        String userBody = '';
        String vendorTitle = '';
        String vendorBody = '';

        if (status == BookingStatus.cancelled) {
          userTitle = 'Booking Declined';
          userBody = 'Your booking has been declined by the vendor.';
          vendorTitle = 'Booking Declined';
          vendorBody = 'You have declined the booking.';
        } else if (status == BookingStatus.inProgress) {
          userTitle = 'Booking Accepted';
          userBody = 'Your booking has been accepted by the vendor.';
          vendorTitle = 'Booking Accepted';
          vendorBody = 'You have accepted the booking.';
        }

        await pushNotificationService.sendNotification(
            userTitle,
            userBody,
            (await AuthService().getUserData(widget.booking.userId))
                    .fcmToken ??
                '');
        await pushNotificationService.sendNotification(
            vendorTitle,
            vendorBody,
            (await AuthService().getUserData(widget.booking.vendorId))
                    .fcmToken ??
                '');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).my_bookings),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder(
            future: Future.wait([_vehicleFuture, _vendorFuture, _clientFuture]),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              // Extract vehicle and vendor information
              DocumentSnapshot vehicleSnapshot =
                  snapshot.data![0] as DocumentSnapshot;
              CustomUser? vendor = snapshot.data![1] as CustomUser?;
              CustomUser? client = snapshot.data![2] as CustomUser?;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.booking.getBookingStatusString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20),
                  ),

                  // Display vehicle image
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey,
                                backgroundImage: vendor?.imageURL != null
                                    ? NetworkImage(vendor!.imageURL!)
                                    : null,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                ' ${widget.booking.vendorBusinessName}',
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                              '${S.of(context).booking_id} : ${widget.booking.id}'),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            '${S.of(context).rental_vehicle} : ${vehicleSnapshot['brand']}', // Example field from vehicle document
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () async {
                              try {
                                DocumentSnapshot vehicleSnapshot =
                                    await AuthService().getVehicleDocument(
                                        widget.booking.vehicleId);
                                Vehicle vehicle =
                                    Vehicle.fromMap(vehicleSnapshot);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CarDetailsScreen(vehicle)),
                                );
                              } catch (e) {
                                print('Error fetching vehicle details: $e');
                                // Handle error, e.g., show a snackbar or dialog
                              }
                            },
                            child: Container(
                              height: 200, // Adjust the height as needed
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(widget.booking.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Display renter
                              Text(
                                '${S.of(context).renter} : ${client?.fullname}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Text(
                                client?.phoneNum ?? 'Client Phone #',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Text(
                            client?.address ?? 'Client Address',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).rental_details,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(S.of(context).booking_time),
                              const Spacer(),
                              Text(
                                '${DateFormat('yyyy-MM-dd').format(widget.booking.pickupDate)} at ${widget.booking.pickupTime.format(context)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // Display drop-off date and time
                          Row(
                            children: [
                              Text(S.of(context).drop_off),
                              const Spacer(),
                              Text(
                                ' ${DateFormat('yyyy-MM-dd').format(widget.booking.dropoffDate)} at ${widget.booking.dropoffTime.format(context)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Display pick-up location
                          Row(
                            children: [
                              Text(S.of(context).pick_up_location),
                              const Spacer(),
                              Text(
                                ' ${widget.booking.pickupLocation}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Display drop-off location
                          Row(
                            children: [
                              Text(S.of(context).drop_off_location),
                              const Spacer(),
                              Text(
                                widget.booking.dropoffLocation,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Display pick-up date and time
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).transaction_details,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 15),
                          // Display payment method
                          Row(
                            children: [
                              Text(S.of(context).payment_method),
                              const Spacer(),
                              Text(
                                widget.booking.paymentMethod,
                              ),
                            ],
                          ),
                          // Display payment card information if available
                          if (widget.booking.paymentStatus) ...[
                            Text(
                              'Bank Card: - Visa ending in ${widget.booking.paymentMethod}', // Example field from booking model
                            ),
                          ],
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(S.of(context).booking_time),
                              const Spacer(),
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.booking.createdAt), // Specify the desired time format
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Text(
                            S.of(context).amount_information,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(S.of(context).total_price),
                              const Spacer(),
                              Text(
                                '\$ ${widget.booking.totalPrice.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Text(S.of(context).other_services),
                              const Spacer(),
                              const Text('\$ 0.00'),
                            ],
                          ),
                          const Divider(),
                          Row(
                            children: [
                              const Spacer(),
                              Text(
                                '${S.of(context).total_rental_price} : \$${widget.booking.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: Visibility(
        visible: widget.booking.status == BookingStatus.pending,
        child: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Decline'),
                          content: const Text(
                              'Are you sure you want to decline this booking?'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  // Update booking status to "cancelled" and send notifications
                                  await updateBookingStatusAndNotify(
                                      widget.booking.id,
                                      BookingStatus.cancelled);
                                } catch (e) {
                                  // Handle error, e.g., show a snackbar or dialog
                                  print('Error declining booking: $e');
                                }
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm'),
                          content: const Text(
                              'Are you sure you want to accept this booking?'),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  // Update booking status to "inProgress" and send notifications
                                  await updateBookingStatusAndNotify(
                                      widget.booking.id,
                                      BookingStatus.inProgress);
                                } catch (e) {
                                  // Handle error, e.g., show a snackbar or dialog
                                  print('Error accepting booking: $e');
                                }
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
