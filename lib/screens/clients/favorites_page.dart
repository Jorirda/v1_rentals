import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/main/car_details.dart';

import 'package:v1_rentals/generated/l10n.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<Vehicle>> favoritesFuture;

  @override
  void initState() {
    super.initState();
    favoritesFuture = fetchFavorites();
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
      // Assume Vehicle.fromMap is actually expecting a DocumentSnapshot
      Vehicle vehicle = Vehicle.fromMap(doc);
      vehicles.add(vehicle);
    }
    return vehicles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).favorites),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Vehicle>? favoriteVehicles = snapshot.data;
          if (favoriteVehicles == null || favoriteVehicles.isEmpty) {
            return Center(child: Text('No favorites found'));
          }

          return ListView.builder(
            itemCount: favoriteVehicles.length,
            itemBuilder: (context, index) {
              final vehicle = favoriteVehicles[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: Image.network(
                    vehicle.imageUrl ?? 'https://via.placeholder.com/150',
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.error),
                  ),
                  title: Text(vehicle.brand),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle.modelYear),
                      Text('\$${vehicle.pricePerDay}/Day')
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CarDetailsScreen(vehicle),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
