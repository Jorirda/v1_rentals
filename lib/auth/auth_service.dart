import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<String> signUp(CustomUser user) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      String userId = userCredential.user!.uid;

      // Set the userId before saving to Firestore
      user.userId = userId;

      if (user.userType == UserType.client) {
        await _firestore
            .collection('clients')
            .doc(userId)
            .set((user as Client).toMap());
      } else {
        await _firestore
            .collection('vendors')
            .doc(userId)
            .set((user as Vendor).toMap());
      }

      return userId;
    } catch (e) {
      throw e;
    }
  }

  // Get user data from Firestore
  Future<CustomUser> getUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot;
      CustomUser user;

      // Check if the user is a client
      userSnapshot = await _firestore.collection('clients').doc(userId).get();
      if (userSnapshot.exists) {
        user = Client.fromMap(userSnapshot.data()! as Map<String, dynamic>);
        return user;
      }

      // Check if the user is a vendor
      userSnapshot = await _firestore.collection('vendors').doc(userId).get();
      if (userSnapshot.exists) {
        user = Vendor.fromMap(userSnapshot.data()! as Map<String, dynamic>);
        return user;
      }

      throw Exception('User not found!');
    } catch (e) {
      throw e;
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw e;
    }
  }
}
