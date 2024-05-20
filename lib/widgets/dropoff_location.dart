import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:v1_rentals/models/location/locations_model.dart';

import 'package:v1_rentals/models/location/search_history_model.dart';
import 'package:v1_rentals/widgets/location_service.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';

class SetDropoffLocationScreen extends StatefulWidget {
  const SetDropoffLocationScreen({super.key, required this.historyLocations});

  final List<SearchHistory> historyLocations;
  @override
  _SetDropoffLocationScreenState createState() =>
      _SetDropoffLocationScreenState();
}

class _SetDropoffLocationScreenState extends State<SetDropoffLocationScreen> {
  late TextEditingController _searchController;
  bool _isLoading = false;
  bool _showSearchHistory = true;
  List<String> _suggestions = [];
  List<double> _suggestionDistances = [];
  List<String> _searchHistory = [];
  List<String> _popularLocations = ['Popular 1', 'Popular 2'];
  final LocationService _locationService = LocationService();
  Map<String, dynamic> _suggestionMap =
      {}; // Map to store suggestions and their LatLng

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _confirmSelection(String selectedLocation) {
    Navigator.pop(context,
        selectedLocation); // Pass the selected location back to the previous screen
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (_searchController.text.isEmpty) {
        setState(() {
          _suggestions.clear();
          _showSearchHistory = true;
        });
      } else {
        _getSuggestions(_searchController.text);
        setState(() {
          _showSearchHistory = false;
        });
      }
    });
  }

  Future<void> _getSuggestions(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final LatLng currentLatLng = await LocationService.getCurrentLocation();
      final List<Map<String, dynamic>> suggestions =
          await LocationService.getSuggestions(query);
      final List<String> placeIds = suggestions
          .map((suggestion) => suggestion['place_id'] as String)
          .toList();
      final List<LatLng> suggestionPositions =
          await LocationService.getSuggestionDetails(placeIds);
      final List<double> suggestionDistances =
          await LocationService.calculateDistances(
              currentLatLng, suggestionPositions);

      setState(() {
        _suggestions = suggestions
            .map((suggestion) => suggestion['main_text'] as String)
            .toList();
        _suggestionMap = {
          for (var i = 0; i < suggestions.length; i++)
            suggestions[i]['main_text']: {
              'latlng': suggestionPositions[i],
              'address': suggestions[i]['secondary_text'],
              'distance': suggestionDistances[i],
            }
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching suggestions: $e')),
      );
    }
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: _getCurrentLocation,
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 5),
                    Text(
                      'My Location',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: Colors.grey,
                indent: 10,
                endIndent: 10,
              ),
              TextButton(
                onPressed: () {},
                child: Row(
                  children: [
                    const Icon(Icons.map_sharp, color: Colors.red),
                    const SizedBox(width: 5),
                    Text(
                      'Use Map',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              const Icon(
                Icons.access_time_filled,
                color: Colors.red,
              ),
              const SizedBox(width: 5),
              Text(
                'History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.historyLocations.length,
              itemBuilder: (context, index) {
                final location = widget.historyLocations[index];
                return ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.red,
                  ),
                  title: Text(
                    location.locationName,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),

                  // onTap: () {
                  //   _searchController.text = _searchHistory[index];
                  //   _getSuggestions(_searchHistory[index]);
                  //   setState(() {
                  //     _showSearchHistory = false;
                  //   });
                  // },
                  subtitle: Text(location.address),
                  // trailing: _suggestionDistances.length > index
                  // ? Text(
                  //     '${_suggestionDistances[index].toStringAsFixed(1)} km',
                  //     style:
                  //         TextStyle(color: Theme.of(context).primaryColor),
                  //   )
                  // : null,
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          String suggestion = _suggestions[index];
          var suggestionDetails = _suggestionMap[suggestion];
          return ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
              color: Colors.red,
            ),
            title: Text(
              suggestion,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: suggestionDetails != null
                ? Text(suggestionDetails['address'])
                : null,
            trailing: suggestionDetails != null
                ? Text(
                    '${suggestionDetails['distance'].toStringAsFixed(1)} km',
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
            onTap: () async {
              if (suggestionDetails != null) {
                LatLng selectedLatLng = suggestionDetails['latlng'];
                // Save the search history
                SearchHistory searchHistory = SearchHistory(
                  locationName: suggestion,
                  address: suggestionDetails['address'],
                  latitude: selectedLatLng.latitude,
                  longitude: selectedLatLng.longitude,
                );
                await _locationService.saveSearchHistory(searchHistory);
                // Show confirmation bottom sheet
                _showConfirmationBottomSheet(
                  suggestion,
                  selectedLatLng,
                  suggestionDetails['address'],
                );
              }
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }

  void _showConfirmationBottomSheet(
      String selectedLocation, LatLng selectedLatLng, String address) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Confirm your selection:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                selectedLocation,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    Locations dropOffLocation = Locations(
                      locationName: selectedLocation,
                      address: address,
                      latitude: selectedLatLng.latitude,
                      longitude: selectedLatLng.longitude,
                    );

                    await _locationService.saveDropoffLocation(dropOffLocation);

                    // Close the bottom sheet
                    Navigator.pop(context);
                    // Return the selected location to the previous screen
                    Navigator.pop(context, selectedLocation);
                  } catch (e) {
                    print('Error saving pickup location: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error saving pickup location')),
                    );
                  }
                },
                child: const Text('Confirm Dropoff Selection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final LatLng currentLatLng = await LocationService.getCurrentLocation();
      final String currentLocation =
          await LocationService.updatePosition(currentLatLng);
      setState(() {
        _isLoading = false;
      });
      _showConfirmationBottomSheet(
          currentLocation, currentLatLng, currentLocation);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching current location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Dropoff Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: _showSearchHistory
                      ? _buildSearchHistory()
                      : _buildSuggestionsList(),
                ),
        ],
      ),
    );
  }
}
