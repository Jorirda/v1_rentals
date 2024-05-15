import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/main/car_details.dart';

class VendorStorePage extends StatefulWidget {
  final String vendorId;

  const VendorStorePage({super.key, required this.vendorId});

  @override
  _VendorStorePageState createState() => _VendorStorePageState();
}

class _VendorStorePageState extends State<VendorStorePage> {
  late Stream<QuerySnapshot> _vehicleStream;
  CarType selectedCarType = CarType.all; // Default selected car type
  CustomUser? vendor;

  @override
  void initState() {
    super.initState();
    _fetchVendorInfo();
    _fetchVehicles();
  }

  void _fetchVehicles() {
    if (selectedCarType == CarType.all) {
      _vehicleStream = FirebaseFirestore.instance
          .collection('vehicles')
          .where('vendorId', isEqualTo: widget.vendorId)
          .snapshots();
    } else {
      _vehicleStream = FirebaseFirestore.instance
          .collection('vehicles')
          .where('vendorId', isEqualTo: widget.vendorId)
          .where('carType', isEqualTo: carTypeToString(selectedCarType))
          .snapshots();
    }
  }

  Future<void> _fetchVendorInfo() async {
    try {
      CustomUser? vendorData = await AuthService().getUserData(widget.vendorId);
      setState(() {
        vendor = vendorData;
      });
    } catch (e) {
      print('Error fetching vendor information: $e');
    }
  }

  Widget _buildVendorInfo() {
    if (vendor != null) {
      return Card(
        color: Theme.of(context).colorScheme.primary,
        // margin: EdgeInsets.zero,
        margin: EdgeInsets.all(16.0),
        elevation: 3,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vendor!.businessName ?? 'No Business Name',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () {}, child: Text('Follow +')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        Icon(
                          Icons.star_outline,
                          color: Colors.yellow,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '4.0',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
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

  Widget _buildVehicleList(BuildContext context, QuerySnapshot snapshot) {
    return Column(
      children: snapshot.docs.map((document) {
        final vehicle = Vehicle.fromMap(document);
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
                  width: 300, // Adjusted size to fit the screen width
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120, // Set height of the image container
                        width: 120, // Set width of the image container
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(vehicle.imageUrl ?? ''),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 12), // Add spacing
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text(
                              vehicle.brand,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Divider(),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.settings),
                                    SizedBox(width: 4),
                                    Text(vehicle.getTransmissionTypeString()),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.monetization_on,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${vehicle.pricePerDay.toString()}/Day',
                                  style: TextStyle(
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
            SizedBox(height: 30),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFilterRail(BuildContext context) {
    // Define a map for custom icons for each car type
    Map<CarType, IconData> carTypeIcons = {
      CarType.all: Icons.apps,
      CarType.suv: Icons.directions_car,
      CarType.sedan: Icons.directions_car,
      CarType.truck: Icons.directions_car,
      CarType.van: Icons.directions_car,
      CarType.hatchback: Icons.directions_car,
      CarType.electric: Icons.electric_car,
      CarType.sports: Icons.sports_score,
      CarType.hybrid: Icons.eco,
      CarType.luxury: Icons.diamond_outlined,
      CarType.convertible: Icons.directions_car
    };

    List<Widget> destinationWidgets = [
      for (var carType in CarType.values)
        GestureDetector(
          onTap: () {
            setState(() {
              selectedCarType = carType;
              _fetchVehicles(); // Update vehicle stream based on selected car type
            });
          },
          child: Column(
            children: [
              Icon(
                carTypeIcons[carType],
                size: 24, // Icon size
                color: selectedCarType == carType
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey, // Icon color
              ),
              SizedBox(height: 4),
              Text(
                carTypeToString(carType),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, // Text size
                    color: selectedCarType == carType
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    fontWeight: FontWeight.bold // Text color
                    ),
              ),
            ],
          ),
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), // Make the container rounded
        color: Colors.grey[200],
      ),
      padding:
          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Add padding
      child: SingleChildScrollView(
        // Wrap in SingleChildScrollView to make content scrollable
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Spread out the widgets
          children: destinationWidgets.map((widget) {
            return Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 10.0), // Add vertical spacing
              child: widget,
            );
          }).toList(),
        ),
      ),
    );
  }

  int carTypeIndex(CarType carType) {
    return CarType.values.indexOf(carType);
  }

  CarType carTypeFromIndex(int index) {
    return CarType.values[index];
  }

  String carTypeToString(CarType carType) {
    return carType.toString().split('.').last;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Vendor Store'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.chat_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.star_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVendorInfo(),
          SizedBox(
            height: 10,
          ),
          Divider(),
          // Display vendor info widget
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Card(
              shadowColor: Colors.black,
              elevation: 50,
              margin: EdgeInsets.zero,
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90, // Adjust the width according to your needs
                      child: _buildFilterRail(context),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _vehicleStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return _buildVehicleList(context, snapshot.data!);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
