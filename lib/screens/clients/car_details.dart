import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../main/home_page.dart';

class CarDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const CarDetailsScreen(this.vehicle, {Key? key}) : super(key: key);

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  late TabController tabController;
  CustomUser? vendor;
  late List<Map<String, dynamic>> features;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    fetchVendorInfo();
    initializeFeatures();
    setupFavoriteListener();
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
    features = [
      {
        'title': 'Type',
        'icon': Icons.directions_car,
        'subtitle': widget.vehicle.getCarTypeString(),
      },
      {
        'title': 'Seats',
        'icon': Icons.event_seat,
        'subtitle': '${widget.vehicle.seats} seats',
      },
      {
        'title': 'Fuel ',
        'icon': Icons.local_gas_station,
        'subtitle': widget.vehicle.getFuelTypeString(),
      },
      {
        'title': 'Transmission ',
        'icon': Icons.settings,
        'subtitle': widget.vehicle.getTransmissionTypeString(),
      },
    ];
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
      widget.vehicle.isFavorite = !widget.vehicle.isFavorite; // Toggle the local state
      isFavorite = widget.vehicle.isFavorite; // Update the local isFavorite for UI
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
      setState(() {  // Revert if failed
        widget.vehicle.isFavorite = !widget.vehicle.isFavorite;
        isFavorite = widget.vehicle.isFavorite;
      });
    }
  }







  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
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
                    Text(
                      vendor!.fullname,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vendor!.businessName ?? 'No Business Name',
                      style: TextStyle(
                        color: Colors.grey[300],
                      ),
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
                      offset: Offset(0, 3), // changes the position of the shadow
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
                child: widget.vehicle.imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: widget.vehicle.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error_outline),
                  cacheManager: CustomCacheManager.instance,
                )
                    : Container(color: Colors.grey),
              ),
            ),
            // Other actions...
          ),
          // SliverList implementation remains the same...
        ],
      ),
      // Bottom navigation bar remains the same...
    );
  }
}