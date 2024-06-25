import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/user_model.dart';

class AccountDataProvider with ChangeNotifier {
  CustomUser? _user; // Private variable to store the current user data
  final AuthService _authService =
      AuthService(); // Instance of AuthService to interact with Firebase Auth and Firestore

  CustomUser? get user => _user; // Getter to access the current user data

  // Method to fetch user data from Firestore based on current Firebase Auth user
  Future<void> fetchUserData() async {
    try {
      User? firebaseUser =
          FirebaseAuth.instance.currentUser; // Get the current Firebase user
      if (firebaseUser != null) {
        _user = await _authService
            .getUserData(firebaseUser.uid); // Fetch user data using AuthService
        notifyListeners(); // Notify listeners to update UI with fetched user data
      }
    } catch (e) {
      print("Failed to fetch user data: $e");
    }
  }

  // Method to update user data in Firestore
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      User? firebaseUser =
          FirebaseAuth.instance.currentUser; // Get the current Firebase user
      if (firebaseUser != null) {
        await _authService.updateUserData(
            firebaseUser.uid, data); // Update user data using AuthService
        await fetchUserData(); // Refresh user data after update
      }
    } catch (e) {
      print("Failed to update user data: $e");
    }
  }
}
