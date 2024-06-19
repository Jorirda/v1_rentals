import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:path_provider/path_provider.dart';

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
    Booking booking,
  ) async {
    const userSubject = 'Booking Confirmation';
    const vendorSubject = 'New Booking Received';

    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    final imageUrl =
        'https://firebasestorage.googleapis.com/v0/b/v1-rentals-test.appspot.com/o/assets%2Fv1-rentals-logo.png?alt=media&token=4a5d4ab1-68e5-432f-8fdb-0fc25ed5a09d';
    final userBody = '''
  <div style="background-color: #F0F0F0; color: black; padding: 20px; max-width: 600px; margin: auto; border-radius: 10px; font-family: Arial, sans-serif;">
    <div style="text-align: center;">
      <img src="$imageUrl" alt="V1Rentals Logo" style="max-width: 100%; max-height: 200px; margin-bottom: 20px;">
    </div>
    <h1 style="text-align: center; color: #009DFF;"><strong>Booking Confirmation</strong></h1>
    <p><strong>Dear ${booking.userFullName},</strong></p>
    <p><strong>Thank you for your booking. Here are the details:</strong></p>
    <div style="background-color: #FFFFFF; padding: 10px; border-radius: 10px; margin-bottom: 20px; box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.1);">
      <div style="text-align: center;">
        <img src="${booking.imageUrl}" alt="Vehicle Image" style="max-width: 100%; max-height: 200px; border-radius: 10px; margin-bottom: 20px;">
        <div style="font-size: 20px; font-weight: bold; margin-bottom: 10px; color: #009DFF;"><strong>${booking.vehicleDescription}</strong></div>
      </div>
      <div style="background-color: #F9F9F9; padding: 20px; border-radius: 10px; margin-bottom: 15px; border: 1px solid #E0E0E0;">
        <table style="width: 100%; border-collapse: collapse; color: black;">
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Supplier:</strong></td>
            <td style="padding: 8px; text-align: left; color: #333;">${booking.vendorBusinessName}</td>
          </tr>
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Pick-up:</strong></td>
            <td style="padding: 8px; text-align: left; color: #333;">${booking.pickupLocation}</td>
          </tr>
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Drop-off:</strong></td>
            <td style="padding: 8px; text-align: left; color: #333;">${booking.dropoffLocation}</td>
          </tr>
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Pick-up Date/Time:</strong></td>
            <td style="padding: 8px; text-align: left; color: #333;">${dateFormat.format(booking.pickupDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.pickupTime.hour, booking.pickupTime.minute))}</td>
          </tr>
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Drop-off Date/Time:</strong></td>
            <td style="padding: 8px; text-align: left; color: #333;">${dateFormat.format(booking.dropoffDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.dropoffTime.hour, booking.dropoffTime.minute))}</td>
          </tr>
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Total Price:</strong></td>
            <td style="padding: 8px; text-align: left; color: #333;">USD\$${booking.totalPrice.toStringAsFixed(2)}</td>
          </tr>
        </table>
      </div>
      <p style="text-align: center;">You can view your booking details <a href="YOUR_LINK_HERE" style="color: red;">here</a>.</p>
    </div>
  </div>
''';

//     final userBody = '''
//   <div style="background-color: #212121; color: white; padding: 20px; max-width: 600px; margin: auto; border-radius: 10px; font-family: Arial, sans-serif;">
//     <div style="text-align: center;">
//       <img src="$imageUrl" alt="V1Rentals Logo" style="max-width: 100%; max-height: 200px; margin-bottom: 20px;">
//     </div>
//     <h1 style="text-align: center;"><strong>Booking Confirmation</strong></h1>
//     <p><strong>Dear ${booking.userFullName},</strong></p>
//     <p><strong>Thank you for your booking. Here are the details:</strong></p>
//     <div style="background-color: #2b2b2b; padding: 10px; border-radius: 10px; margin-bottom: 20px;">
//       <div style="text-align: center;">
//         <img src="${booking.imageUrl}" alt="Vehicle Image" style="max-width: 100%; max-height: 200px; border-radius: 10px; margin-bottom: 20px;">
//          <div style="font-size: 20px; font-weight: bold; margin-bottom: 10px;"><strong>${booking.vehicleDescription}</strong></div>
//       </div>
//       <div style="background-color: #333; padding: 20px; border-radius: 10px; margin-bottom: 15px;">
//         <table style="width: 100%; border-collapse: collapse; color: white;">
//           <tr>
//             <td style="padding: 8px; text-align: left; width: 30%;"><strong>Supplier:</strong></td>
//             <td style="padding: 8px; text-align: left; color: #ccc;">${booking.vendorBusinessName}</td>
//           </tr>
//           <tr>
//             <td style="padding: 8px; text-align: left; width: 30%;"><strong>Pick-up:</strong></td>
//             <td style="padding: 8px; text-align: left; color: #ccc;">${booking.pickupLocation}</td>
//           </tr>
//           <tr>
//             <td style="padding: 8px; text-align: left; width: 30%;"><strong>Drop-off:</strong></td>
//             <td style="padding: 8px; text-align: left; color: #ccc;">${booking.dropoffLocation}</td>
//           </tr>
//           <tr>
//             <td style="padding: 8px; text-align: left; width: 30%;"><strong>Pick-up Date/Time:</strong></td>
//             <td style="padding: 8px; text-align: left; color: #ccc;">${dateFormat.format(booking.pickupDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.pickupTime.hour, booking.pickupTime.minute))}</td>
//           </tr>
//           <tr>
//             <td style="padding: 8px; text-align: left; width: 30%;"><strong>Drop-off Date/Time:</strong></td>
//             <td style="padding: 8px; text-align: left; color: #ccc;">${dateFormat.format(booking.dropoffDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.dropoffTime.hour, booking.dropoffTime.minute))}</td>
//           </tr>
//           <tr>
//             <td style="padding: 8px; text-align: left; width: 30%;"><strong>Total Price:</strong></td>
//             <td style="padding: 8px; text-align: left; color: #ccc;">USD\$${booking.totalPrice.toStringAsFixed(2)}</td>
//           </tr>
//         </table>
//       </div>
//       <p style="text-align: center;">You can view your booking details <a href="YOUR_LINK_HERE" style="color: #1a73e8;">here</a>.</p>
//     </div>
//   </div>
// ''';

    final vendorBody = '''
  <div style="background-color: #212121; color: white; padding: 20px; max-width: 600px; margin: auto; border-radius: 10px; font-family: Arial, sans-serif;">
    <div style="text-align: center;">
      <img src="$imageUrl" alt="V1Rentals Logo" style="max-width: 100%; max-height: 200px; margin-bottom: 20px;">
    </div>
    <h1 style="text-align: center;"><strong>New Booking Received</strong></h1>
    <p><strong>Dear ${booking.vendorBusinessName},</strong></p>
    <p><strong>You have received a new booking. Here are the details:</strong></p>
    <div style="background-color: #2b2b2b; padding: 10px; border-radius: 10px; margin-bottom: 20px;">
      <div style="text-align: center;">
        <img src="${booking.imageUrl}" alt="Vehicle Image" style="max-width: 100%; max-height: 200px; border-radius: 10px; margin-bottom: 20px;">
         <div style="font-size: 20px; font-weight: bold; margin-bottom: 10px;"><strong>${booking.vehicleDescription}</strong></div>
      </div>
      <div style="background-color: #333; padding: 20px; border-radius: 10px; margin-bottom: 15px;">
        <table style="width: 100%; border-collapse: collapse; color: white;">
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Renter:</strong></td>
            <td style="padding: 8px; text-align: left; color: #ccc;">${booking.userFullName}</td>
          </tr>
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Pick-up:</strong></td>
            <td style="padding: 8px; text-align: left; color: #ccc;">${booking.pickupLocation}</td>
          </tr>
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Drop-off:</strong></td>
            <td style="padding: 8px; text-align: left; color: #ccc;">${booking.dropoffLocation}</td>
          </tr>
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Pick-up Date/Time:</strong></td>
            <td style="padding: 8px; text-align: left; color: #ccc;">${dateFormat.format(booking.pickupDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.pickupTime.hour, booking.pickupTime.minute))}</td>
          </tr>
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Drop-off Date/Time:</strong></td>
            <td style="padding: 8px; text-align: left; color: #ccc;">${dateFormat.format(booking.dropoffDate)} at ${timeFormat.format(DateTime(1, 1, 1, booking.dropoffTime.hour, booking.dropoffTime.minute))}</td>
          </tr>
          <tr>
            <td style="padding: 8px; text-align: left; width: 30%;"><strong>Total Price:</strong></td>
            <td style="padding: 8px; text-align: left; color: #ccc;">USD\$${booking.totalPrice.toStringAsFixed(2)}</td>
          </tr>
        </table>
      </div>
      <p style="text-align: center;">You can view the booking details <a href="YOUR_LINK_HERE" style="color: #1a73e8;">here</a>.</p>
    </div>
  </div>
''';

    await sendEmail(booking.userEmail!, userSubject, userBody);
    await sendEmail(booking.vendorEmail!, vendorSubject, vendorBody);
  }
}
