import 'package:flutter/material.dart';
import 'package:v1_rentals/widgets/location_service.dart';

class SetPickupLocationScreen extends StatefulWidget {
  const SetPickupLocationScreen({Key? key}) : super(key: key);

  @override
  _SetPickupLocationScreenState createState() =>
      _SetPickupLocationScreenState();
}

class _SetPickupLocationScreenState extends State<SetPickupLocationScreen> {
  late TextEditingController _searchController;
  bool _isLoading = false;
  bool _showSearchHistory = true;
  List<String> _suggestions = [];
  List<double> _suggestionDistances = [];
  List<String> _searchHistory = [];
  List<String> _popularLocations = ['Popular 1', 'Popular 2'];
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
    _loadSearchHistory();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
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
  }

  Future<void> _loadSearchHistory() async {
    _searchHistory = await LocationService.getSearchHistory();
  }

  Future<void> _getSuggestions(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> suggestions =
          await LocationService.getSuggestions(query);
      final List<String> suggestionDescriptions = suggestions
          .map((suggestion) => suggestion['description'] as String)
          .toList();

      setState(() {
        _suggestions = suggestionDescriptions;
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

  void _saveSearchHistory(String search) {
    setState(() {
      _searchHistory.remove(search); // Remove if already exists
      _searchHistory.insert(0, search); // Add to the top of the list
      LocationService.saveSearchHistory(_searchHistory);
    });
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('My Location',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.map_sharp, color: Colors.red),
                      const SizedBox(
                        width: 5,
                      ),
                      Text('Use Map',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ],
              ),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
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
        ),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.location_on),
            title: Text(_suggestions[index]),
            onTap: () async {
              String selectedLocation = _suggestions[index];
              _searchController.text = selectedLocation;
              _saveSearchHistory(selectedLocation);
              await _getSuggestions(selectedLocation);
              setState(() {
                _showSearchHistory = false;
              });
            },
            subtitle: _suggestionDistances.length > index
                ? Text('${_suggestionDistances[index].toStringAsFixed(1)} km')
                : null,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Pickup Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
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
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
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
