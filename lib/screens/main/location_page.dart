import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({Key? key}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late String lat = '';
  late String long = '';
  late String address = '';
  late LatLng _center = LatLng(0, 0);
  bool _isLoading = true;

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          lat = position.latitude.toString();
          long = position.longitude.toString();
          address =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
          _center = LatLng(position.latitude, position.longitude);
          _isLoading =
              false; // Set loading indicator to false when data is available
        });
      } else {
        setState(() {
          address = 'No address found';
          _isLoading =
              false; // Set loading indicator to false even if no address is found
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false; // Set loading indicator to false if an error occurs
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Location"),
      ),
      body: _buildMap(),
    );
  }

  Widget _buildMap() {
    if (_isLoading) {
      return Center(
        child:
            CircularProgressIndicator(), // Show a loading indicator while data is being fetched
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Current location of User:'),
            Text('Latitude: $lat'),
            Text('Longitude: $long'),
            Text('Address: $address'),
            SizedBox(
              height: 300,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  // You can use this to interact with the map once created.
                },
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 15.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('userLocation'),
                    position: _center,
                    infoWindow: InfoWindow(
                      title: 'Your Location',
                      snippet: address,
                    ),
                  ),
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _getCurrentLocation();
              },
              child: const Text('Get Current Location'),
            )
          ],
        ),
      );
    }
  }
}
