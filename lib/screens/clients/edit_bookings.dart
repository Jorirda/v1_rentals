import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:v1_rentals/auth/push_notifications.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/auth/auth_service.dart';

class EditBookingScreen extends StatefulWidget {
  final Booking booking;

  const EditBookingScreen({Key? key, required this.booking}) : super(key: key);

  @override
  _EditBookingScreenState createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends State<EditBookingScreen> {
  late DateTime _pickupDate;
  late TimeOfDay _pickupTime;
  late DateTime _dropoffDate;
  late TimeOfDay _dropoffTime;
  late String _pickupLocation;
  late String _dropoffLocation;

  @override
  void initState() {
    super.initState();
    _pickupDate = widget.booking.pickupDate;
    _pickupTime = widget.booking.pickupTime;
    _dropoffDate = widget.booking.dropoffDate;
    _dropoffTime = widget.booking.dropoffTime;
    _pickupLocation = widget.booking.pickupLocation;
    _dropoffLocation = widget.booking.dropoffLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Booking'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pick-up Date and Time'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(_pickupDate),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _pickupDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != _pickupDate) {
                        setState(() {
                          _pickupDate = picked;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Pick-up Date',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: _pickupTime.format(context),
                    ),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _pickupTime,
                      );
                      if (picked != null && picked != _pickupTime) {
                        setState(() {
                          _pickupTime = picked;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Pick-up Time',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text('Drop-off Date and Time'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(_dropoffDate),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _dropoffDate,
                        firstDate: _pickupDate,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != _dropoffDate) {
                        setState(() {
                          _dropoffDate = picked;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Drop-off Date',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: _dropoffTime.format(context),
                    ),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _dropoffTime,
                      );
                      if (picked != null && picked != _dropoffTime) {
                        setState(() {
                          _dropoffTime = picked;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Drop-off Time',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextFormField(
              initialValue: _pickupLocation,
              onChanged: (value) {
                setState(() {
                  _pickupLocation = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Pick-up Location',
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              initialValue: _dropoffLocation,
              onChanged: (value) {
                setState(() {
                  _dropoffLocation = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Drop-off Location',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _showConfirmationDialog();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show the confirmation dialog
  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Update'),
          content: Text('Are you sure you want to update this booking?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // User confirmed, update the booking
                _updateBooking();
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  // Method to update the booking in Firestore
  void _updateBooking() async {
    // Update the booking object with the modified details
    Booking updatedBooking = Booking(
      id: widget.booking.id,
      // Copy the existing data and update the modified fields
      pickupDate: _pickupDate,
      pickupTime: _pickupTime,
      dropoffDate: _dropoffDate,
      dropoffTime: _dropoffTime,
      pickupLocation: _pickupLocation,
      dropoffLocation: _dropoffLocation,
      status: widget.booking.status,
      paymentMethod: widget.booking.paymentMethod,
      paymentStatus: widget.booking.paymentStatus,
      totalPrice: widget.booking.totalPrice,
      createdAt: widget.booking.createdAt,
      userId: widget.booking.userId,
      vehicleId: widget.booking.vehicleId,
      vendorId: widget.booking.vendorId,
      imageUrl: widget.booking.imageUrl,
      userFullName: widget.booking.userFullName,
      vehicleDescription: widget.booking.vehicleDescription,
      vendorBusinessName: widget.booking.vendorBusinessName,
      clientImageURL: widget.booking.clientImageURL,
      vendorImageURL: widget.booking.vendorImageURL,
    );

    // Update the booking in Firestore
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.booking.id)
          .update(updatedBooking.toMap()); // Update the booking data

      // Send notifications
      String userTitle = 'Booking Updated';
      String userBody = 'Your booking details have been updated.';
      String vendorTitle = 'Booking Updated';
      String vendorBody = 'A booking has been updated by the user.';

      await pushNotificationService.sendNotification(
          userTitle,
          userBody,
          (await AuthService().getUserData(widget.booking.userId))?.fcmToken ??
              '');
      await pushNotificationService.sendNotification(
          vendorTitle,
          vendorBody,
          (await AuthService().getUserData(widget.booking.vendorId))
                  ?.fcmToken ??
              '');

      // Show a success message, navigate back, or perform any other action
      print('Booking updated successfully!');
    } catch (e) {
      // Handle errors, such as displaying an error message
      print('Error updating booking: $e');
      // Show an error message to the user
      // You can use a snackbar, toast, or another method to display the error
    }
  }
}
