import 'package:flutter/material.dart';
import 'package:v1_rentals/services/email_service.dart';

class EmailProvider with ChangeNotifier {
  final EmailService _emailService = EmailService();

  Future<void> sendEmail(String to, String subject, String body) async {
    await _emailService.sendEmail(to, subject, body);
  }
}
