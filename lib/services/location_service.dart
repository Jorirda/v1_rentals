import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/locations_model.dart';
import 'package:v1_rentals/models/search_history_model.dart';
import 'package:v1_rentals/models/user_model.dart';

class LocationService {
  static const String apiKey =
      'AIzaSyBtA-wz9_JZno0YdDdV-kmaQh2guHxGrKE'; // Google API Key

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final AuthService _authService;

  LocationService() {
    _authService = AuthService();
  }

  Future<String> getCurrentUserId() async {
    final CustomUser? currentUser = await _authService.getCurrentUser();
    if (currentUser != null) {
      return currentUser.userId!;
    } else {
      throw Exception('Current user not found');
    }
  }

  static Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  static Future<String> updatePosition(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      return "${place.street}, ${place.locality}, ${place.country}";
    }
    return '';
  }

  static Future<List<Map<String, dynamic>>> getSuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&components=country:BB&key=$apiKey'));

    if (response.statusCode == 200) {
      final List predictions = json.decode(response.body)['predictions'];
      List<Map<String, dynamic>> results = [];

      for (var prediction in predictions) {
        results.add({
          'description': prediction['description'],
          'place_id': prediction['place_id'],
          'main_text': prediction['structured_formatting']['main_text'],
          'secondary_text': prediction['structured_formatting']
              ['secondary_text'],
        });
      }
      return results;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  static Future<List<LatLng>> getSuggestionDetails(
      List<String> placeIds) async {
    List<LatLng> positions = [];
    await Future.wait(placeIds.map((placeId) async {
      final detailsResponse = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey'));

      if (detailsResponse.statusCode == 200) {
        final location =
            json.decode(detailsResponse.body)['result']['geometry']['location'];
        positions.add(LatLng(location['lat'], location['lng']));
      }
    }));

    return positions;
  }

  Future<void> savePickupLocation(Locations location) async {
    try {
      final String userId = await getCurrentUserId();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('pickupLocations')
          .add(location.toMap());
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveDropoffLocation(Locations location) async {
    try {
      final String userId = await getCurrentUserId();
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('dropoffLocations')
          .add(location.toMap());
    } catch (e) {
      throw e;
    }
  }

  Future<void> saveSearchHistory(String userId, SearchHistory history) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('searchHistory')
          .add(history.toMap());
      print('Search history saved successfully');
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  static Future<List<double>> calculateDistances(
      LatLng currentPosition, List<LatLng> suggestionPositions) async {
    return await Future.wait(suggestionPositions.map((position) async {
      double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        position.latitude,
        position.longitude,
      );
      return distance / 1000; // Convert meters to kilometers
    }).toList());
  }

  Future<List<SearchHistory>> getSearchHistory(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('searchHistory')
          .get();

      return snapshot.docs
          .map((doc) =>
              SearchHistory.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching search history: $e');
    }
  }

  Future<void> clearSearchHistory(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('searchHistory')
          .get();
      for (DocumentSnapshot document in snapshot.docs) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('searchHistory')
            .doc(document.id)
            .delete();
      }
      print('Search history cleared successfully');
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }

  Future<void> deleteSearchHistoryItem(String userId, String documentId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('searchHistory')
          .doc(documentId)
          .delete();
      print('Search history item deleted successfully');
    } catch (e) {
      print('Error deleting search history item: $e');
    }
  }
}
