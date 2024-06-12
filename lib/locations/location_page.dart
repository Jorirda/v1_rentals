import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/search_history_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/providers/location_provider.dart';
import 'package:v1_rentals/locations/dropoff_location.dart';
import 'package:v1_rentals/locations/pickup_location.dart';
import 'package:v1_rentals/generated/l10n.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _pickupLocation = '';
  String _dropoffLocation = '';

  final AuthService _authService = AuthService();

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

  Widget _buildCurrentLocation(
      BuildContext context, LocationProvider provider) {
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
                S.of(context).current_location_address,
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
            title: Text(provider.currentLocation),
            trailing: IconButton(
              onPressed: () {
                provider.initializeLocation();
              },
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
          if (title == S.of(context).history)
            TextButton(
              onPressed: () {
                final provider =
                    Provider.of<LocationProvider>(context, listen: false);
                provider.clearSearchHistory();
              },
              child: Text(
                S.of(context).clear,
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListSection(List<SearchHistory> items, String headerTitle,
      IconData headerIcon, ValueChanged<int> onTap,
      {bool showDeleteButton = false, bool showSubtitles = false}) {
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
                subtitle: showSubtitles ? Text(items[index].address) : null,
                trailing: showDeleteButton
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          final provider = Provider.of<LocationProvider>(
                              context,
                              listen: false);
                          provider.deleteSearchHistoryItem(items[index].id!);
                        },
                      )
                    : null,
                onTap: () => onTap(index),
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

  Widget _buildLocationOptions(
      BuildContext context, LocationProvider provider) {
    _pickupLocation = S.of(context).set_address;
    _dropoffLocation = S.of(context).set_address;
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
                  S.of(context).pick_up,
                  _pickupLocation,
                  () async {
                    final selectedLocation = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SetPickupLocationScreen(
                              historyLocations: provider.searchHistory)),
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
                  S.of(context).drop_off,
                  _dropoffLocation,
                  () async {
                    final selectedLocation = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SetDropoffLocationScreen(
                              historyLocations: provider.searchHistory)),
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
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).locations),
      ),
      body: ListView(
        children: [
          _buildLocationOptions(context, locationProvider),
          _buildCurrentLocation(context, locationProvider),
          _buildListSection(
            locationProvider.searchHistory,
            S.of(context).history,
            Icons.access_time_filled_sharp,
            (index) {
              // Implement the onTap functionality if needed
            },
            showSubtitles: true,
            showDeleteButton: true, // Show delete button for history
          ),
          // _buildListSection(
          //   locationProvider.popularLocations
          //       .map((location) => SearchHistory(
          //             locationName: location,
          //             address: '',
          //             latitude: 0.0,
          //             longitude: 0.0,
          //           ))
          //       .toList(),
          //   S.of(context).popular_locations,
          //   Icons.star,
          //   (index) {
          //     // Implement the onTap functionality if needed
          //   },
          //   showDeleteButton:
          //       false, // Do not show delete button for popular locations
          // ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
