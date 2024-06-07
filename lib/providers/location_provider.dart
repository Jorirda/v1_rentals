import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:v1_rentals/models/locations_model.dart';
import 'package:v1_rentals/models/search_history_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();
  CustomUser? _currentUser;
  final List<String> _popularLocations = [
    'Grantley Adams International Airport'
  ]; // Define a list of popular locations
  List<SearchHistory> _searchHistory = [];
  String _currentLocation = '';
  LatLng _currentPosition = LatLng(0, 0);
  bool _isLoading = false;
  LatLng? _currentLatLng;
  String? _currentPlaceName;
  String? _currentAddress;

  // Getters
  List<String> get popularLocations => _popularLocations;
  List<SearchHistory> get searchHistory => _searchHistory;
  String get currentLocation => _currentLocation;
  LatLng get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  LatLng? get currentLatLng => _currentLatLng;
  String? get currentPlaceName => _currentPlaceName;
  String? get currentAddress => _currentAddress;

  LocationProvider(this._currentUser) {
    if (_currentUser != null) {
      initializeLocation();
    }
  }

  void updateUser(CustomUser? user) {
    _currentUser = user;
    if (_currentUser != null) {
      initializeLocation();
    }
  }

  void initializeLocation() async {
    await fetchSearchHistory();
  }

  Future<void> fetchSearchHistory() async {
    if (_currentUser?.userId != null) {
      _searchHistory =
          await _locationService.getSearchHistory(_currentUser!.userId!);
      notifyListeners();
    }
  }

  Future<void> fetchCurrentLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get current location
      _currentLatLng = await LocationService.getCurrentLocation();
      await LocationService.updatePosition(_currentLatLng!);

      // Perform reverse geocoding to get the address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentLatLng!.latitude,
        _currentLatLng!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        // Fetch place details from Google Places API
        final String apiKey = LocationService.apiKey;
        final String url =
            'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentLatLng!.latitude},${_currentLatLng!.longitude}&radius=50&key=$apiKey';

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          if (result['results'].isNotEmpty) {
            final placeDetails = result['results'].first;
            _currentPlaceName = placeDetails['name'];
            _currentAddress =
                '${place.street}, ${place.locality}, ${place.country}';
          } else {
            throw Exception('No place details found');
          }
        } else {
          throw Exception('Failed to fetch place details');
        }
      } else {
        throw Exception('No address found');
      }
    } catch (e) {
      _isLoading = false;
      _currentPlaceName = null;
      _currentAddress = null;
      notifyListeners();
      throw e;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePosition(LatLng position) async {
    _currentPosition = position;
    _currentLocation = await LocationService.updatePosition(position);
    notifyListeners();
  }

  Future<void> saveSearchHistory(SearchHistory history) async {
    if (_currentUser?.userId != null) {
      await _locationService.saveSearchHistory(_currentUser!.userId!, history);
      _searchHistory.insert(0, history);
      notifyListeners();
    }
  }

  Future<void> savePickupLocation(Locations location) async {
    await _locationService.savePickupLocation(location);
  }

  Future<void> saveDropoffLocation(Locations location) async {
    await _locationService.saveDropoffLocation(location);
  }

  Future<LatLng> getCurrentLocation() async {
    _currentPosition = await LocationService.getCurrentLocation();
    notifyListeners();
    return _currentPosition;
  }

  Future<List<Map<String, dynamic>>> getSuggestions(String query) async {
    return await LocationService.getSuggestions(query);
  }

  Future<List<LatLng>> getSuggestionDetails(List<String> placeIds) async {
    return await LocationService.getSuggestionDetails(placeIds);
  }

  Future<List<double>> calculateDistances(
      LatLng currentLatLng, List<LatLng> suggestionPositions) async {
    return await LocationService.calculateDistances(
        currentLatLng, suggestionPositions);
  }

  Future<void> clearSearchHistory() async {
    if (_currentUser?.userId != null) {
      await _locationService.clearSearchHistory(_currentUser!.userId!);
      _searchHistory.clear();
      notifyListeners();
    }
  }

  Future<void> deleteSearchHistoryItem(String documentId) async {
    if (_currentUser?.userId != null) {
      await _locationService.deleteSearchHistoryItem(
          _currentUser!.userId!, documentId);
      _searchHistory.removeWhere((history) => history.id == documentId);
      notifyListeners();
    }
  }
}
