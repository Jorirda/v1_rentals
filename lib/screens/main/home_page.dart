import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/home_model.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/main/car_details.dart';

import 'package:v1_rentals/widgets/location_page.dart';
import 'package:v1_rentals/screens/main/search_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // Keep state alive across tab switches

  CustomUser? _currentUser;
  final AuthService _authService = AuthService();
  List<RecommendModel> recommendBrands = [];
  List<Vehicle> vehicles = [];
  bool isDarkMode = false;
  CustomUser? user;
  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _getInitialInfo();
    _loadVehicles();
  }

  Future<void> _onRefresh() async {
    await _loadCurrentUser();
    _getInitialInfo();
    await _loadVehicles();
  }

  void _getInitialInfo() {
    recommendBrands = RecommendModel.getRecommendedBrands();
  }

  Future<void> _loadCurrentUser() async {
    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        user = await _authService.getUserData(firebaseUser.uid);
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _loadVehicles() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('vehicles').get();
      setState(() {
        vehicles =
            querySnapshot.docs.map((doc) => Vehicle.fromMap(doc)).toList();
      });
    } catch (e) {
      print('Error loading vehicles: $e');
    }
  }

  String? _truncateAddress(String? address) {
    const int maxLength = 25; // Maximum length of truncated address
    if (address == null) return null;
    return address.length <= maxLength
        ? address
        : '${address.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Needed for AutomaticKeepAliveClientMixin
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(), // Ensure scrollability
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Theme.of(context).colorScheme.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.grey,
                              child: _currentUser?.imageURL != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(45),
                                      child: Image.network(
                                        _currentUser!.imageURL!,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Text(
                                      _currentUser?.fullname[0].toUpperCase() ??
                                          "",
                                      style: const TextStyle(fontSize: 18),
                                    ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(right: 10, left: 20),
                              child: Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LocationScreen(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.red,
                                        ),
                                        Tooltip(
                                          message: _currentUser?.address ??
                                              'Your location',
                                          child: Text(
                                            _truncateAddress(
                                                    _currentUser?.address) ??
                                                'Your location',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_drop_down,
                                        ),
                                      ],
                                    ),
                                    style: TextButton.styleFrom(
                                        foregroundColor: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${_currentUser?.fullname ?? ""}\u{1F44B}',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Search for your favorite vehicle',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SearchScreen(vehicles),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white),
                                  child: const Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Icon(Icons.search,
                                            color: Colors.red),
                                      ),
                                      Text('Search for vehicles',
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(right: 15),
                          //   child: Container(
                          //     decoration: BoxDecoration(
                          //       color: Theme.of(context).colorScheme.primary,
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //     child: IconButton(
                          //       onPressed: () {
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //             builder: (context) => FilterPage(),
                          //           ),
                          //         );
                          //       },
                          //       icon: const Icon(Icons.filter_list_sharp),
                          //       color: Colors.white,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recommended Brands',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    itemCount: recommendBrands.length,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                    ),
                    separatorBuilder: (context, index) => const SizedBox(
                      width: 25,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        width: 100,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 150,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.black, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 3,
                                    offset: const Offset(
                                        3, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(
                                    recommendBrands[index].iconPath),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'All Vehicles in Collection',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CarDetailsScreen(vehicles[index]),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          width: 280,
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildVehicleImage(vehicles[
                                    index]), // Use the method to build image
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            vehicles[index].brand,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                vehicles[index]
                                                    .rating
                                                    .toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(),
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
                                              Text(
                                                vehicles[index]
                                                    .getTransmissionTypeString(),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.monetization_on,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${vehicles[index].pricePerDay}/Day',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                    color: Colors.red),
                                              ),
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
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleImage(Vehicle vehicle) {
    if (vehicle.imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: CachedNetworkImage(
          imageUrl: vehicle.imageUrl,
          cacheManager:
              CustomCacheManager.instance, // Use the custom cache manager
          width: 280,
          height: 120,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 280,
            height: 120,
            color: Colors.grey,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    } else {
      return Container(
        width: 280,
        height: 120,
        color: Colors.grey,
        child: const Icon(Icons.image, size: 50, color: Colors.white),
      );
    }
  }
}

class CustomCacheManager {
  static const key = 'customCacheKey';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 30), // Longer cache duration
      maxNrOfCacheObjects: 100, // Increase max number of cached objects
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}
