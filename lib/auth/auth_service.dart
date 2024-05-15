import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/models/booking_model.dart';
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
      } else {
        print('Vendor not found!');
      }
    } catch (error) {
      print('Error fetching vendor information: $error');
    }
  }

  // Method to get the vehicle document based on its ID
  Future<DocumentSnapshot> getVehicleDocument(String vehicleId) async {
    try {
      return await _firestore.collection('vehicles').doc(vehicleId).get();
    } catch (e) {
      throw e;
    }
  }

  Stream<List<Booking>> getCurrentUserBookingsStream(BookingStatus status) {
    try {
      Query bookingsQuery = _firestore.collection('bookings');
      // Filter by booking status
      if (status != BookingStatus.all) {
        bookingsQuery = bookingsQuery.where('status',
            isEqualTo: status.toString().split('.').last);
      }
      return bookingsQuery
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Booking.fromSnapshot(doc)).toList());
    } catch (e) {
      throw e;
    }
  }

  Stream<List<Booking>> getVendorBookingsStream(BookingStatus status) {
    try {
      Query bookingsQuery = _firestore.collection('bookings');
      // Filter by booking status
      if (status != BookingStatus.all) {
        bookingsQuery = bookingsQuery.where('status',
            isEqualTo: status.toString().split('.').last);
      }
      return bookingsQuery
          .where('vendorId', isEqualTo: _auth.currentUser!.uid)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Booking.fromSnapshot(doc)).toList());
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw e;
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
