import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/main/car_details.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/screens/main/vendor_store.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<Vehicle>> favoritesFuture;
  List<Vehicle> _allFavorites = [];
  List<Vehicle> _filteredFavorites = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    favoritesFuture = fetchFavorites();
    _searchController.addListener(_onSearchChanged);
  }

  Future<List<Vehicle>> fetchFavorites() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .get();

    List<Vehicle> vehicles = [];
    for (var doc in querySnapshot.docs) {
      String vehicleId = doc.id;
      DocumentSnapshot vehicleDoc = await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(vehicleId)
          .get();
      if (vehicleDoc.exists) {
        Vehicle vehicle = Vehicle.fromMap(vehicleDoc);
        vehicles.add(vehicle);
      }
    }
    return vehicles;
  }

  void _onSearchChanged() {
    String searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _filteredFavorites = _allFavorites.where((vehicle) {
        return vehicle.brand.toString().toLowerCase().contains(searchQuery) ||
            vehicle.modelYear.toLowerCase().contains(searchQuery) ||
            vehicle.pricePerDay.toString().contains(searchQuery) ||
            vehicle.color.toLowerCase().contains(searchQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${S.of(context).favorites} \u{2764} '),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: S.of(context).search_for_favorite_vehicle,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Vehicle>>(
              future: favoritesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (_allFavorites.isEmpty && snapshot.hasData) {
                  _allFavorites = snapshot.data!;
                  _filteredFavorites = _allFavorites;
                }

                if (_filteredFavorites.isEmpty) {
                  return Center(child: Text('No favorites found'));
                }

                return ListView.builder(
                  itemCount: _filteredFavorites.length,
                  itemBuilder: (context, index) {
                    final vehicle = _filteredFavorites[index];
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(vehicle.vendorId)
                          .get(),
                      builder: (context, vendorSnapshot) {
                        if (vendorSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (vendorSnapshot.hasError) {
                          return Center(
                              child: Text('Error: ${vendorSnapshot.error}'));
                        }

                        final vendorData = vendorSnapshot.data!.data()
                            as Map<String, dynamic>?;

                        // Check if vendorData is not null before accessing its properties
                        final businessName =
                            vendorData?['businessName'] ?? 'Unknown';

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarDetailsScreen(vehicle),
                              ),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 2.0),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VendorStorePage(
                                              vendorId: vehicle.vendorId),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.storefront_sharp,
                                            color: Colors.red),
                                        Text(businessName),
                                        Icon(Icons.arrow_forward),
                                        Spacer(),
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(Icons.favorite),
                                          color: Colors.red,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 150,
                                        height:
                                            100, // Set the desired height here
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl: vehicle.imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${vehicle.brand} ${vehicle.modelYear}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    color: Colors.yellow,
                                                  ),
                                                  Text(
                                                    '${vehicle.rating}',
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                '\$${vehicle.pricePerDay}/Day',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 20),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
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
