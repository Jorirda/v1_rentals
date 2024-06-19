import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/models/home_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/screens/main/car_details.dart';
import 'package:v1_rentals/widgets/filter_page.dart'; // Import the filter page
import 'package:cached_network_image/cached_network_image.dart';
import 'package:v1_rentals/widgets/shimmer_widget.dart';

class CategoriesScreen extends StatefulWidget {
  final String? selectedBrand;

  const CategoriesScreen({Key? key, this.selectedBrand}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState(selectedBrand);
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  static const String allBrands = 'All Brands';

  late String _selectedBrand;
  late int _selectedRailIndex;
  late int _selectedTabIndex;
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  late TabController _tabController;
  final List<RecommendModel> _recommendBrands =
      RecommendModel.getRecommendedBrands();
  late Map<String, int> _brandToRailIndex;

  // Filter variables
  CarType? _selectedCarType;
  FuelType? _selectedFuelType;
  TransmissionType? _selectedTransmissionType;
  RangeValues _priceRange = RangeValues(0, 1000);

  _CategoriesScreenState(String? selectedBrand) {
    _selectedBrand = selectedBrand ?? allBrands;
    _selectedRailIndex = 0;
    _selectedTabIndex = 0;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: CarType.values.length, vsync: this);

    _brandToRailIndex = {
      allBrands: 0,
      for (int i = 0; i < _recommendBrands.length; i++)
        _recommendBrands[i].brand.getTranslation(): i + 1,
    };

    _selectedRailIndex = _brandToRailIndex[_selectedBrand] ?? 0;
  }

  @override
  void dispose() {
    searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: CarType.values.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.red,
                  ),
                  hintText: S.of(context).search_for_vehicles,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () async {
                final result = await showModalBottomSheet<Map<String, dynamic>>(
                  context: context,
                  builder: (context) => FilterPage(
                    initialFuelType: _selectedFuelType,
                    initialTransmissionType: _selectedTransmissionType,
                    initialPriceRange: _priceRange,
                  ),
                );
                if (result != null) {
                  setState(() {
                    _selectedFuelType = result['fuelType'];
                    _selectedTransmissionType = result['transmissionType'];
                    _priceRange = result['priceRange'];
                  });
                }
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: CarType.values.map((CarType type) {
              return Tab(text: type.getTranslation());
            }).toList(),
            onTap: (int index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: Row(
          children: [
            SingleChildScrollView(
              child: IntrinsicHeight(
                child: NavigationRail(
                  selectedIndex: _selectedRailIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedRailIndex = index;
                      _selectedTabIndex = 0;
                      _selectedBrand = index == 0
                          ? allBrands
                          : _recommendBrands[index - 1].brand.getTranslation();
                    });
                  },
                  labelType: NavigationRailLabelType.selected,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.directions_car),
                      label: Text(S.of(context).all_brands),
                    ),
                    ..._recommendBrands.map((brand) {
                      return NavigationRailDestination(
                        icon: SizedBox(
                            width: 24,
                            height: 24,
                            child: Image.asset(brand.iconPath)),
                        label: Text(brand.brand.getTranslation()),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            VerticalDivider(width: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('vehicles')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ShimmerWidget();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(S.of(context).no_vehicles_found),
                      );
                    }
                    final vehicles = snapshot.data!.docs
                        .map((doc) => Vehicle.fromMap(doc))
                        .toList()
                        .where((vehicle) {
                      final matchesQuery = (vehicle.brand
                              .getTranslation()
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          vehicle.model
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          vehicle.carType.name
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()));

                      final matchesBrand = (_selectedBrand == allBrands ||
                          vehicle.brand.name.toLowerCase() ==
                              _selectedBrand.toLowerCase());

                      final matchesCarType = (_selectedCarType == null ||
                          vehicle.carType == _selectedCarType);

                      final matchesFuelType = (_selectedFuelType == null ||
                          vehicle.fuelType == _selectedFuelType);

                      final matchesTransmissionType =
                          (_selectedTransmissionType == null ||
                              vehicle.transmission ==
                                  _selectedTransmissionType);

                      final matchesPriceRange =
                          (vehicle.pricePerDay >= _priceRange.start &&
                              vehicle.pricePerDay <= _priceRange.end);

                      return matchesQuery &&
                          matchesBrand &&
                          matchesCarType &&
                          matchesFuelType &&
                          matchesTransmissionType &&
                          matchesPriceRange;
                    }).toList();
                    return TabBarView(
                      controller: _tabController,
                      children: CarType.values.map((carType) {
                        final filteredVehicles = carType == CarType.all
                            ? vehicles
                            : vehicles
                                .where((vehicle) => vehicle.carType == carType)
                                .toList();
                        return buildVehicleList(filteredVehicles);
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVehicleList(List<Vehicle> vehicles) {
    if (vehicles.isEmpty) {
      return Center(child: Text(S.of(context).no_vehicles_found));
    }
    return ListView.builder(
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        return Column(
          children: [
            const SizedBox(height: 20),
            Material(
              elevation: 4,
              color: Theme.of(context).colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      child: CachedNetworkImage(
                        imageUrl: vehicle.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Center(child: ShimmerWidget()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${vehicle.brand.getTranslation()} ${vehicle.model} ${vehicle.modelYear}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.car_rental),
                                  const SizedBox(width: 4),
                                  Text(vehicle.getCarTypeString()),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.settings),
                                  const SizedBox(width: 4),
                                  Text(vehicle.getTransmissionTypeString()),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.monetization_on),
                                  const SizedBox(width: 4),
                                  Text('${vehicle.pricePerDay}/Day'),
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
            ),
            const SizedBox(height: 30),
          ],
        );
      },
    );
  }
}
