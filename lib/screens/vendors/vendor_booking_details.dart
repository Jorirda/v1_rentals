import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/main/car_details.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/providers/booking_provider.dart';
import 'package:v1_rentals/widgets/shimmer_widget.dart';

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
  late Stream<Duration> _countdownStream;

  @override
  void initState() {
    super.initState();
    _vehicleFuture = AuthService().getVehicleDocument(widget.booking.vehicleId);
    _vendorFuture = AuthService().getUserData(widget.booking.vendorId);
    _clientFuture = AuthService().getUserData(widget.booking.userId);

    if (widget.booking.status == BookingStatus.accepted &&
        widget.booking.startTime != null) {
      _countdownStream = _startCountdownStream();
    }
  }

  Stream<Duration> _startCountdownStream() async* {
    final expirationTime = widget.booking.startTime!.add(Duration(minutes: 2));
    while (true) {
      final currentTime = DateTime.now();
      final timeLeft = expirationTime.difference(currentTime);
      if (timeLeft.isNegative) {
        _autoCancelBooking();
        break;
      }
      yield timeLeft;
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<void> _autoCancelBooking() async {
    await updateBookingStatus(widget.booking.id, BookingStatus.cancelled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking has been automatically cancelled.')),
    );
  }

  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    await Provider.of<BookingProvider>(context, listen: false)
        .updateBookingStatusAndNotify(
            bookingId, status, widget.booking.userId, widget.booking.vendorId);
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
                return Center(child: CircularProgressIndicator());
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

                  SizedBox(height: 20),
                  if (widget.booking.status == BookingStatus.accepted &&
                      widget.booking.startTime != null)
                    StreamBuilder<Duration>(
                      stream: _countdownStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final timeLeft = snapshot.data!;
                        final minutes = timeLeft.inMinutes;
                        final seconds = timeLeft.inSeconds % 60;

                        return Center(
                          child: Text(
                            'Time Remaining for Payment: ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s',
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          ),
                        );
                      },
                    ),

                  // Display vehicle image
                  SizedBox(height: 20),
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
                                    ? CachedNetworkImageProvider(
                                        vendor!.imageURL!)
                                    : null,
                              ),
                              SizedBox(width: 10),
                              Text(
                                ' ${widget.booking.vendorBusinessName}',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                              '${S.of(context).booking_id} : ${widget.booking.id}'),
                          SizedBox(height: 20),
                          Text(
                            '${S.of(context).rental_vehicle} : ${widget.booking.vehicleDescription}', // Example field from vehicle document
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
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
                                print(
                                    '${S.of(context).error_loading_vehicles}: $e');
                                // Handle error, e.g., show a snackbar or dialog
                              }
                            },
                            child: Container(
                              height: 200, // Adjust the height as needed
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: widget.booking.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Center(child: ShimmerWidget()),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

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
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Spacer(),
                              Text(
                                client?.phoneNum ?? 'Client Phone #',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Text(
                            client?.address ?? 'Client Address',
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 10),

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
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),

                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text(S.of(context).booking_time),
                              Spacer(),
                              Text(
                                '${DateFormat('yyyy-MM-dd').format(widget.booking.pickupDate)} at ${widget.booking.pickupTime.format(context)}',
                              ),
                            ],
                          ),
                          SizedBox(height: 15),

                          // Display drop-off date and time
                          Row(
                            children: [
                              Text(S.of(context).drop_off),
                              Spacer(),
                              Text(
                                ' ${DateFormat('yyyy-MM-dd').format(widget.booking.dropoffDate)} at ${widget.booking.dropoffTime.format(context)}',
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          // Display pick-up location
                          Row(
                            children: [
                              Text(S.of(context).pick_up_location),
                              Spacer(),
                              Flexible(
                                child: Text(
                                  ' ${widget.booking.pickupLocation}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          // Display drop-off location
                          Row(
                            children: [
                              Text(S.of(context).drop_off_location),
                              Spacer(),
                              Flexible(
                                child: Text(
                                  '${widget.booking.dropoffLocation}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Display pick-up date and time
                  SizedBox(height: 10),
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
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text(S.of(context).booking_time),
                              Spacer(),
                              Text(
                                '${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.booking.createdAt)}', // Specify the desired time format
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          Text(
                            S.of(context).amount_information,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text(S.of(context).total_price),
                              Spacer(),
                              Text(
                                '\$ ${widget.booking.totalPrice.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text(S.of(context).other_services),
                              Spacer(),
                              Text('\$ 0.00'),
                            ],
                          ),
                          Divider(),
                          Row(
                            children: [
                              Text(
                                "${S.of(context).total_price}: ", // Translate total price label
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              Spacer(),
                              Text(
                                'USD\$${widget.booking.totalPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 20),
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
        visible: widget.booking.status == BookingStatus.pending ||
            widget.booking.status == BookingStatus.inProgress,
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
                          title: Text(S.of(context).decline),
                          content: Text(S.of(context).confirm_decline_booking),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(S.of(context).cancel),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  // Update booking status to "cancelled" and send notifications
                                  await updateBookingStatus(widget.booking.id,
                                      BookingStatus.cancelled);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(S.of(context).booking_declined),
                                    ),
                                  );
                                } catch (e) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${S.of(context).error_declining_booking}: $e'),
                                    ),
                                  );
                                }
                              },
                              child: Text(S.of(context).confirm),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(S.of(context).decline),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                              widget.booking.status == BookingStatus.pending
                                  ? S.of(context).accept
                                  : S.of(context).complete),
                          content: Text(
                            'Are you sure you want to ${widget.booking.status == BookingStatus.pending ? S.of(context).accept : S.of(context).complete} this booking?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(S.of(context).cancel),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  // Update booking status and send notifications
                                  if (widget.booking.status ==
                                      BookingStatus.pending) {
                                    await updateBookingStatus(widget.booking.id,
                                        BookingStatus.accepted);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            S.of(context).booking_accepted),
                                      ),
                                    );
                                  } else if (widget.booking.status ==
                                      BookingStatus.inProgress) {
                                    await updateBookingStatus(widget.booking.id,
                                        BookingStatus.completed);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            S.of(context).booking_completed),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${S.of(context).error_processing_booking}: $e'),
                                    ),
                                  );
                                }
                              },
                              child: Text(S.of(context).confirm),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.booking.status == BookingStatus.pending
                            ? Theme.of(context).colorScheme.primary
                            : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(widget.booking.status == BookingStatus.pending
                      ? S.of(context).accept
                      : S.of(context).complete),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
