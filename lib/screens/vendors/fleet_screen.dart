import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/vendors/add_vehicle.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/screens/vendors/vendor_vehicle_details.dart';
import 'package:v1_rentals/generated/l10n.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  _FleetScreenState createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  late TabController _tabController;
  late int _selectedTabIndex;

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = 0;
    _tabController = TabController(length: CarType.values.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: CarType.values.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation:
              0, // Remove the elevation to ensure the app bar blends with the background
          title: Text(
            S.of(context).your_fleet,
            style: const TextStyle(
              color: Colors
                  .black, // Set the text color to black for better contrast
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.black), // Set text color
                  decoration: InputDecoration(
                    suffixIcon: const Icon(
                      Icons.search,
                      color: Colors.red,
                    ),
                    hintText: S.of(context).search_for_vehicles,
                    hintStyle: const TextStyle(
                        color: Colors.grey), // Set hint text color
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: CarType.values.map((CarType type) {
              return Tab(text: type.getTranslation()); // Updated translation
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
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder<CustomUser?>(
            future: AuthService().getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return const Center(
                  child: Text('Error: Unable to fetch user data.'),
                );
              }
              final userId = snapshot.data!.userId;
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('vehicles')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
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
                      .where((vehicle) =>
                          vehicle.brand
                              .getTranslation()
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          vehicle.model
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                          vehicle.carType.name
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                      .toList();
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
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddVehicleForm()),
            );
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
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
                      builder: (context) =>
                          VehicleDetailsPage(vehicle: vehicle),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(vehicle.imageUrl ?? ''),
                            fit: BoxFit.cover),
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
                                  Text('${vehicle.pricePerDay.toString()}/Day'),
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
