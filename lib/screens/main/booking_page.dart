import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/services/email_service.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/models/search_history_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:intl/intl.dart';
import 'package:v1_rentals/locations/dropoff_location.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/services/location_service.dart';
import 'package:v1_rentals/locations/pickup_location.dart';
import 'package:v1_rentals/services/notification_service.dart';
import 'package:v1_rentals/widgets/custom_stepper.dart';

class BookingScreen extends StatefulWidget {
  final Vehicle vehicle;

  const BookingScreen(this.vehicle, {super.key});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Booking booking; // Declare booking model variable
  TextEditingController pickupLocationController = TextEditingController();
  TextEditingController dropoffLocationController = TextEditingController();
  int currentStep = 0;
  bool setSameLocation = false;

  String? vendorBusinessName;

  String? vendorEmail;
  String? userFullName;

  final AuthService _authService = AuthService();

  final List<SearchHistory> _searchHistory =
      []; // Update to store SearchHistory objects

  final LocationService _locationService = LocationService();
  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final DateTime initialPickupDate = DateTime(now.year, now.month, now.day);
    final DateTime initialDropoffDate =
        initialPickupDate.add(Duration(days: 1));
    booking = Booking(
      id: FirebaseFirestore.instance.collection('bookings').doc().id,
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      userEmail: FirebaseAuth.instance.currentUser?.email,
      userFullName: '', // You will need to fetch this value
      vehicleId: widget.vehicle.id,
      vehicleDescription:
          '${widget.vehicle.brand.getTranslation()} ${widget.vehicle.model} ${widget.vehicle.modelYear}',
      vendorId: widget.vehicle.vendorId,
      vendorEmail: '', // You will need to fetch this value
      vendorBusinessName: '', // You will need to fetch this value
      vendorContactInformation: '', // You will need to fetch this value
      pickupDate: initialPickupDate,
      pickupTime: TimeOfDay.fromDateTime(DateTime.now()),
      dropoffDate: initialDropoffDate,
      dropoffTime:
          TimeOfDay.fromDateTime(DateTime.now().add(Duration(days: 1))),
      pickupLocation: '',
      dropoffLocation: '',
      totalPrice: widget.vehicle.pricePerDay,
      imageUrl: widget.vehicle.imageUrl,
      status: BookingStatus.pending,

      createdAt: DateTime.now(),
      clientImageURL: '',
      vendorImageURL: '',
    );

    fetchUserData(); // Fetch user data including full name
    fetchVendorInformation(widget.vehicle
        .vendorId); // Fetch vendor information by passing vehicle vendorId
    _fetchSearchHistory();
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    final int differenceInDays =
        booking.dropoffDate.difference(booking.pickupDate).inDays;
    setState(() {
      booking.totalPrice = differenceInDays * widget.vehicle.pricePerDay;
      print(differenceInDays);
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    pickupLocationController.dispose();
    dropoffLocationController.dispose();
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
      _showError('Error fetching search history: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
      setState(() {
        pickupLocationController.text = selectedLocation;
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
      setState(() {
        dropoffLocationController.text = selectedLocation;
      });
    }
  }

  // Fetch user data including full name
  void fetchUserData() async {
    try {
      CustomUser? user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          booking.userFullName = user.fullname;
          booking.clientImageURL = user.imageURL!;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchVendorInformation(String? vendorId) async {
    try {
      if (vendorId != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(vendorId)
            .get();

        if (userSnapshot.exists) {
          CustomUser vendor =
              CustomUser.fromMap(userSnapshot.data() as Map<String, dynamic>?);
          setState(() {
            booking.vendorBusinessName = vendor.businessName!;
            booking.vendorEmail = vendor.email;
            booking.vendorImageURL = vendor.imageURL!;
          });
        }
      }
    } catch (e) {
      print('Error fetching vendor information: $e');
    }
  }

  List<Step> getSteps() {
    return [
      Step(
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 0,
        title: Text(
          S.of(context).reserve,
        ),
        content: Center(
          child: SingleChildScrollView(
            // Use SingleChildScrollView to handle overflow
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_up,
                      color: Colors.red,
                      size: 30,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      S.of(context).pick_up,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.date_range,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        S.of(context).pickup_date,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        '${booking.pickupDate.day}/${booking.pickupDate.month}/${booking.pickupDate.year}',
                      ),
                      onTap: () => _selectPickupDate(context),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.access_time,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        S.of(context).pickup_time,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize:
                              20, // Increase the font size of the time text
                        ),
                      ),
                      subtitle: Text(
                        '${booking.pickupTime.hour}:${booking.pickupTime.minute}',
                      ),
                      onTap: () => _selectPickupTime(context),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Divider(),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_circle_down,
                      color: Colors.red,
                      size: 30,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      S.of(context).drop_off,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            30, // Increase the font size of the drop-off text
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.date_range,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        S.of(context).dropoff_date,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        '${booking.dropoffDate.day}/${booking.dropoffDate.month}/${booking.dropoffDate.year}',
                      ),
                      onTap: () => _selectDropoffDate(context),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.access_time,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        S.of(context).dropoff_time,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        '${booking.dropoffTime.hour}:${booking.dropoffTime.minute}',
                      ),
                      onTap: () => _selectDropoffTime(context),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: Text(
          S.of(context).locations,
        ),
        content: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      S.of(context).locations,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  S.of(context).pick_up_location,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: S.of(context).enter_pickup_location,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        controller: pickupLocationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).enter_pickup_location;
                          }
                          return null;
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
                        onPressed: () => _selectPickupLocation(context),
                        icon: const Icon(
                          Icons.my_location,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Text(
                  S.of(context).drop_off_location,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: S.of(context).enter_dropoff_location,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        controller: dropoffLocationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).enter_dropoff_location;
                          }
                          return null;
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
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: setSameLocation,
                      onChanged: (value) {
                        setState(() {
                          setSameLocation = value!;
                          if (setSameLocation) {
                            if (pickupLocationController.text.isEmpty &&
                                dropoffLocationController.text.isNotEmpty) {
                              pickupLocationController.text =
                                  dropoffLocationController.text;
                            } else if (dropoffLocationController.text.isEmpty &&
                                pickupLocationController.text.isNotEmpty) {
                              dropoffLocationController.text =
                                  pickupLocationController.text;
                            }
                          }
                        });
                      },
                    ),
                    Flexible(
                      child: Text(S.of(context).set_pickup_drop_off,
                          style: TextStyle(fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2
                          // Adjust font size for better readability
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      Step(
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 2,
        title: Text(S.of(context).summary),
        content: _buildSummaryWidget(),
      ),
    ];
  }

  // Method to generate the summary widget
  Widget _buildSummaryWidget() {
    return Column(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      S.of(context).summary,
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.notes,
                      size: 30,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(),
                // Display vehicle image
                Container(
                  height: 200, // Adjust the height as needed
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: widget.vehicle.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Divider(),
                const SizedBox(height: 10),
                // Display car name
                Row(
                  children: [
                    Text(
                      '${S.of(context).rental_vehicle}:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        '${widget.vehicle.brand.getTranslation()} ${widget.vehicle.model} ${widget.vehicle.modelYear}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '${S.of(context).rental_supplier}: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(booking.vendorBusinessName)
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '${S.of(context).renter}: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    Text(booking.userFullName)
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                // Display pick-up date and time
                Row(
                  children: [
                    Text(
                      '${S.of(context).pick_up}: ',
                    ),
                    Spacer(),
                    Text(
                        '${DateFormat('yyyy-MM-dd').format(booking.pickupDate)} at ${booking.pickupTime.format(context)}')
                  ],
                ),
                const SizedBox(height: 5),
                // Display drop-off date and time
                Row(
                  children: [
                    Text(
                      '${S.of(context).drop_off}: ',
                    ),
                    Spacer(),
                    Text(
                        '${DateFormat('yyyy-MM-dd').format(booking.dropoffDate)} at ${booking.dropoffTime.format(context)}'),
                  ],
                ),
                const SizedBox(height: 5),
                // Display pick-up location
                Row(
                  children: [
                    Text(
                      '${S.of(context).pick_up_location}:',
                    ),
                    Spacer(),
                    Flexible(
                        child: Text(' ${pickupLocationController.text}',
                            overflow: TextOverflow.ellipsis, maxLines: 3)),
                  ],
                ),
                const SizedBox(height: 5),
                // Display drop-off location
                Row(
                  children: [
                    Text(
                      '${S.of(context).drop_off_location}: ',
                    ),
                    Spacer(),
                    Flexible(
                      child: Text(dropoffLocationController.text,
                          overflow: TextOverflow.ellipsis, maxLines: 3),
                    ),
                  ],
                ),

                Divider(),
                // Display total price
                Row(
                  children: [
                    Text(
                      '${S.of(context).total_price}: ',
                    ),
                    Spacer(),
                    Text(
                      'USD\$${booking.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 20),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        CheckboxListTile(
          title: Text(S.of(context).accept_terms),
          value: true,
          onChanged: (bool? value) {
            // Handle acceptance of terms
          },
        ),
      ],
    );
  }

  // Date and Time Selection Methods
  Future<void> _selectPickupDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: booking.pickupDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != booking.pickupDate) {
      setState(() {
        booking.pickupDate = picked;
        // Ensure dropoff date is after pickup date
        if (!picked.isBefore(booking.dropoffDate)) {
          booking.dropoffDate = picked.add(Duration(days: 1));
        }
      });
      _calculateTotalPrice();
    }
  }

  Future<void> _selectDropoffDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: booking.dropoffDate,
      firstDate: booking.pickupDate.add(Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != booking.dropoffDate) {
      setState(() {
        booking.dropoffDate = picked;
      });
      _calculateTotalPrice();
    }
  }

  Future<void> _selectPickupTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: booking.pickupTime,
    );
    if (picked != null && picked != booking.pickupTime) {
      setState(() {
        booking.pickupTime = picked;
      });
    }
  }

  Future<void> _selectDropoffTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: booking.dropoffTime,
    );
    if (picked != null && picked != booking.dropoffTime) {
      setState(() {
        booking.dropoffTime = picked;
      });
    }
  }

  Future<void> _showProcessingDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Processing your booking...'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == getSteps().length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).book_your_vehicle),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        steps: getSteps(),
        currentStep: currentStep,
        onStepContinue: () {
          final isLastStep = currentStep == getSteps().length - 1;
          if (isLastStep) {
            print('Completed');
            //send data to firebase
            sendBookingDataToFirebase(booking);
          } else {
            setState(() {
              if (currentStep < getSteps().length - 1) {
                currentStep++;
              }
            });
          }
        },
        onStepCancel: () {
          currentStep == 0
              ? null
              : setState(() {
                  if (currentStep > 0) {
                    currentStep--;
                  }
                });
        },
        onStepTapped: (step) {
          setState(() {
            currentStep = step;
          });
        },
        controlsBuilder: (context, details) {
          return Container();
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          child: CustomStepperControls(
            currentStep: currentStep,
            onStepContinue: () async {
              final isLastStep = currentStep == getSteps().length - 1;
              if (isLastStep) {
                final shouldSend = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(S.of(context).confirm_booking),
                      content: Text(S.of(context).confirm_booking_dialog),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(S.of(context).cancel),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text(S.of(context).confirm),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (shouldSend == true) {
                  _showProcessingDialog(context);
                  // send data to firebase
                  await sendBookingDataToFirebase(booking);
                  Navigator.of(context).pop(); // Close the processing dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Booking completed!')),
                  );
                }
              } else {
                setState(() {
                  if (currentStep < getSteps().length - 1) {
                    currentStep++;
                  }
                });
              }
            },
            onStepCancel: () {
              setState(() {
                if (currentStep > 0) {
                  currentStep--;
                }
              });
            },
            isLastStep: currentStep == getSteps().length - 1,
          ),
        ),
      ),
    );
  }

  Future<void> sendBookingDataToFirebase(Booking booking) async {
    try {
      // Get a reference to the Firestore collection for bookings
      CollectionReference bookingsCollection =
          FirebaseFirestore.instance.collection('bookings');

      // Generate a new booking ID
      String bookingId = bookingsCollection.doc().id;

      // Set the booking ID and other details in the booking object
      booking.id = bookingId;

      booking.pickupLocation = pickupLocationController.text;
      booking.dropoffLocation = dropoffLocationController.text;

      // Add the booking with the explicitly set ID to the "bookings" collection
      await bookingsCollection.doc(bookingId).set(booking.toMap());

      // Add references to this booking in the client's and vendor's "bookings" subcollections
      await FirebaseFirestore.instance
          .collection('users')
          .doc(booking.userId)
          .collection('bookings')
          .doc(bookingId)
          .set({'bookingId': bookingId});

      await FirebaseFirestore.instance
          .collection('users')
          .doc(booking.vendorId)
          .collection('bookings')
          .doc(bookingId)
          .set({'bookingId': bookingId});

      // Fetch user and vendor images
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(booking.userId)
          .get();
      DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(booking.vendorId)
          .get();

      String userImageURL = userSnapshot['imageURL'] ?? '';
      String vendorImageURL = vendorSnapshot['imageURL'] ?? '';

      // Create and send notifications for the initial booking request status
      await pushNotificationService.createAndSendNotification(
        booking.userId,
        booking.vendorId,
        bookingId,
        userImageURL,
        vendorImageURL,
        booking.imageUrl,
        'sent',
      );

      // Send booking confirmation emails to user and vendor
      EmailService emailService = EmailService();
      await emailService.sendBookingEmails(
        booking,
      );

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking successfully saved.'),
          backgroundColor: Colors.green,
        ),
      );

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email successfully sent.'),
          backgroundColor: Colors.green,
        ),
      );

      // Close the page
      Navigator.of(context).pop();
    } catch (e) {
      print('Error sending booking data to Firebase: $e');
      // Show error message if booking data couldn't be saved
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save booking. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
