import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      // Save user data to Firestore
      await _firestore.collection('users').doc(userId).set(user.toMap());

      return userId;
    } catch (e) {
      throw e;
    }
  }

  Future<CustomUser> getUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      if (!userSnapshot.exists) {
        throw Exception('User not found!');
      }

      return CustomUser.fromMap(userSnapshot.data()! as Map<String, dynamic>);
    } catch (e) {
      throw e;
    }
  }

  Future<CustomUser?> getCurrentUser() async {
    try {
      User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        CustomUser userData = await getUserData(firebaseUser.uid);
        return userData;
      } else {
        return null;
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> getVendorInfo(String vendorId) async {
    try {
      DocumentSnapshot vendorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(vendorId)
          .get();

      if (vendorSnapshot.exists) {
        // Convert the vendor's document snapshot to a CustomUser object
        CustomUser vendor =
            CustomUser.fromMap(vendorSnapshot.data() as Map<String, dynamic>?);

        // Now you have access to the vendor's information
        print('Vendor Name: ${vendor.fullname}');
        print('Vendor Email: ${vendor.email}');
        // Display other vendor details as needed
      } else {
        print('Vendor not found!');
      }
    } catch (error) {
      print('Error fetching vendor information: $error');
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw e;
    }
  }
}
