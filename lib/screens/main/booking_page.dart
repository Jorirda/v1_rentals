import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/services/email_service.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/models/notification_model.dart';
import 'package:v1_rentals/models/search_history_model.dart';
import 'package:v1_rentals/models/payment_card_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/account/payment_overviews/add_payment_card.dart';
import 'package:intl/intl.dart';
import 'package:v1_rentals/locations/dropoff_location.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/services/location_service.dart';
import 'package:v1_rentals/locations/pickup_location.dart';

import '../../providers/notification_provider.dart';

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

  String? vendorEmail;
  String? userFullName;

  final AuthService _authService = AuthService();

  final List<SearchHistory> _searchHistory =
      []; // Update to store SearchHistory objects

  final LocationService _locationService = LocationService();
  @override
  void initState() {
    super.initState();

    booking = Booking(
      id: FirebaseFirestore.instance.collection('bookings').doc().id,
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      userEmail: FirebaseAuth.instance.currentUser?.email,
      userFullName: '', // You will need to fetch this value
      vehicleId: widget.vehicle.id,
      vehicleDescription:
          '${widget.vehicle.brand} ${widget.vehicle.modelYear}', // Assuming vehicle has a modelYear property
      vendorId: widget.vehicle.vendorId,
      vendorEmail: '', // You will need to fetch this value
      vendorBusinessName: '', // You will need to fetch this value
      vendorContactInformation: '', // You will need to fetch this value
      pickupDate: DateTime.now(),
      pickupTime: TimeOfDay.fromDateTime(DateTime.now()),
      dropoffDate: DateTime.now().add(Duration(days: 1)),
      dropoffTime:
          TimeOfDay.fromDateTime(DateTime.now().add(Duration(days: 1))),
      pickupLocation: '',
      dropoffLocation: '',
      totalPrice: widget.vehicle.pricePerDay,
      imageUrl: widget.vehicle.imageUrl,
      status: BookingStatus.pending,
      paymentStatus: false,
      paymentMethod: PaymentMethod.Card.toString(),
      createdAt: DateTime.now(),
      clientImageURL: '',
      vendorImageURL: '',
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
        title: Text(S.of(context).reserve),
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
                  S.of(context).pick_up,
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
                      S.of(context).pickup_date,
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
                    leading: Icon(
                      Icons.access_time,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      S.of(context).pickup_time,
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
                  S.of(context).drop_off,
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
                      S.of(context).dropoff_date,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${booking.dropoffDate.day}/${booking.dropoffDate.month}/${booking.dropoffDate.year}',
                    ),
                    onTap: () => _selectDropoffDate(context),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      S.of(context).dropoff_time,
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
                  S.of(context).locations,
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
              S.of(context).pick_up_location,
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
                      hintText: S.of(context).enter_pickup_location,
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
            Text(
              S.of(context).drop_off_location,
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
                      hintText: S.of(context).enter_dropoff_location,
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
                Text(
                  S.of(context).set_pickup_drop_off,
                ),
              ],
            ),
          ],
        ),
      ),
      Step(
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: currentStep >= 1,
        title: Text(S.of(context).payment),
        content: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${S.of(context).total_rental_price} : USD\$150.00',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                S.of(context).choose_payment_method,
                style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
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
                        Text(
                          S.of(context).your_credit_debit,
                          style: const TextStyle(
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
                            child: Text(S.of(context).no_card_found),
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
                                S.of(context).add_credit_debit,
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
                        Text(
                          S.of(context).other_payment_method,
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
        title: Text(S.of(context).summary),
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
                  S.of(context).summary,
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
            const SizedBox(height: 10),
            // Display car name
            Text(
              '${S.of(context).rental_vehicle}: ${widget.vehicle.brand.getTranslation()} ${widget.vehicle.model} ${widget.vehicle.modelYear}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${S.of(context).rental_supplier}: ${booking.vendorBusinessName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${S.of(context).renter}: ${booking.userFullName}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            // Display pick-up date and time
            Text(
              '${S.of(context).pick_up}: ${DateFormat('yyyy-MM-dd').format(booking.pickupDate)} at ${booking.pickupTime.format(context)}',
            ),
            const SizedBox(height: 5),
            // Display drop-off date and time
            Text(
              '${S.of(context).drop_off}: ${DateFormat('yyyy-MM-dd').format(booking.dropoffDate)} at ${booking.dropoffTime.format(context)}',
            ),
            const SizedBox(height: 5),
            // Display pick-up location
            Text(
              '${S.of(context).pick_up_location}: ${pickupLocationController.text}',
            ),
            const SizedBox(height: 5),
            // Display drop-off location
            Text(
              '${S.of(context).drop_off_location}: ${dropoffLocationController.text}',
            ),
            const SizedBox(height: 10),
            const Divider(),
            // Display selected payment method and card information
            Text(
              '${S.of(context).payment_method} : ${_selectedPaymentMethod?.toString().split('.').last ?? 'N/A'}',
            ),
            if (_selectedPaymentCard != null) ...[
              Text(
                'Bank Card: - Visa ${S.of(context).ending_in} ${_selectedPaymentCard?.lastFourDigits}',
              ),
            ],
            const Divider(),
            const SizedBox(height: 10),
            // Display total price
            Text(
              '${S.of(context).total_price}: USD\$${booking.totalPrice.toStringAsFixed(2)}',
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
        'Visa ${S.of(context).ending_in} .. ${card.lastFourDigits}',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('${S.of(context).card_holder}: ${card.cardHolderName}'),
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
                      child: Text(S.of(context).back),
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
                    child: Text(isLastStep
                        ? S.of(context).confirm
                        : S.of(context).next),
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

      // Create notifications for user and vendor
      NotificationModel userNotification = NotificationModel(
        title: 'Booking Confirmation',
        body: 'Your booking has been confirmed.',
        timestamp: DateTime.now(),
        userImageURL: vendorImageURL, // Vendor image for the user
        vehicleImageURL: booking.imageUrl,
        bookingId: bookingId, // Add this field
      );

      NotificationModel vendorNotification = NotificationModel(
        title: 'New Booking',
        body: 'You have received a new booking.',
        timestamp: DateTime.now(),
        userImageURL: userImageURL, // User image for the vendor
        vehicleImageURL: booking.imageUrl,
        bookingId: bookingId, // Add this field
      );

      // Add notifications to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(booking.userId)
          .collection('notifications')
          .add(userNotification.toMap());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(booking.vendorId)
          .collection('notifications')
          .add(vendorNotification.toMap());

      // Send notifications to user and vendor using NotificationProvider
      final notificationProvider =
          Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.sendUserNotification(booking.userId);
      await notificationProvider.sendVendorNotification(booking.vendorId);

      // Send booking confirmation emails to user and vendor
      // EmailService emailService = EmailService();
      // await emailService.sendBookingEmails(
      //   booking.userEmail ?? '',
      //   booking.vendorEmail ?? '',
      //   booking.userFullName,
      //   booking.vendorBusinessName,
      //   booking,
      //   _selectedPaymentCard?.lastFourDigits,
      // );

      // Show success SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking successfully saved.'),
          backgroundColor: Colors.green,
        ),
      );

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
