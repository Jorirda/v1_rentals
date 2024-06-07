import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

import 'package:v1_rentals/models/booking_model.dart';

class EmailService {
  final String _mailgunApiKey = dotenv.env['MAILGUN_API_KEY'] ?? '';
  final String _mailgunDomain = dotenv.env['MAILGUN_DOMAIN'] ?? '';

  Future<void> sendEmail(String to, String subject, String body) async {
    final url =
        Uri.parse('https://api.mailgun.net/v3/$_mailgunDomain/messages');

    final response = await http.post(
      url,
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('api:$_mailgunApiKey'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'from': 'V1Rentals <mailgun@$_mailgunDomain>',
        'to': to,
        'subject': subject,
        'html': body,
      },
    );

    if (response.statusCode == 200) {
      print('Email sent successfully');
    } else {
      print('Failed to send email: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  Future<void> sendBookingEmails(
      String userEmail,
      String vendorEmail,
      String userFullName,
      String vendorBusinessName,
      Booking booking,
      String? lastFourDigits) async {
    const userSubject = 'Booking Confirmation';
    const vendorSubject = 'New Booking Received';

    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    final userBody = '''
      <div>
        <h1>Booking Confirmation</h1>
        <p>Dear $userFullName,</p>
        <p>Thank you for your booking. Here are the details:</p>
        <div>
          <img src="${booking.imageUrl}" alt="Vehicle Image" style="width:100%; height:auto;">
        </div>
        <div style="font-size: 20px; font-weight: bold; flex: 1;">${booking.vehicleDescription}</div>
        <div> Supplier: $vendorBusinessName</div>
        <div> Pick-up: ${booking.pickupLocation}</div>
        <div> Drop-off: ${booking.dropoffLocation}</div>
        <div> Pick-up Date/Time: ${dateFormat.format(booking.pickupDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.pickupTime.hour, booking.pickupTime.minute))}</div>
        <div> Drop-off Date/Time: ${dateFormat.format(booking.dropoffDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.dropoffTime.hour, booking.dropoffTime.minute))}</div>
        <div> Payment Method: ${booking.paymentMethod}</div>
        ${lastFourDigits != null ? '<div>- Visa ending in $lastFourDigits</div>' : ''}
        <div> Total Price: USD\$${booking.totalPrice.toStringAsFixed(2)}</div>
      </div>
    ''';

    final vendorBody = '''
      <div>
        <h1>New Booking Received</h1>
        <p>Dear $vendorBusinessName,</p>
        <p>You have received a new booking. Here are the details:</p>
        <div>
          <img src="${booking.imageUrl}" alt="Vehicle Image" style="width:100%; height:auto;">
        </div>
        <div style="font-size: 20px; font-weight: bold; flex: 1;">${booking.vehicleDescription}</div>
        <div> Renter: $userFullName</div>
        <div> Pick-up: ${booking.pickupLocation}</div>
        <div> Drop-off: ${booking.dropoffLocation}</div>
        <div> Pick-up Date/Time: ${dateFormat.format(booking.pickupDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.pickupTime.hour, booking.pickupTime.minute))}</div>
        <div> Drop-off Date/Time: ${dateFormat.format(booking.dropoffDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.dropoffTime.hour, booking.dropoffTime.minute))}</div>
        <div> Total Price: USD\$${booking.totalPrice.toStringAsFixed(2)}</div>
      </div>
    ''';

    await sendEmail(userEmail, userSubject, userBody);
    await sendEmail(vendorEmail, vendorSubject, vendorBody);
  }
}
