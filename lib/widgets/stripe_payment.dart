import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/providers/booking_provider.dart';
import 'package:v1_rentals/providers/notification_provider.dart';
import 'package:v1_rentals/services/notification_service.dart';

class PaymentHandler {
  final String _secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  Future<void> createStripeCustomer(
      BuildContext context, String bookingId, int amount) async {
    final String stripeSecretKey = _secretKey;
    const String stripeApiVersion = '2024-04-10';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final email = user.email;
      if (email == null) {
        throw Exception("User email not available");
      }

      // Create customer
      final customerResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $stripeSecretKey',
        },
        body: {
          'email': email,
        },
      );
      final customerBody = json.decode(customerResponse.body);
      final customerId = customerBody['id'];

      if (customerId == null) {
        throw Exception("Failed to create customer");
      }

      // Create ephemeral key
      final ephemeralKeyResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/ephemeral_keys'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $stripeSecretKey',
          'Stripe-Version': stripeApiVersion,
        },
        body: {
          'customer': customerId,
        },
      );
      final ephemeralKeyBody = json.decode(ephemeralKeyResponse.body);
      final ephemeralKey = ephemeralKeyBody['secret'];

      if (ephemeralKey == null) {
        throw Exception("Failed to create ephemeral key");
      }

      // Create payment intent
      final paymentIntentResponse = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $stripeSecretKey',
        },
        body: {
          'amount':
              (amount * 100).toInt().toString(), // Example amount, in cents
          'currency': 'usd',
          'customer': customerId,
        },
      );
      final paymentIntentBody = json.decode(paymentIntentResponse.body);
      final clientSecret = paymentIntentBody['client_secret'];

      if (clientSecret == null) {
        throw Exception("Failed to create payment intent");
      }

      // Initialize the payment sheet
      await initPaymentSheet(
        context,
        clientSecret: clientSecret,
        ephemeralKey: ephemeralKey,
        customerId: customerId,
        bookingId: bookingId,
      );

      // Present the payment sheet
      await presentPaymentSheet(context, bookingId);

      // Close the loading dialog
      Navigator.of(context).pop();
    } catch (e) {
      print("Error: $e");
      Navigator.of(context).pop(); // Close the loading dialog in case of error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> initPaymentSheet(
    BuildContext context, {
    required String clientSecret,
    required String ephemeralKey,
    required String customerId,
    required String bookingId,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'V1Rentals',
          paymentIntentClientSecret: clientSecret,
          customerEphemeralKeySecret: ephemeralKey,
          customerId: customerId,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            currencyCode: 'usd',
            testEnv: true,
          ),
          style: ThemeMode.dark,
        ),
      );
    } catch (e) {
      print("Error initializing payment sheet: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing payment sheet: $e')),
      );
    }
  }

  Future<void> presentPaymentSheet(BuildContext context, bookingId) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!')),
      );

      // // Send a notification to the user
      // await pushNotificationService.sendNotification(
      //   'Payment Successful',
      //   'Your payment was processed successfully.',
      //   (await FirebaseAuth.instance.currentUser)?.uid ?? '',
      // );

      // Update booking status in database and send notifications
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      final booking = await bookingProvider.getBookingById(bookingId);

      if (booking != null) {
        await bookingProvider.updateBookingStatusAndNotify(
          booking.id,
          BookingStatus.inProgress,
          booking.userId,
          booking.vendorId,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: Payment was cancelled.')),
      );
    }
  }
}
