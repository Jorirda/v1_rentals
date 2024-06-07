import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/user_model.dart';

class AccountDataProvider with ChangeNotifier {
  CustomUser? _user;
  final AuthService _authService = AuthService();

  CustomUser? get user => _user;

  Future<void> fetchUserData() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        _user = await _authService.getUserData(firebaseUser.uid);
        notifyListeners();
      }
    } catch (e) {
      print("Failed to fetch user data: $e");
    }
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await _authService.updateUserData(firebaseUser.uid, data);
        await fetchUserData(); // Refresh user data
      }
    } catch (e) {
      print("Failed to update user data: $e");
    }
  }
}
