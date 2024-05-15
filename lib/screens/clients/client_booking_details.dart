import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:intl/intl.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/clients/edit_bookings.dart';
import 'package:v1_rentals/screens/main/car_details.dart';

class ClientBookingDetailsScreen extends StatefulWidget {
  final Booking booking;

  const ClientBookingDetailsScreen({Key? key, required this.booking})
      : super(key: key);

  @override
  _ClientBookingDetailsScreenState createState() =>
      _ClientBookingDetailsScreenState();
}

class _ClientBookingDetailsScreenState
    extends State<ClientBookingDetailsScreen> {
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

  // Method to update booking status
  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    try {
      await AuthService().updateBookingStatus(bookingId, status);
    } catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Details'),
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
                    'Status: ${widget.booking.status}'
                        .toString()
                        .split('.')
                        .last,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20),
                  ),

                  // Display vehicle image
                  SizedBox(
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
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                vendor?.businessName ?? 'Unknown Business Name',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('Booking ID: ${widget.booking.id}'),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Rental Vehicle: ${vehicleSnapshot['brand']}', // Example field from vehicle document
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
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
                                'Renter: ${client?.fullname}',
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
                          SizedBox(
                            height: 10,
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
                            'Rental Details',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),

                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text('Pick-up'),
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
                              Text('Drop-off'),
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
                              Text('Pick-up Location'),
                              Spacer(),
                              Text(
                                ' ${widget.booking.pickupLocation}',
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          // Display drop-off location
                          Row(
                            children: [
                              Text('Drop-off Location'),
                              Spacer(),
                              Text(
                                '${widget.booking.dropoffLocation}',
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
                            'Transaction Details',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),

                          SizedBox(height: 15),
                          // Display payment method
                          Row(
                            children: [
                              Text('Payment method'),
                              Spacer(),
                              Text(
                                '${widget.booking.paymentMethod}',
                              ),
                            ],
                          ),
                          // Display payment card information if available
                          if (widget.booking.paymentStatus) ...[
                            Text(
                              'Bank Card: - Visa ending in ${widget.booking.paymentMethod}', // Example field from booking model
                            ),
                          ],
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text('Booking Time'),
                              Spacer(),
                              Text(
                                '${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.booking.createdAt)}', // Specify the desired time format
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 30,
                          ),

                          Text(
                            'Amount Information',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 10,
                          ),

                          Row(
                            children: [
                              Text(
                                'Total Rental Price',
                              ),
                              Spacer(),
                              Text(
                                '\$ ${widget.booking.totalPrice.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),

                          Row(
                            children: [
                              Text(
                                'Other Services',
                              ),
                              Spacer(),
                              Text(
                                '\$ 0.00',
                              ),
                            ],
                          ),

                          Divider(),

                          Row(
                            children: [
                              Spacer(),
                              Text(
                                'Total Price: \$${widget.booking.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
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
                          title: Text('Cancel'),
                          content: Text(
                              'Are you sure you want to cancel this booking?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                // Update booking status to "cancelled"
                                await updateBookingStatus(
                                    widget.booking.id, BookingStatus.cancelled);
                                Navigator.of(context).pop();
                              },
                              child: Text('Confirm'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditBookingScreen(booking: widget.booking),
                      ),
                    );
                  },
                  child: Text('Edit'),
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
