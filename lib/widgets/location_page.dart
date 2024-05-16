import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/widgets/add_dropoff_location.dart';
import 'package:v1_rentals/widgets/add_pickup_location.dart';
import 'package:v1_rentals/widgets/location_map.dart';
import 'dart:async';
import 'package:v1_rentals/widgets/location_service.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  late GoogleMapController _mapController;
  LatLng _currentPosition =
      const LatLng(13.081781693391143, -59.48398883384077);
  String _currentAddress = '';
  final TextEditingController _searchController = TextEditingController();
  List<String> _suggestions = [];
  List<LatLng> _suggestionPositions = [];
  List<double> _suggestionDistances = [];
  final List<String> _searchHistory = [];
  final List<String> _popularLocations = ['Popular 1', 'Popular 2'];
  bool _isLoading = false;
  bool _showSearchHistory = true;
  Timer? _debounce;
  AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (_searchController.text.isEmpty) {
        setState(() {
          _suggestions.clear();
          _showSearchHistory = true;
        });
      } else {
        await _getSuggestions(_searchController.text);
        setState(() {
          _showSearchHistory = false;
        });
      }
    });
  }

  Future<void> _initializeLocation() async {
    try {
      LatLng position = await LocationService.getCurrentLocation();
      String address = await LocationService.updatePosition(position);
      setState(() {
        _currentPosition = position;
        _currentAddress = address;
      });
    } catch (e) {
      print('Error initializing location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing location: $e')),
      );
    }
  }

  Future<void> _getSuggestions(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> results =
          await LocationService.getSuggestions(query);
      List<String> descriptions = [];
      List<String> placeIds = [];

      for (var result in results) {
        descriptions.add(result['description']);
        placeIds.add(result['place_id']);
      }

      setState(() {
        _suggestions = descriptions;
      });

      List<LatLng> positions =
          await LocationService.getSuggestionDetails(placeIds);
      setState(() {
        _suggestionPositions = positions;
      });

      List<double> distances = await LocationService.calculateDistances(
          _currentPosition, _suggestionPositions);
      setState(() {
        _suggestionDistances = distances;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching suggestions: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching suggestions: $e')),
      );
    }
  }

  void _showMapSection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(initialPosition: _currentPosition),
      ),
    );
  }

  void _saveSearchHistory(String search) {
    setState(() {
      _searchHistory.remove(search);
      _searchHistory.insert(0, search);
    });
  }

  Widget _buildHistoryAndPopularLocations() {
    return ListView(
      children: [
        _buildSearchHistory(),
        _buildPopularLocations(),
      ],
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SetPickupLocationScreen()),
                    );
                  },
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_circle_up, color: Colors.red),
                      Text('Pick-up',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary)),
                      Text('Set Address'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SetDropoffLocationScreen()),
                    )
                  },
                  child: Column(
                    children: [
                      const Icon(Icons.arrow_circle_down, color: Colors.red),
                      Text('Drop-off',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary)),
                      Text('Set Address'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _showMapSection,
                  child: Column(
                    children: [
                      Icon(Icons.map_sharp, color: Colors.red),
                      Text('Use Map',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary)),
                      Text('Drag Map'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Icon(Icons.access_time),
              SizedBox(width: 5),
              Text(
                'History',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.all(8.0),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _searchHistory.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(_searchHistory[index]),
                onTap: () {
                  _searchController.text = _searchHistory[index];
                  _saveSearchHistory(_searchHistory[index]);
                  _getSuggestions(_searchHistory[index]);
                  setState(() {
                    _showSearchHistory = false;
                  });
                },
                subtitle: _suggestionDistances.length > index
                    ? Text(
                        '${_suggestionDistances[index].toStringAsFixed(1)} km')
                    : null,
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularLocations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(Icons.star),
              SizedBox(width: 5),
              Text(
                'Popular Locations',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Card(
          margin: const EdgeInsets.all(8.0),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _popularLocations.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(_popularLocations[index]),
                onTap: () {
                  _searchController.text = _popularLocations[index];
                  _saveSearchHistory(_popularLocations[index]);
                  _getSuggestions(_popularLocations[index]);
                  setState(() {
                    _showSearchHistory = false;
                  });
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for a location',
            contentPadding:
                EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _getSuggestions(_searchController.text);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _showSearchHistory
              ? _buildHistoryAndPopularLocations()
              : _buildSuggestionsList(),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildSuggestionsList() {
    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.location_on),
          title: Text(_suggestions[index]),
          onTap: () async {
            String selectedLocation = _suggestions[index];
            // _searchController.text = selectedLocation;
            _saveSearchHistory(selectedLocation);
            // await _getSuggestions(selectedLocation);
            setState(() {
              _showSearchHistory = false;
            });
            // Show bottom sheet
            _showBottomSheet(context, selectedLocation);
          },
          subtitle: _suggestionDistances.length > index
              ? Text('${_suggestionDistances[index].toStringAsFixed(1)} km')
              : null,
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, String? selectedLocation) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Ensure selectedLocation and userId are not null
                    if (selectedLocation != null) {
                      CustomUser? currentUser =
                          await authService.getCurrentUser();
                      if (currentUser != null && currentUser.userId != null) {
                        // Update user's address
                        await authService.updateUserAddress(
                            currentUser.userId!, selectedLocation);
                        // Inform user
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Address updated successfully')),
                        );
                      } else {
                        // Handle scenario where no user is signed in or userId is null
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('No user signed in or userId is null')),
                        );
                      }
                    }
                    // Close the bottom sheet
                    Navigator.of(context).pop();
                  },
                  child: Text('Set Current User Address'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
