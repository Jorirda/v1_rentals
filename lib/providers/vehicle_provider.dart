import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1_rentals/models/vehicle_model.dart';

class VehicleProvider with ChangeNotifier {
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  String? _userId;

  VehicleProvider(this._userId);

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;

  void updateUserId(String? newUserId) {
    _userId = newUserId;
    notifyListeners();
  }

  // Fetch vehicles and check if they are favorited
  Future<void> fetchVehicles() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('vehicles').get();

      _vehicles = await Future.wait(querySnapshot.docs.map((doc) async {
        Vehicle vehicle = Vehicle.fromMap(doc);

        // Check if the vehicle is favorited
        DocumentSnapshot favoriteSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .collection('favorites')
            .doc(vehicle.id)
            .get();

        vehicle.isFavorite = favoriteSnapshot.exists;
        return vehicle;
      }).toList());
    } catch (error) {
      // Handle error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(Vehicle vehicle) async {
    if (_userId == null) return;

    final favoriteDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('favorites')
        .doc(vehicle.id);

    if (vehicle.isFavorite) {
      await favoriteDoc.delete();
    } else {
      await favoriteDoc.set({'vehicleId': vehicle.id});
    }

    vehicle.isFavorite = !vehicle.isFavorite;
    notifyListeners();
  }
}
