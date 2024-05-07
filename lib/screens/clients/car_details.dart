import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';

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
    isFavorite = widget.vehicle.isFavorite;
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

  Future<void> toggleFavorite(String vehicleId, Vehicle vehicle) async {
    setState(() {
      isFavorite = !isFavorite;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        if (isFavorite) {
          // Add vehicle to favorites
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('favorites')
              .doc(vehicleId)
              .set(vehicle.toMap());
        } else {
          // Remove vehicle from favorites
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('favorites')
              .doc(vehicleId)
              .delete();
        }
      }
    } catch (error) {
      print('Error toggling favorite: $error');
      // Handle error
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
                        child: Image.network(
                          vendor!.imageURL!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
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
      // Show loading indicator or placeholder while fetching vendor information
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
                        : Icon(Icons.favorite_outline),
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
                            '\$${widget.vehicle.pricePerDay}/Day',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.red),
                          ),
                          Row(
                            children: [
                              Text(
                                widget.vehicle.rating.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary,
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
                      SizedBox(height: 10),
                      Text(
                        widget.vehicle.brand,
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
                    'Vendor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                buildVendorInfo(), // Display vendor information widget
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
                    onPressed: () {},
                    icon: const Icon(Icons.storefront),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const Text(
                    'Store',
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
                  const Text(
                    'Call',
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
                  const Text(
                    'Chat',
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
                    // Add your booking logic here
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 32),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Book Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
