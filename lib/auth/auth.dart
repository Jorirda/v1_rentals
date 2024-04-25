import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1_rentals/auth/auth_page.dart';
import 'package:v1_rentals/main.dart';

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator or splash screen while checking authentication state
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            // User is logged in, return the main screen
            return FutureBuilder<DocumentSnapshot>(
              future: _getUserData(snapshot.data!.uid),
              builder:
                  (context, AsyncSnapshot<DocumentSnapshot> userDataSnapshot) {
                if (userDataSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (userDataSnapshot.hasData &&
                      userDataSnapshot.data != null) {
                    // Fetch userType from user data
                    final userType =
                        userDataSnapshot.data!['userType'] as String?;
                    if (userType == 'vendor') {
                      // If the user is a vendor, navigate to Vendor Main Screen
                      return const VendorMainScreen();
                    } else {
                      // If the user is a client, navigate to Main Screen
                      return const MainScreen();
                    }
                  } else {
                    // User data not found
                    return const AuthPage();
                  }
                }
              },
            );
          } else {
            // User is not logged in, redirect to the login screen
            return const AuthPage();
          }
        }
      },
    );
  }

  Future<DocumentSnapshot> _getUserData(String uid) async {
    final userData =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userData;
  }
}
