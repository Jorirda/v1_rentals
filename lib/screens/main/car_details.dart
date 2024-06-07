import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:v1_rentals/screens/main/booking_page.dart';
import 'package:v1_rentals/screens/main/vendor_store.dart';

import 'package:v1_rentals/generated/l10n.dart';

class CarDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const CarDetailsScreen(this.vehicle, {super.key});

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  bool isFavorite = false;

  CustomUser? vendor;
  late List<Map<String, dynamic>> features = [];

  @override
  void initState() {
    super.initState();
    fetchVendorInfo();
    setupFavoriteListener();

    // Delay the initialization of features until after the first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeFeatures();
    });
  }

  void setupFavoriteListener() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('favorites')
          .doc(widget.vehicle.id)
          .snapshots()
          .listen((documentSnapshot) {
        setState(() {
          isFavorite = documentSnapshot.exists;
        });
        print("Updated isFavorite to: $isFavorite based on database change.");
      });
    }
  }

  // Check if the vehicle is already favorited by the user
  void checkIfFavorite() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("User is not logged in.");
      return;
    }

    DocumentSnapshot favoriteDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('favorites')
        .doc(widget.vehicle.id)
        .get();

    setState(() {
      isFavorite = favoriteDoc.exists;
      print("Initial favorite state is: $isFavorite");
    });
  }

  // Method to initialize features
  void initializeFeatures() {
    setState(() {
      features = [
        {
          'title': S.of(context).type,
          'icon': Icons.directions_car,
          'subtitle': widget.vehicle.getCarTypeString(),
        },
        {
          'title': S.of(context).seats,
          'icon': Icons.event_seat,
          'subtitle': '${widget.vehicle.seats} ${S.of(context).seats}',
        },
        {
          'title': S.of(context).fuel,
          'icon': Icons.local_gas_station,
          'subtitle': widget.vehicle.getFuelTypeString(),
        },
        {
          'title': S.of(context).transmission,
          'icon': Icons.settings,
          'subtitle': widget.vehicle.getTransmissionTypeString(),
        },
        {
          'title': 'F/M Radio',
          'icon': Icons.radio,
          'subtitle': '',
        },
        {
          'title': 'A/C',
          'icon': Icons.air,
          'subtitle': '',
        },
        {
          'title': 'Luggage',
          'icon': Icons.luggage,
          'subtitle': '',
        },
      ];
    });
  }

  // Method to fetch vendor information
  Future<void> fetchVendorInfo() async {
    try {
      CustomUser? vendorData =
          await AuthService().getUserData(widget.vehicle.vendorId);
      setState(() {
        vendor = vendorData;
      });
    } catch (e) {
      print('Error fetching vendor information: $e');
    }
  }

  Future<void> toggleFavorite(String vehicleId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("User is not logged in.");
      return;
    }

    setState(() {
      widget.vehicle.isFavorite =
          !widget.vehicle.isFavorite; // Toggle the local state
      isFavorite =
          widget.vehicle.isFavorite; // Update the local isFavorite for UI
    });

    print("Updating favorite status to: ${widget.vehicle.isFavorite}");

    try {
      if (widget.vehicle.isFavorite) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('favorites')
            .doc(vehicleId)
            .set(widget.vehicle.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('favorites')
            .doc(vehicleId)
            .delete();
      }
      print("Firestore operation successful.");
    } catch (e) {
      print("Failed to update Firestore: $e");
      setState(() {
        // Revert if failed
        widget.vehicle.isFavorite = !widget.vehicle.isFavorite;
        isFavorite = widget.vehicle.isFavorite;
      });
    }
  }

  // Widget to display vendor information
  Widget buildVendorInfo() {
    if (vendor != null) {
      return Card(
        color: Theme.of(context).colorScheme.primary,
        margin: const EdgeInsets.all(16.0),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
                child: vendor?.imageURL != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: CachedNetworkImage(
                          imageUrl: vendor!.imageURL!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          cacheManager: CustomCacheManager.instance,
                        ),
                      )
                    : Text(
                        vendor?.fullname?[0].toUpperCase() ?? "",
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vendor!.businessName ??
                              S.of(context).no_business_name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        const Text(
                          '4.0',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                            onPressed: () {},
                            child: Text('${S.of(context).follow} +'))
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return CircularProgressIndicator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350.0,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset:
                          Offset(0, 3), // changes the position of the shadow
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                child: Image.network(
                  widget.vehicle.imageUrl ?? '',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () async {
                      await toggleFavorite(widget.vehicle.id);
                    },
                    icon: isFavorite
                        ? Icon(Icons.favorite, color: Colors.red)
                        : Icon(
                            Icons.favorite_outline,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset:
                            Offset(0, 3), // changes the position of the shadow
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Add your action here
                    },
                    icon: Icon(Icons.share, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.vehicle.pricePerDay}/${S.of(context).day}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                                color: Colors.red),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.vehicle.rating.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.star,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${widget.vehicle.brand.getTranslation()} ${widget.vehicle.model}  ${widget.vehicle.modelYear}',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.vehicle.overview,
                        maxLines: 3,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      Divider(),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: features.map((feature) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: SizedBox(
                                height: 100,
                                width: 120,
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          feature['icon'],
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          feature['title'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          feature['subtitle'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    S.of(context).vendor,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                buildVendorInfo(),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    S.of(context).reviews,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 100, // Adjust height as needed
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VendorStorePage(
                            vendorId: widget.vehicle.vendorId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.storefront),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  Text(
                    S.of(context).store,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.phone,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    S.of(context).call,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chat_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text(
                    S.of(context).chat,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the booking screen and pass the selected vehicle
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(widget.vehicle),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(S.of(context).book_now),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCacheManager {
  static const key = 'customCacheKey';

  static final CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod:
          const Duration(days: 15), // Adjust the cache duration as needed
      maxNrOfCacheObjects: 100, // Adjust the max number of objects
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );
}
