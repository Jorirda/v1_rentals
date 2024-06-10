import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:path_provider/path_provider.dart';

class EmailService {
  final String _mailgunApiKey = dotenv.env['MAILGUN_API_KEY'] ?? '';
  final String _mailgunDomain = dotenv.env['MAILGUN_DOMAIN'] ?? '';

  Future<String> getImagePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/assets/images/v1-rentals-logo.png';

    return imagePath;
  }

  Future<void> sendEmail(String to, String subject, String body) async {
    final url =
        Uri.parse('https://api.mailgun.net/v3/$_mailgunDomain/messages');

    final response = await http.post(
      url,
      headers: {
        'Authorization':
            'Basic ' + base64Encode(utf8.encode('api:$_mailgunApiKey')),
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

    final imagePath = await getImagePath();
    final userBody = '''
      <div style="background-color: royalblue; color: white; padding: 20px; max-width: 600px; margin: auto; border-radius: 10px; font-family: Arial, sans-serif;">
          <div style="text-align: center;">
          <img src="$imagePath" alt="V1Rentals Image" style="max-width: 100%; max-height: 100px; border-radius: 10px; margin-bottom: 20px;">
        </div>
        <h1 style="text-align: center;">Booking Confirmation</h1>
        <p>Dear $userFullName,</p>
        <p>Thank you for your booking. Here are the details:</p>
        <div style="text-align: center;">
          <img src="${booking.imageUrl}" alt="Vehicle Image" style="max-width: 100%; max-height: 200px; border-radius: 10px; margin-bottom: 20px;">
        </div>
        <div style="font-size: 20px; font-weight: bold; margin-bottom: 10px;">${booking.vehicleDescription}</div>
        <div style="margin-bottom: 5px;"><strong>Supplier:</strong> $vendorBusinessName</div>
        <div style="margin-bottom: 5px;"><strong>Pick-up:</strong> ${booking.pickupLocation}</div>
        <div style="margin-bottom: 5px;"><strong>Drop-off:</strong> ${booking.dropoffLocation}</div>
        <div style="margin-bottom: 5px;"><strong>Pick-up Date/Time:</strong> ${dateFormat.format(booking.pickupDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.pickupTime.hour, booking.pickupTime.minute))}</div>
        <div style="margin-bottom: 5px;"><strong>Drop-off Date/Time:</strong> ${dateFormat.format(booking.dropoffDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.dropoffTime.hour, booking.dropoffTime.minute))}</div>
        <div style="margin-bottom: 5px;"><strong>Payment Method:</strong> ${booking.paymentMethod}</div>
        ${lastFourDigits != null ? '<div style="margin-bottom: 5px;">- Visa ending in $lastFourDigits</div>' : ''}
        <div style="margin-bottom: 5px;"><strong>Total Price:</strong> USD\$${booking.totalPrice.toStringAsFixed(2)}</div>
      </div>
    ''';

    final vendorBody = '''
      <div style="background-color: royalblue; color: white; padding: 20px; max-width: 600px; margin: auto; border-radius: 10px; font-family: Arial, sans-serif;">
        <h1 style="text-align: center;">New Booking Received</h1>
        <p>Dear $vendorBusinessName,</p>
        <p>You have received a new booking. Here are the details:</p>
        <div style="text-align: center;">
          <img src="${booking.imageUrl}" alt="Vehicle Image" style="max-width: 100%; max-height: 200px; border-radius: 10px; margin-bottom: 20px;">
        </div>
        <div style="font-size: 20px; font-weight: bold; margin-bottom: 10px;">${booking.vehicleDescription}</div>
        <div style="margin-bottom: 5px;"><strong>Renter:</strong> $userFullName</div>
        <div style="margin-bottom: 5px;"><strong>Pick-up:</strong> ${booking.pickupLocation}</div>
        <div style="margin-bottom: 5px;"><strong>Drop-off:</strong> ${booking.dropoffLocation}</div>
        <div style="margin-bottom: 5px;"><strong>Pick-up Date/Time:</strong> ${dateFormat.format(booking.pickupDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.pickupTime.hour, booking.pickupTime.minute))}</div>
        <div style="margin-bottom: 5px;"><strong>Drop-off Date/Time:</strong> ${dateFormat.format(booking.dropoffDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.dropoffTime.hour, booking.dropoffTime.minute))}</div>
        <div style="margin-bottom: 5px;"><strong>Total Price:</strong> USD\$${booking.totalPrice.toStringAsFixed(2)}</div>
      </div>
    ''';

    await sendEmail(userEmail, userSubject, userBody);
    await sendEmail(vendorEmail, vendorSubject, vendorBody);
  }
}
