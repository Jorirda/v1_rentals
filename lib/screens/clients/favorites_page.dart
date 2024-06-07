import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/main/car_details.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/screens/main/vendor_store.dart';
import 'package:v1_rentals/providers/favorites_provider.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: false);
    favoritesProvider.fetchFavorites();
    _searchController.addListener(() {
      favoritesProvider.filterFavorites(_searchController.text.toLowerCase());
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
            child: Consumer<FavoritesProvider>(
              builder: (context, provider, child) {
                if (provider.filteredFavorites.isEmpty) {
                  return Center(child: Text('No favorites found'));
                }

                return ListView.builder(
                  itemCount: provider.filteredFavorites.length,
                  itemBuilder: (context, index) {
                    final vehicle = provider.filteredFavorites[index];
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
                                        const Icon(Icons.storefront_sharp,
                                            color: Colors.red),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          businessName,
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        const Icon(Icons.arrow_forward),
                                        const Spacer(),
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              provider.isFavorite(vehicle.id)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              if (provider
                                                  .isFavorite(vehicle.id)) {
                                                provider
                                                    .removeFavorite(vehicle);
                                              } else {
                                                provider.addFavorite(vehicle);
                                              }
                                            },
                                          ),
                                        ),
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
                                      SizedBox(
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
                                                '${vehicle.brand.getTranslation()} ${vehicle.model} ',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.settings,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        vehicle
                                                            .getTransmissionTypeString(),
                                                        style: TextStyle(
                                                            color: Colors.grey),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                      ),
                                                      Text(
                                                        '${vehicle.rating}',
                                                        style: TextStyle(
                                                            fontSize: 15),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'USD\$${vehicle.pricePerDay}/${S.of(context).day}',
                                                    style: TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 20),
                                                  ),
                                                ],
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
