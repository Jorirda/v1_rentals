import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/auth/push_notifications.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/location/search_history_model.dart';
import 'package:v1_rentals/models/payment_card_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/account/payment_overviews/add_payment_card.dart';
import 'package:intl/intl.dart';
import 'package:v1_rentals/widgets/dropoff_location.dart';

import 'package:v1_rentals/widgets/location_service.dart';
import 'package:v1_rentals/widgets/pickup_location.dart';

enum PaymentMethod {
  Card,
  PayPal,
  ApplePay,
  GooglePay,
}

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
  List<PaymentCard> userCards = []; // List to hold user's payment cards
  PaymentMethod? _selectedPaymentMethod;
  PaymentCard? _selectedPaymentCard;

  String? vendorBusinessName;
  String? userFullName;

  final AuthService _authService = AuthService();

  final List<SearchHistory> _searchHistory =
      []; // Update to store SearchHistory objects

  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    // Initialize booking model with default values or empty
    booking = Booking(
      userId: FirebaseAuth.instance.currentUser?.uid ??
          '', // Initialize with current user's ID if available
      vehicleId: widget.vehicle.id,
      vendorId: widget.vehicle.vendorId,
      pickupDate: DateTime.now(), // Initialize with current date/time
      dropoffDate: DateTime.now().add(Duration(days: 1)),
      id: FirebaseFirestore.instance.collection('bookings').doc().id,
      createdAt: DateTime.now(), // Initialize createdAt with current time
      pickupTime: TimeOfDay.fromDateTime(
          DateTime.now()), // Initialize with current time of day
      dropoffTime: TimeOfDay.fromDateTime(
          DateTime.now()), // Initialize with current time of day
      pickupLocation: '',
      dropoffLocation: '',
      totalPrice: widget.vehicle.pricePerDay,
      imageUrl: widget.vehicle.imageUrl,
      status: BookingStatus.pending,
      paymentStatus: false,
      paymentMethod: PaymentMethod.Card.toString(),
    );

    fetchUserPaymentCards(); // Fetch user's payment cards when the screen initializes
    fetchUserData(); // Fetch user data including full name
    fetchVendorInformation(widget.vehicle
        .vendorId); // Fetch vendor information by passing vehicle vendorId
    _fetchSearchHistory();
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
          userFullName = user.fullname;
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
            vendorBusinessName = vendor.businessName;
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
        title: Text('Reserve'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.arrow_circle_up,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'PICK-UP',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListTile(
                    leading: Icon(
                      Icons.date_range,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      'Pick-up Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${booking.pickupDate.day}/${booking.pickupDate.month}/${booking.pickupDate.year}',
                    ),
                    onTap: () => _selectPickupDate(context),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: Icon(Icons.access_time,
                        color: Theme.of(context).colorScheme.primary),
                    title: Text(
                      'Pick-up Time',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15.9),
                    ),
                    subtitle: Text(
                      '${booking.pickupTime.hour}:${booking.pickupTime.minute}',
                    ),
                    onTap: () => _selectPickupTime(context),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Icon(
                  Icons.arrow_circle_down,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'DROP-OFF',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListTile(
                    leading: Icon(
                      Icons.date_range,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      'Drop-off Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${booking.dropoffDate.day}/${booking.dropoffDate.month}/${booking.dropoffDate.year}',
                    ),
                    onTap: () => _selectDropoffDate(context),
                  ),
                ),
                // SizedBox(width: 16), // Add space between date and time pickers
                Expanded(
                  child: ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      'Drop-off Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${booking.dropoffTime.hour}:${booking.dropoffTime.minute}',
                    ),
                    onTap: () => _selectDropoffTime(context),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Location',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Pick-up Location',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, // Adjust font size for better readability
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
                      hintText: 'Enter pick-up location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: pickupLocationController,
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
                height:
                    20), // Add spacing between pick-up and drop-off sections
            const Text(
              'Drop-off Location',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16, // Adjust font size for better readability
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
                      hintText: 'Enter drop-off location',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: dropoffLocationController,
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
            Row(
              children: [
                Checkbox(
                  value: setSameLocation,
                  onChanged: (value) {
                    setState(() {
                      setSameLocation = value!;
                    });
                  },
                ),
                Text(
                  'Set pick-up and drop-off as the same location',
                ),
              ],
            ),
          ],
        ),

        // Your widget for Step 1, such as a DatePicker for pickup date and time,
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: const Text('Payment'),
        content: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Total: USD\$150.00',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Choose a payment method',
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your credit and debit cards',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        if (userCards.isNotEmpty) ...[
                          // Display radio tiles for user's payment cards
                          ...userCards
                              .map((card) => buildPaymentCardRadioTile(card)),
                        ] else ...[
                          Center(
                            child: Text('No cards found'),
                          ),
                        ],
                        // Display default option for adding a new card if no cards are available
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddPaymentCardScreen(),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.credit_card,
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Add a credit or debit card',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.navigate_next,
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                child:
                                    Image.asset('assets/images/visa_icon.png'),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                child: Image.asset(
                                    'assets/images/mastercard_icon.png'),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Other payment methods',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(),
                        // ListView for other payment methods
                        Column(
                          children: [
                            // PayPal payment option
                            RadioListTile<PaymentMethod>(
                              title: Text(
                                'PayPal',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              value: PaymentMethod.PayPal,
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                  _selectedPaymentCard = null;
                                });
                              },
                              secondary:
                                  Image.asset('assets/images/paypal_icon.png'),
                            ),
                            // Apple Pay payment option
                            RadioListTile<PaymentMethod>(
                              title: Text(
                                'Apple Pay',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              value: PaymentMethod.ApplePay,
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                  _selectedPaymentCard = null;
                                });
                              },
                              secondary: Image.asset(
                                  'assets/images/apple_pay_icon.png'),
                            ),
                            // Google Pay payment option
                            RadioListTile<PaymentMethod>(
                              title: Text(
                                'Google Pay',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              value: PaymentMethod.GooglePay,
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value;
                                  _selectedPaymentCard = null;
                                });
                              },
                              secondary: Image.asset(
                                  'assets/images/google_pay_icon.png'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      Step(
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 2,
        title: const Text('Summary'),
        content: _buildSummaryWidget(),
      ),
    ];
  }

  Future<void> fetchUserPaymentCards() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Fetch user's cards from Firestore
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cards')
            .get();

        // Convert QuerySnapshot to List of PaymentCard objects
        List<PaymentCard> cards = querySnapshot.docs
            .map((doc) =>
                PaymentCard.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        setState(() {
          userCards = cards;
        });
      }
    } catch (e) {
      print('Error fetching user payment cards: $e');
    }
  }

  // Method to generate the summary widget
  Widget _buildSummaryWidget() {
    return Card(
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
                  'Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(Icons.notes),
              ],
            ),
            SizedBox(height: 10),
            Divider(),
            // Display vehicle image
            Container(
              height: 200, // Adjust the height as needed
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(widget.vehicle.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 10),
            // Display car name
            Text(
              'Rental Vehicle: ${widget.vehicle.brand}', // Assuming 'name' is the property for the car name
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Rental Supplier: $vendorBusinessName', // Assuming 'name' is the property for the car name
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Renter: $userFullName', // Assuming 'name' is the property for the car name
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            // Display pick-up date and time
            Text(
              'Pick-up: ${DateFormat('yyyy-MM-dd').format(booking.pickupDate)} at ${booking.pickupTime.format(context)}',
            ),
            SizedBox(height: 5),
            // Display drop-off date and time
            Text(
              'Drop-off: ${DateFormat('yyyy-MM-dd').format(booking.dropoffDate)} at ${booking.dropoffTime.format(context)}',
            ),
            SizedBox(height: 5),
            // Display pick-up location
            Text(
              'Pick-up Location: ${pickupLocationController.text}',
            ),
            SizedBox(height: 5),
            // Display drop-off location
            Text(
              'Drop-off Location: ${dropoffLocationController.text}',
            ),
            SizedBox(height: 10),
            Divider(),
            // Display selected payment method and card information
            Text(
              'Payment Method: ${_selectedPaymentMethod?.toString().split('.').last ?? 'N/A'}',
            ),
            if (_selectedPaymentCard != null) ...[
              Text(
                'Bank Card: - Visa ending in ${_selectedPaymentCard?.lastFourDigits}',
              ),
            ],
            Divider(),
            SizedBox(height: 10),
            // Display total price
            Text(
              'Total Price: USD\$${booking.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaymentCardRadioTile(PaymentCard card) {
    return RadioListTile<PaymentCard>(
      title: Text(
        'Visa ending in ${card.lastFourDigits}',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('Card Holder: ${card.cardHolderName}'),
      value: card,
      groupValue: _selectedPaymentCard,
      secondary: Image.asset('assets/images/credit-card.png'),
      onChanged: (value) {
        setState(() {
          _selectedPaymentMethod = PaymentMethod.Card;
          _selectedPaymentCard = value;
        });
      },
    );
  }

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
      });
    }
  }

  Future<void> _selectDropoffDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: booking.dropoffDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (picked != null && picked != booking.dropoffDate) {
      setState(() {
        booking.dropoffDate = picked;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Vehicle Booking Process'),
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
          final isLastStep = currentStep == getSteps().length - 1;
          return Container(
            margin: EdgeInsets.only(top: 50),
            child: Row(
              children: [
                if (currentStep != 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepCancel,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white),
                      child: const Text('BACK'),
                    ),
                  ),
                SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white),
                    child: Text(isLastStep ? 'CONFIRM' : 'NEXT'),
                  ),
                ),
              ],
            ),
          );
        },
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
      booking.paymentMethod = _selectedPaymentMethod.toString().split('.').last;
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

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking successfully saved.'),
          backgroundColor: Colors.green,
        ),
      );

      // Send notifications to user and vendor using PushNotificationService
      await pushNotificationService.sendUserNotification(booking.userId);
      await pushNotificationService.sendVendorNotification(booking.vendorId);

      // Close the page
      Navigator.of(context).pop();
    } catch (e) {
      print('Error sending booking data to Firebase: $e');
      // Show error message if booking data couldn't be saved
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save booking. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
