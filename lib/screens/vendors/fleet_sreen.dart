import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart'; // Import your Vehicle model here
import 'package:v1_rentals/screens/vendors/add_vehicle.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/screens/vendors/vendor_vehicle_details.dart';

class FleetScreen extends StatelessWidget {
  const FleetScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Management'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to the AddVehicleForm when the IconButton is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddVehicleForm()),
              );
            },
            icon: const Icon(Icons.add),
            color: Theme.of(context).colorScheme.primary,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<CustomUser?>(
          future: AuthService().getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
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
                    child: Text('No vehicles found.'),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot document =
                        snapshot.data!.docs[index];
                    final vehicle = Vehicle.fromMap(document);
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: Text(
                            'Vehicle ${index + 1}', // You can customize the header text as needed
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Material(
                          elevation: 4,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          clipBehavior: Clip.antiAlias, // Add this line
                          child: InkWell(
                            onTap: () {
                              // Implement onTap to view vehicle details if needed
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
                                        image: NetworkImage(
                                            vehicle.imageUrl ?? ''),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        vehicle.brand,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.car_rental),
                                              SizedBox(width: 4),
                                              Text(vehicle.type),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.energy_savings_leaf),
                                              SizedBox(width: 4),
                                              Text(vehicle.transmission),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.monetization_on),
                                              SizedBox(width: 4),
                                              Text(
                                                  '${vehicle.pricePerDay}/Day'),
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
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
