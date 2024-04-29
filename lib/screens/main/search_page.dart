import 'package:flutter/material.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/clients/car_details.dart';

class SearchScreen extends StatefulWidget {
  final List<Vehicle> vehicles;

  const SearchScreen(this.vehicles, {Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Vehicle> _searchResults = [];
  List<String> _recentSearches = [];
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchQueryChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _searchResults = [];
    });
  }

  void _handleSearch() {
    setState(() {
      _searchResults = widget.vehicles.where((vehicle) {
        return vehicle.brand.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      // Remove any existing duplicates of the search query
      _recentSearches.removeWhere(
          (query) => query.toLowerCase() == _searchQuery.toLowerCase());

      // Add the new search query to the beginning of the recent searches list
      _recentSearches.insert(0, _searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search rentals',
            border: InputBorder.none,
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          onSubmitted: (value) {
            _handleSearch();
          },
        ),
      ),
      body: _searchQuery.isNotEmpty
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
              ),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CarDetailsScreen(_searchResults[index]),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Image.network(
                            _searchResults[index].imageUrl,
                            width: double.infinity, // Use full width
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _searchResults[index].brand,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.settings),
                                      const SizedBox(width: 4),
                                      Text(_searchResults[index].transmission),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.monetization_on),
                                      const SizedBox(width: 4),
                                      Text(
                                          '${_searchResults[index].pricePerDay}/Day'),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _recentSearches.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_recentSearches[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _recentSearches.removeAt(index);
                            });
                          },
                        ),
                        onTap: () {
                          _searchController.text = _recentSearches[index];
                          _handleSearch();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
