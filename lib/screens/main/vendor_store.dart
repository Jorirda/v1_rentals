import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/main/car_details.dart';
import 'package:v1_rentals/generated/l10n.dart';

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
        margin: const EdgeInsets.all(16.0),
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
                              const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      )
                    : Text(
                        vendor?.fullname[0].toUpperCase() ?? "",
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
                          vendor!.businessName ??
                              S.of(context).no_business_name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        const Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        const Icon(
                          Icons.star_outline,
                          color: Colors.yellow,
                        ),
                        const Text(
                          '4.0',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(S.of(context).follow),
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
      return const CircularProgressIndicator();
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
                  width: 300,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(vehicle.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  '${vehicle.brand.getTranslation()} ${vehicle.modelYear}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.settings),
                                    const SizedBox(width: 4),
                                    Text(vehicle.getTransmissionTypeString()),
                                  ],
                                ),
                                const VerticalDivider(),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(vehicle.rating.toString()),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Icon(
                                  Icons.monetization_on,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${vehicle.pricePerDay.toString()}/${S.of(context).day}',
                                  style: const TextStyle(
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
            const SizedBox(height: 30),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildFilterRail(BuildContext context) {
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
      CarType.convertible: Icons.directions_car,
    };

    Map<CarType, String> carTypeTranslationKeys = {
      CarType.all: S.of(context).carTypeAll,
      CarType.suv: S.of(context).carTypeSuv,
      CarType.sedan: S.of(context).carTypeSedan,
      CarType.truck: S.of(context).carTypeTruck,
      CarType.van: S.of(context).carTypeVan,
      CarType.hatchback: S.of(context).carTypeHatchback,
      CarType.electric: S.of(context).carTypeElectric,
      CarType.sports: S.of(context).carTypeSports,
      CarType.hybrid: S.of(context).carTypeHybrid,
      CarType.luxury: S.of(context).carTypeLuxury,
      CarType.convertible: S.of(context).carTypeConvertible,
    };

    List<Widget> destinationWidgets = [
      for (var carType in CarType.values)
        GestureDetector(
          onTap: () {
            setState(() {
              selectedCarType = carType;
              _fetchVehicles();
            });
          },
          child: Column(
            children: [
              Icon(
                carTypeIcons[carType],
                size: 24,
                color: selectedCarType == carType
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                carTypeTranslationKeys[carType]!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: selectedCarType == carType
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: destinationWidgets.map((widget) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: widget,
            );
          }).toList(),
        ),
      ),
    );
  }

  String carTypeToString(CarType carType) {
    return carType.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(S.of(context).store),
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
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          Expanded(
            child: Card(
              shadowColor: Colors.black,
              elevation: 50,
              margin: EdgeInsets.zero,
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 90,
                      child: _buildFilterRail(context),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: _vehicleStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                    '${S.of(context).error_loading_vehicles}: ${snapshot.error}'),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
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
