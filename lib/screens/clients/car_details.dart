import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';

class CarDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const CarDetailsScreen(this.vehicle, {super.key});

  @override
  _CarDetailsScreenState createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  String _vendorFullName = '';
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Details'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  isFavorite = !isFavorite;
                });
              },
              icon: isFavorite
                  ? Icon(Icons.favorite_outline)
                  : Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display vehicle details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.vehicle.brand,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      widget.vehicle.rating.toString(),
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
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
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                    image: NetworkImage(widget.vehicle.imageUrl ?? ''),
                    fit: BoxFit.cover),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Overview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.vehicle.overview,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Features',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Grey background color
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.directions_car),
                      ),
                      const SizedBox(height: 4),
                      Text(widget.vehicle.getCarTypeString()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Grey background color
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.event_seat),
                      ),
                      const SizedBox(height: 4),
                      Text('${widget.vehicle.seats} seats'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Grey background color
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.local_gas_station),
                      ),
                      const SizedBox(height: 4),
                      Text(widget.vehicle.getFuelTypeString()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Grey background color
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Icon(Icons.settings),
                      ),
                      const SizedBox(height: 4),
                      Text(widget.vehicle.getTransmissionTypeString()),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            // Use FutureBuilder to fetch vendor's full name asynchronously

            const Text(
              'Vendor',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            FutureBuilder(
              future: AuthService().getUserData(widget.vehicle.vendorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  CustomUser vendor = snapshot.data as CustomUser;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.grey,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        vendor.fullname,
                        style: const TextStyle(fontSize: 15),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .grey[200], // Grey background color
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: const Icon(Icons.chat),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .grey[200], // Grey background color
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: const Icon(Icons.phone),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Price', // Label text
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                        Icons.attach_money), // Icon to the left of the price
                    const SizedBox(width: 8),
                    Text(
                      '${widget.vehicle.pricePerDay}/Day', // Replace with actual price value
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                // Add your booking logic here
              },
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white),
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
