import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/models/booking_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Method to update the FCM token in Firestore
  Future<void> updateFcmToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
      print('FCM Token updated for user: $userId');
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<String> signUp(CustomUser user) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      String userId = userCredential.user!.uid;
      user.userId = userId;

      await _firestore.collection('users').doc(userId).set(user.toMap());

      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await updateFcmToken(userId, token);
      }

      return userId;
    } catch (e) {
      rethrow;
    }
  }

  // Method to get user data
  Future<CustomUser> getUserData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      return CustomUser.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting user data: $e');
      rethrow;
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
      rethrow;
    }
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getVendorInfo(String vendorId) async {
    try {
      DocumentSnapshot vendorSnapshot =
          await _firestore.collection('users').doc(vendorId).get();

      if (vendorSnapshot.exists) {
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
      rethrow;
    }
  }

  Stream<List<Booking>> getCurrentUserBookingsStream(BookingStatus status) {
    try {
      Query bookingsQuery = _firestore.collection('bookings');
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
      rethrow;
    }
  }

  Stream<List<Booking>> getVendorBookingsStream(BookingStatus status) {
    try {
      Query bookingsQuery = _firestore.collection('bookings');
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
      rethrow;
    }
  }

  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBookingDetails(Booking booking) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .update(booking.toMap());
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateUserAddress(String userId, String address) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'address': address,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      String userId = userCredential.user!.uid;

      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await updateFcmToken(userId, token);
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
