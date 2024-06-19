import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/models/vehicle_model.dart';

class FavoritesProvider with ChangeNotifier {
  List<Vehicle> _favorites = [];
  List<Vehicle> _filteredFavorites = [];
  bool _isLoading = false;
  Map<String, String> _vendorNames = {};

  List<Vehicle> get favorites => _favorites;
  List<Vehicle> get filteredFavorites => _filteredFavorites;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .get();

    List<Vehicle> vehicles = [];
    for (var doc in querySnapshot.docs) {
      String vehicleId = doc.id;
      DocumentSnapshot vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicleId)
          .get();
      if (vehicleDoc.exists) {
        Vehicle vehicle = Vehicle.fromMap(vehicleDoc);
        vehicles.add(vehicle);
      }
    }

    _favorites = vehicles;
    _filteredFavorites = vehicles;
    notifyListeners();
  }

  void filterFavorites(String query) {
    if (query.isEmpty) {
      _filteredFavorites = _favorites;
    } else {
      _filteredFavorites = _favorites.where((vehicle) {
        return vehicle.brand.toString().toLowerCase().contains(query) ||
            vehicle.modelYear.toLowerCase().contains(query) ||
            vehicle.pricePerDay.toString().contains(query) ||
            vehicle.color.toLowerCase().contains(query);
      }).toList();
    }
    notifyListeners();
  }

  bool isFavorite(String vehicleId) {
    return _favorites.any((vehicle) => vehicle.id == vehicleId);
  }

  Future<void> addFavorite(Vehicle vehicle) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .doc(vehicle.id)
        .set(vehicle.toMap());

    _favorites.add(vehicle);
    _filteredFavorites = _favorites;
    notifyListeners();
  }

  Future<void> removeFavorite(Vehicle vehicle) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .doc(vehicle.id)
        .delete();

    _favorites.removeWhere((fav) => fav.id == vehicle.id);
    _filteredFavorites = _favorites;
    notifyListeners();
  }

  Future<void> toggleFavorite(Vehicle vehicle) async {
    if (isFavorite(vehicle.id)) {
      await removeFavorite(vehicle);
    } else {
      await addFavorite(vehicle);
    }
  }

  String getBusinessName(String vendorId) {
    return _vendorNames[vendorId] ?? 'Unknown';
  }

  Future<void> fetchVendorNames() async {
    final vendorIds = _favorites.map((vehicle) => vehicle.vendorId).toSet();

    for (final vendorId in vendorIds) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(vendorId)
          .get();

      final vendorData = docSnapshot.data();
      if (vendorData != null && vendorData.containsKey('businessName')) {
        _vendorNames[vendorId] = vendorData['businessName'];
      } else {
        _vendorNames[vendorId] = 'Unknown';
      }
    }
    notifyListeners();
  }
}
