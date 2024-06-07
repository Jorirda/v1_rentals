import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/models/home_model.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/main/car_details.dart';

class CategoriesScreen extends StatefulWidget {
  final String? selectedBrand;

  const CategoriesScreen({super.key, this.selectedBrand});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  static const String allBrands = 'All Brands';

  late String _selectedBrand;
  late int _selectedTabIndex;
  late TabController _tabController;
  List<Vehicle> _vehicles = [];
  List<Vehicle> _filteredVehicles = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _selectedBrand = widget.selectedBrand ?? allBrands;
    _selectedTabIndex = 0;
    _tabController = TabController(length: CarType.values.length, vsync: this);
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('vehicles').get();
      setState(() {
        _vehicles =
            querySnapshot.docs.map((doc) => Vehicle.fromMap(doc)).toList();
        _isLoading = false;
        _filterVehicles();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print('Error loading vehicles: $e');
    }
  }

  void _filterVehicles() {
    setState(() {
      String searchText = _searchController.text.toLowerCase();
      CarType selectedCarType = CarType.values[_selectedTabIndex];

      _filteredVehicles = _vehicles.where((vehicle) {
        bool matchesBrand = _selectedBrand == allBrands ||
            vehicle.brand.toString().split('.').last == _selectedBrand;
        bool matchesCarType = selectedCarType == CarType.all ||
            vehicle.carType == selectedCarType;
        bool matchesSearch =
            vehicle.overview.toLowerCase().contains(searchText);

        return matchesBrand && matchesCarType && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: S.of(context).search_for_vehicles,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                ),
                onChanged: (value) => _filterVehicles(),
              ),
              IconButton(
                icon: const Icon(Icons.search, color: Colors.red),
                onPressed: () => _filterVehicles(),
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          SingleChildScrollView(
            child: IntrinsicHeight(
              child: NavigationRail(
                selectedIndex:
                    _selectedBrand == allBrands ? 0 : _getSelectedIndex(),
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedBrand = index == 0
                        ? allBrands
                        : Brand.values[index - 1].toString().split('.').last;
                    _filterVehicles();
                  });
                },
                labelType: NavigationRailLabelType.selected,
                destinations: [
                  NavigationRailDestination(
                    icon: const Icon(Icons.car_rental),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(S.of(context).all_brands),
                    ),
                  ),
                  ...RecommendModel.getRecommendedBrands()
                      .map((RecommendModel brand) {
                    return NavigationRailDestination(
                      icon: _buildBrandImage(brand.iconPath),
                      label: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(brand.brand
                            .getTranslation()), // Updated translation
                      ),
                    );
                  }),
                ],
                selectedLabelTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelTextStyle: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: CarType.values.map((CarType type) {
                    return Tab(
                        text: type.getTranslation()); // Updated translation
                  }).toList(),
                  onTap: (int index) {
                    setState(() {
                      _selectedTabIndex = index;
                      _filterVehicles();
                    });
                  },
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _hasError
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(S.of(context).error_loading_vehicles),
                                  ElevatedButton(
                                    onPressed: _loadVehicles,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _filteredVehicles.isEmpty
                              ? Center(
                                  child: Text(S.of(context).no_vehicles_found))
                              : SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                        children: [_buildVehicleList(context)]),
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getSelectedIndex() {
    return Brand.values
            .indexWhere((b) => b.toString().split('.').last == _selectedBrand) +
        1;
  }

  Widget _buildBrandImage(String assetPath) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Image.asset(assetPath),
    );
  }

  Widget _buildVehicleList(BuildContext context) {
    return Column(
      children: _filteredVehicles.map((vehicle) {
        return Column(
          children: [
            Material(
              elevation: 4,
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarDetailsScreen(vehicle),
                    ),
                  );
                },
                child: SizedBox(
                  width: 300,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(vehicle.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  '${vehicle.brand.getTranslation()} ${vehicle.model}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      vehicle.getTransmissionTypeString(),
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      vehicle.rating.toString(),
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'USD\$${vehicle.pricePerDay}/${S.of(context).day}',
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        );
      }).toList(),
    );
  }
}
