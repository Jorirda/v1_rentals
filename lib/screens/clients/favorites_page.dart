import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/clients/car_details.dart';

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
    return querySnapshot.docs
        .map((doc) => Vehicle.fromMap(doc.data() as DocumentSnapshot<Object?>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
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
              return ListTile(
                title: Text(vehicle.brand),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CarDetailsScreen(vehicle),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}