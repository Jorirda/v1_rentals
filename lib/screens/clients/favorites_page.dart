import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/screens/main/car_details.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/screens/main/vendor_store.dart';
import 'package:v1_rentals/providers/favorites_provider.dart';
import 'package:v1_rentals/widgets/shimmer_widget.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<void> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    final favoritesProvider =
        Provider.of<FavoritesProvider>(context, listen: false);
    _favoritesFuture = _fetchData(favoritesProvider);

    _searchController.addListener(() {
      favoritesProvider.filterFavorites(_searchController.text.toLowerCase());
    });
  }

  Future<void> _fetchData(FavoritesProvider favoritesProvider) async {
    await favoritesProvider.fetchFavorites();
    await favoritesProvider.fetchVendorNames();
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.red,
                  ),
                  hintText: S.of(context).search_for_favorite_vehicle,
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<void>(
              future: _favoritesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: ShimmerWidget());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error loading favorites'));
                }

                return Consumer<FavoritesProvider>(
                  builder: (context, provider, child) {
                    if (provider.filteredFavorites.isEmpty) {
                      return Center(child: Text('No favorites found'));
                    }

                    return ListView.builder(
                      itemCount: provider.filteredFavorites.length,
                      itemBuilder: (context, index) {
                        final vehicle = provider.filteredFavorites[index];
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
                            elevation: 5,
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
                                        SizedBox(width: 5),
                                        Text(
                                          provider.getBusinessName(
                                              vehicle.vendorId),
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                        SizedBox(width: 5),
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
                                              provider.toggleFavorite(vehicle);
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
                                        height: 100,
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
                                              SizedBox(height: 10),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.settings,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
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
                                                      Icon(Icons.star,
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                      Text('${vehicle.rating}',
                                                          style: TextStyle(
                                                              fontSize: 15)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
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
                                SizedBox(height: 20),
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
