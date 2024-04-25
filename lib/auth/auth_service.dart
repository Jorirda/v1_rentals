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
