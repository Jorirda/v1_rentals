import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String apiKey =
      'AIzaSyBtA-wz9_JZno0YdDdV-kmaQh2guHxGrKE'; // Google API Key

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

  static Future<List<double>> calculateDistances(
      LatLng currentPosition, List<LatLng> suggestionPositions) async {
    List<double> distances = [];
    for (var position in suggestionPositions) {
      double distance = await Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        position.latitude,
        position.longitude,
      );
      distance /= 1000; // Convert meters to kilometers
      distances.add(distance);
    }
    return distances;
  }

  static Future<List<String>> getSearchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('searchHistory') ?? [];
  }

  static Future<void> saveSearchHistory(List<String> searchHistory) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('searchHistory', searchHistory);
  }
}
