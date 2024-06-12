import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/models/locations_model.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/models/search_history_model.dart';
import 'package:v1_rentals/providers/location_provider.dart';

class SetDropoffLocationScreen extends StatefulWidget {
  const SetDropoffLocationScreen({super.key, required this.historyLocations});

  final List<SearchHistory> historyLocations;

  @override
  _SetDropoffLocationScreenState createState() =>
      _SetDropoffLocationScreenState();
}

class _SetDropoffLocationScreenState extends State<SetDropoffLocationScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  bool _isLoading = false;
  bool _showSearchHistory = true;
  List<String> _suggestions = [];
  Map<String, dynamic> _suggestionMap =
      {}; // Map to store suggestions and their LatLng
  Timer? _debounce;

  late LocationProvider _locationProvider;

  @override
  void initState() {
    super.initState();
    _locationProvider = Provider.of<LocationProvider>(context, listen: false);
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
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
      final LatLng currentLatLng = await _locationProvider.getCurrentLocation();
      final List<Map<String, dynamic>> suggestions =
          await _locationProvider.getSuggestions(query);
      final List<String> placeIds = suggestions
          .map((suggestion) => suggestion['place_id'] as String)
          .toList();
      final List<LatLng> suggestionPositions =
          await _locationProvider.getSuggestionDetails(placeIds);
      final List<double> suggestionDistances = await _locationProvider
          .calculateDistances(currentLatLng, suggestionPositions);

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
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final searchHistory = locationProvider.searchHistory;
        final popularLocations = locationProvider.popularLocations;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _getCurrentLocation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 5),
                          Text(
                            S.of(context).my_location,
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
                      S.of(context).history,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Clear all search history
                        locationProvider.clearSearchHistory();
                      },
                      child: Text(
                        S.of(context).clear,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
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
                    itemCount: searchHistory.length,
                    itemBuilder: (context, index) {
                      final location = searchHistory[index];
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
                        subtitle: Text(location.address),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            // Delete the search history item
                            locationProvider
                                .deleteSearchHistoryItem(location.id!);
                          },
                        ),
                        onTap: () {
                          _showConfirmationBottomSheet(
                            location.locationName,
                            LatLng(location.latitude, location.longitude),
                            location.address,
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ),
              ),
              _buildPopularLocations(popularLocations),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopularLocations(List<Locations> popularLocations) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.red,
                ),
                const SizedBox(width: 5),
                Text(
                  S.of(context).popular_locations,
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
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: popularLocations.length,
              itemBuilder: (context, index) {
                final location = popularLocations[index];
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
                  subtitle: Text(location.address ?? ''),
                  onTap: () {
                    setState(() {
                      _searchController.text = location.locationName;
                      _showSearchHistory = false;
                    });
                    _getSuggestions(location.locationName);
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
        ],
      ),
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
                await _locationProvider.saveSearchHistory(searchHistory);
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
              Text(
                ' ${S.of(context).confirm_your_selection} :',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                selectedLocation,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    Locations DropoffLocation = Locations(
                      locationName: selectedLocation,
                      address: address,
                      latitude: selectedLatLng.latitude,
                      longitude: selectedLatLng.longitude,
                    );

                    await _locationProvider
                        .saveDropoffLocation(DropoffLocation);

                    // Close the bottom sheet
                    Navigator.pop(context);
                    // Return the selected location to the previous screen
                    Navigator.pop(context, selectedLocation);
                  } catch (e) {
                    print('Error saving Dropoff location: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Error saving Dropoff location')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(S.of(context).confirm_dropoff_location),
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
      final LatLng currentLatLng = await _locationProvider.getCurrentLocation();
      await _locationProvider.updatePosition(currentLatLng);

      // Perform reverse geocoding to get the address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentLatLng.latitude,
        currentLatLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        final String currentLocation = '${place.name}';
        final String address = '${place.locality}, ${place.country}';
        setState(() {
          _isLoading = false;
        });

        _showConfirmationBottomSheet(
          currentLocation,
          currentLatLng,
          address,
        );
      } else {
        throw Exception('No address found');
      }
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
        title: Text(S.of(context).set_dropoff_location),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: S.of(context).search_for_locations,
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
                          setState(() {
                            _showSearchHistory = true;
                          });
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
                      ? Column(
                          children: [
                            _buildSearchHistory(),
                          ],
                        )
                      : _buildSuggestionsList(),
                ),
        ],
      ),
    );
  }
}
