import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:v1_rentals/locations/dropoff_location.dart';
import 'package:v1_rentals/locations/pickup_location.dart';
import 'package:v1_rentals/models/search_history_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/services/location_service.dart';
import 'package:v1_rentals/services/notification_service.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/services/auth_service.dart';

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

  final AuthService _authService = AuthService();

  final List<SearchHistory> _searchHistory =
      []; // Update to store SearchHistory objects

  final LocationService _locationService = LocationService();

  // TextEditingControllers for the locations
  late TextEditingController _pickupLocationController;
  late TextEditingController _dropoffLocationController;
  @override
  void initState() {
    super.initState();
    _pickupDate = widget.booking.pickupDate;
    _pickupTime = widget.booking.pickupTime;
    _dropoffDate = widget.booking.dropoffDate;
    _dropoffTime = widget.booking.dropoffTime;
    _pickupLocation = widget.booking.pickupLocation;
    _dropoffLocation = widget.booking.dropoffLocation;

    // Initialize TextEditingControllers with initial values
    _pickupLocationController = TextEditingController(text: _pickupLocation);
    _dropoffLocationController = TextEditingController(text: _dropoffLocation);

    _fetchSearchHistory();
  }

  @override
  void dispose() {
    // Dispose of the TextEditingControllers
    _pickupLocationController.dispose();
    _dropoffLocationController.dispose();
    super.dispose();
  }

  Future<void> _fetchSearchHistory() async {
    try {
      CustomUser? currentUser = await _authService.getCurrentUser();
      if (currentUser != null && currentUser.userId != null) {
        List<SearchHistory> searchHistory =
            await _locationService.getSearchHistory(currentUser.userId!);
        setState(() {
          _searchHistory
            ..clear()
            ..addAll(
                searchHistory.reversed); // Reverse the list and add all items
        });
      }
    } catch (e) {
      print('Error fetching search history: $e');
    }
  }

  Future<void> _selectPickupLocation(BuildContext context) async {
    // Navigate to SetPickupLocationScreen
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetPickupLocationScreen(
          historyLocations: _searchHistory,
        ),
      ),
    );

    if (selectedLocation != null) {
      print('Selected Pickup Location: $selectedLocation'); // Debug print
      setState(() {
        _pickupLocation = selectedLocation;
        _pickupLocationController.text = selectedLocation;
      });
    }
  }

  Future<void> _selectDropoffLocation(BuildContext context) async {
    // Navigate to SetDropoffLocationScreen
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetDropoffLocationScreen(
          historyLocations: _searchHistory,
        ),
      ),
    );

    if (selectedLocation != null) {
      print('Selected Dropoff Location: $selectedLocation'); // Debug print
      setState(() {
        _dropoffLocation = selectedLocation;
        _dropoffLocationController.text = selectedLocation;
      });
    }
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
            SectionTitle(title: 'Pick-up Date and Time'),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'Pick-up Date',
                    value: DateFormat('yyyy-MM-dd').format(_pickupDate),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _pickupDate,
                        firstDate: DateTime.now().isBefore(_pickupDate)
                            ? DateTime.now()
                            : _pickupDate,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && picked != _pickupDate) {
                        setState(() {
                          _pickupDate = picked;
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: CustomTextField(
                    labelText: 'Pick-up Time',
                    value: _pickupTime.format(context),
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
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            SectionTitle(title: 'Drop-off Date and Time'),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'Drop-off Date',
                    value: DateFormat('yyyy-MM-dd').format(_dropoffDate),
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
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: CustomTextField(
                    labelText: 'Drop-off Time',
                    value: _dropoffTime.format(context),
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
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            SectionTitle(title: 'Pickup and Drop-off Location'),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                      labelText: 'Pick-up Location',
                      controller: _pickupLocationController),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _selectPickupLocation(context),
                    icon: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'Drop-off Location',

                    controller:
                        _dropoffLocationController, // Use the controller
                    onTap: () => _selectDropoffLocation(context),
                    onChanged: (value) {
                      setState(() {
                        _dropoffLocation = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _selectDropoffLocation(context),
                    icon: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog();
                },
                child: Text('SAVE CHANGES'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
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

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? value;
  final Function()? onTap;
  final Function(String)? onChanged;

  final TextEditingController? controller;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.value,
    this.onTap,
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: onTap != null,
      controller: controller ??
          (value != null ? TextEditingController(text: value) : null),
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
      ),
    );
  }
}
