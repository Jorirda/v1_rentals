import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/location/search_history_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/widgets/dropoff_location.dart';
import 'package:v1_rentals/widgets/pickup_location.dart';
import 'package:v1_rentals/widgets/location_service.dart';

import 'dart:async';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  LatLng _currentPosition =
      const LatLng(13.081781693391143, -59.48398883384077);
  String _currentLocation = '';

  final List<SearchHistory> _searchHistory =
      []; // Update to store SearchHistory objects
  final List<String> _popularLocations = ['Popular 1', 'Popular 2'];
  final AuthService _authService = AuthService();
  final LocationService _locationService =
      LocationService(); // Ensure you have an instance of LocationService

  String _pickupLocation = 'Set Address';
  String _dropoffLocation = 'Set Address';

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _fetchSearchHistory(); // Fetch search history when initializing
  }

  Future<void> _initializeLocation() async {
    try {
      LatLng position = await LocationService.getCurrentLocation();
      String address = await LocationService.updatePosition(position);
      setState(() {
        _currentPosition = position;
        _currentLocation = address;
      });
    } catch (e) {
      _showError('Error initializing location: $e');
    }
  }

  Future<void> _fetchSearchHistory() async {
    try {
      CustomUser? currentUser = await _authService.getCurrentUser();
      if (currentUser != null && currentUser.userId != null) {
        List<SearchHistory> searchHistory =
            await _locationService.getSearchHistory(currentUser.userId!);
        setState(() {
          _searchHistory
            ..clear()
            ..addAll(
                searchHistory.reversed); // Reverse the list and add all items
        });
      }
    } catch (e) {
      _showError('Error fetching search history: $e');
    }
  }

  Future<void> _clearSearchHistory() async {
    try {
      CustomUser? currentUser = await _authService.getCurrentUser();
      if (currentUser != null && currentUser.userId != null) {
        await _locationService.clearSearchHistory(currentUser.userId!);
        setState(() {
          _searchHistory.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search history cleared successfully')),
        );
      }
    } catch (e) {
      _showError('Error clearing search history: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildLocationOption(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    const int maxSubtitleLength = 20;
    String truncatedSubtitle = subtitle.length > maxSubtitleLength
        ? '${subtitle.substring(0, maxSubtitleLength)}...'
        : subtitle;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.red, size: 40),
          Text(title,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          Tooltip(
            message: subtitle,
            child: Text(
              truncatedSubtitle,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 20),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              SizedBox(width: 5),
              Text(
                'Current Location Address',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.all(12.0),
          child: ListTile(
            leading: const Icon(Icons.location_on_outlined, color: Colors.red),
            title: Text(_currentLocation),
            trailing: IconButton(
              onPressed: _initializeLocation,
              icon: const Icon(Icons.my_location),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.red),
          const SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Spacer(),
          if (title == 'History')
            TextButton(
              onPressed: _clearSearchHistory,
              child: Text(
                'clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListSection(List<SearchHistory> items, String headerTitle,
      IconData headerIcon, ValueChanged<int> onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildSectionHeader(headerIcon, headerTitle),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.all(12.0),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading:
                    const Icon(Icons.location_on_outlined, color: Colors.red),
                title: Text(
                  items[index].locationName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                subtitle: Text(items[index].address),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context, String? selectedLocation) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () async {
                  if (selectedLocation != null) {
                    CustomUser? currentUser =
                        await _authService.getCurrentUser();
                    if (currentUser != null && currentUser.userId != null) {
                      await _authService.updateUserAddress(
                          currentUser.userId!, selectedLocation);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Address updated successfully')),
                      );
                    } else {
                      _showError('No user signed in or userId is null');
                    }
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Set Current User Address'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Theme.of(context).colorScheme.primary,
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLocationOption(
                  Icons.arrow_circle_up_sharp,
                  'Pick-up',
                  _pickupLocation,
                  () async {
                    final selectedLocation = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SetPickupLocationScreen(
                              historyLocations: _searchHistory)),
                    );
                    if (selectedLocation != null) {
                      setState(() {
                        _pickupLocation = selectedLocation;
                      });
                    }
                  },
                ),
                _buildLocationOption(
                  Icons.arrow_circle_down,
                  'Drop-off',
                  _dropoffLocation,
                  () async {
                    final selectedLocation = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SetDropoffLocationScreen(
                              historyLocations: _searchHistory)),
                    );
                    if (selectedLocation != null) {
                      setState(() {
                        _dropoffLocation = selectedLocation;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
      ),
      body: ListView(
        children: [
          _buildLocationOptions(),
          _buildCurrentLocation(),
          _buildListSection(
            _searchHistory,
            'History',
            Icons.access_time_filled_sharp,
            (index) {
              // Implement the onTap functionality if needed
            },
          ),
          _buildListSection(
            _popularLocations
                .map((location) => SearchHistory(
                      locationName: location,
                      address: '',
                      latitude: 0.0,
                      longitude: 0.0,
                    ))
                .toList(),
            'Popular Locations',
            Icons.star,
            (index) {
              // Implement the onTap functionality if needed
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
