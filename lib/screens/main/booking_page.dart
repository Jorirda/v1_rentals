import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/main/add_payment_card.dart';

enum PaymentMethod {
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
  int currentStep = 0;
  bool setSameLocation = false;

  PaymentMethod? _selectedPaymentMethod;
  @override
  void initState() {
    super.initState();
    // Initialize booking model with default values or empty
    booking = Booking(
      userId: '', // Initialize with current user's ID if available
      vehicleId: widget.vehicle.id,
      pickupDate: DateTime.now(), // Initialize with current date/time
      dropoffDate: DateTime.now().add(Duration(days: 1)),
      id: '',
      createdAt: Timestamp.now(), // Initialize createdAt with current time
      pickupTime: TimeOfDay.now(), // Initialize with current time of day
      dropoffTime: TimeOfDay.now(), // Initialize with current time of day
      totalPrice: 0,
      status: '',
      paymentStatus: false, // Example: Next day
      // Initialize other fields with default values or empty
    );
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
                      hintText:
                          'Enter pick-up location', // Provide a hint text for better UX
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType
                        .text, // Change keyboard type to text for location entry
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a pick-up location';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                    width:
                        10), // Add spacing between text field and icon button
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Add functionality to get user's current location
                    },
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
                      hintText:
                          'Enter drop-off location', // Provide a hint text for better UX
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType
                        .text, // Change keyboard type to text for location entry
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a drop-off location';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(
                    width:
                        10), // Add spacing between text field and icon button
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Add functionality to get user's current location
                    },
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
                          'Your credit and debit cards', // Example payment method
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
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
                                  child: Image.asset(
                                      'assets/images/visa_icon.png')),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                  width: 32,
                                  height: 32,
                                  child: Image.asset(
                                      'assets/images/mastercard_icon.png'))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        const Text(
                          'Other payment methods', // Example payment method
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        // ListView for other payment methods
                        ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            // PayPal payment option
                            RadioListTile(
                              title: Text(
                                'PayPal',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              value: PaymentMethod.PayPal,
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod =
                                      value as PaymentMethod;
                                });
                              },
                              secondary:
                                  Image.asset('assets/images/paypal_icon.png'),
                            ),
                            // Apple Pay payment option
                            RadioListTile(
                              title: Text(
                                'Apple Pay',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              value: PaymentMethod.ApplePay,
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod =
                                      value as PaymentMethod;
                                });
                              },
                              secondary: Image.asset(
                                  'assets/images/apple_pay_icon.png'),
                            ),
                            // Google Pay payment option
                            RadioListTile(
                              title: Text(
                                'Google Pay',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              value: PaymentMethod.GooglePay,
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod =
                                      value as PaymentMethod;
                                });
                              },
                              secondary: Image.asset(
                                  'assets/images/google_pay_icon.png'),
                            )
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
          content: Text(
              'Step 3') // Your widget for Step 3, such as a form for entering payment details,
          ),
    ];
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
}
