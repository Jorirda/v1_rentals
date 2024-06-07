import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/models/vehicle_model.dart';

class FavoritesService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Vehicle>> fetchFavorites() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .get();

    List<Vehicle> vehicles = [];
    for (var doc in querySnapshot.docs) {
      String vehicleId = doc.id;
      DocumentSnapshot vehicleDoc =
          await _firestore.collection('vehicles').doc(vehicleId).get();
      if (vehicleDoc.exists) {
        Vehicle vehicle = Vehicle.fromMap(vehicleDoc);
        vehicles.add(vehicle);
      }
    }
    return vehicles;
  }

  Future<void> addFavorite(String vehicleId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .doc(vehicleId)
        .set({});
  }

  Future<void> removeFavorite(String vehicleId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .doc(vehicleId)
        .delete();
  }
}
