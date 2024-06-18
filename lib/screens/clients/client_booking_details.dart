import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/providers/booking_provider.dart';
import 'package:v1_rentals/screens/clients/edit_bookings.dart';
import 'package:v1_rentals/screens/main/car_details.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/widgets/stripe_payment.dart';
import 'package:intl/intl.dart';

class ClientBookingDetailsScreen extends StatefulWidget {
  final Booking booking;

  const ClientBookingDetailsScreen({Key? key, required this.booking});

  @override
  _ClientBookingDetailsScreenState createState() =>
      _ClientBookingDetailsScreenState();
}

class _ClientBookingDetailsScreenState
    extends State<ClientBookingDetailsScreen> {
  late Future<DocumentSnapshot> _vehicleFuture;
  late Future<CustomUser?> _vendorFuture;
  late Future<CustomUser?> _clientFuture;

  bool _isCancelLoading = false;
  bool _isConfirmLoading = false;

  @override
  void initState() {
    super.initState();
    _vehicleFuture = AuthService().getVehicleDocument(widget.booking.vehicleId);
    _vendorFuture = AuthService().getUserData(widget.booking.vendorId);
    _clientFuture = AuthService().getUserData(widget.booking.userId);
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
        title: Text(S.of(context).booking_details),
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
                              SizedBox(width: 10),
                              Text(
                                vendor?.businessName ?? "",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                              '${S.of(context).booking_id}: ${widget.booking.id}'),
                          SizedBox(height: 20),
                          Text(
                            '${S.of(context).rental_vehicle}: ${widget.booking.vehicleDescription}',
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
                              Text(
                                '${S.of(context).renter}: ${client?.fullname}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Spacer(),
                              Text(
                                client?.phoneNum ?? "",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Text(
                            client?.address ?? "",
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
                              Text(S.of(context).pick_up),
                              Spacer(),
                              Text(
                                '${DateFormat('yyyy-MM-dd').format(widget.booking.pickupDate)} at ${widget.booking.pickupTime.format(context)}',
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
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
                          Row(
                            children: [
                              Text(S.of(context).pick_up_location),
                              Spacer(),
                              Flexible(
                                child: Text(
                                  widget.booking.pickupLocation,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text(S.of(context).drop_off_location),
                              Spacer(),
                              Flexible(
                                child: Text(
                                  widget.booking.dropoffLocation,
                                ),
                              ),
                            ],
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
                          const SizedBox(height: 30),
                          Text(
                            S.of(context).amount_information,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(S.of(context).total_rental_price),
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
            widget.booking.status == BookingStatus.inProgress ||
            widget.booking.status == BookingStatus.accepted,
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
                          title: Text(S.of(context).cancel),
                          content: Text(S.of(context).confirm),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(S.of(context).cancel),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Update booking status to "cancelled"
                                await updateBookingStatus(
                                    widget.booking.id, BookingStatus.cancelled);
                                Navigator.of(context).pop();
                              },
                              child: Text(S.of(context).confirm),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text(S.of(context).cancel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.booking.status == BookingStatus.accepted) {
                      try {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Prevent dialog dismissal on tap outside
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 20),
                                  Text(
                                      'Please wait while we prepare the payment...')
                                ],
                              ),
                            );
                          },
                        );

                        await PaymentHandler().createStripeCustomer(
                          context,
                          widget.booking.id,
                          widget.booking.totalPrice,
                        );

                        // Close the dialog after payment processing completes
                        Navigator.of(context).pop();
                      } catch (e) {
                        print("Error creating Stripe customer: $e");
                        // Handle error or show error message
                        Navigator.of(context)
                            .pop(); // Dismiss the dialog on error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditBookingScreen(booking: widget.booking),
                        ),
                      );
                    }
                  },
                  child: Text(
                    widget.booking.status == BookingStatus.accepted
                        ? S.of(context).pay_now
                        : S.of(context).edit,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
