import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _ready = false;
  String? _clientSecret;
  String? _ephemeralKey;
  String? _customerId;

  @override
  void initState() {
    super.initState();
    createStripeCustomer();
  }

  Future<void> createStripeCustomer() async {
    const String stripeSecretKey =
        'sk_test_51PPcUVJWp34Kh7YONAnVxd0B3igBW11qJutEUxjgRH3xMA240l7Gu8u5XeLwcJ8DT8DbxdSX9x4Ou8RqtsgJqDcp00F61kJE3u'; // Replace with your actual Stripe secret key
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
      _customerId = customerBody['id'];

      if (_customerId == null) {
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
          'customer': _customerId!,
        },
      );
      final ephemeralKeyBody = json.decode(ephemeralKeyResponse.body);
      _ephemeralKey = ephemeralKeyBody['secret'];

      if (_ephemeralKey == null) {
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
          'amount': '1099',
          'currency': 'usd',
          'customer': _customerId!,
        },
      );
      final paymentIntentBody = json.decode(paymentIntentResponse.body);
      _clientSecret = paymentIntentBody['client_secret'];

      if (_clientSecret == null) {
        throw Exception("Failed to create payment intent");
      }

      // Initialize the payment sheet
      await initPaymentSheet();

      setState(() {
        _ready = true;
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> initPaymentSheet() async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Flutter Stripe Store Demo',
          paymentIntentClientSecret: _clientSecret!,
          customerEphemeralKeySecret: _ephemeralKey!,
          customerId: _customerId!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _ready
              ? () async {
                  try {
                    await Stripe.instance.presentPaymentSheet();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment successful!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment failed: $e')),
                    );
                  }
                }
              : null,
          child: Text('Make Payment'),
        ),
      ),
    );
  }
}
