import 'package:cloud_firestore/cloud_firestore.dart';
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

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  String _vendorFullName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Details'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.favorite_outline))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display vehicle details
            Text(
              widget.vehicle.brand,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
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
            SizedBox(
              height: 20,
            ),
            const Text(
              'Overview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              widget.vehicle.overview,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(
              height: 20,
            ),
            const Text(
              'Features',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Grey background color
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(Icons.directions_car),
                      ),
                      SizedBox(height: 4),
                      Text(widget.vehicle.type),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Grey background color
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(Icons.event_seat),
                      ),
                      SizedBox(height: 4),
                      Text('${widget.vehicle.seats} seats'),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Grey background color
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(Icons.local_gas_station),
                      ),
                      SizedBox(height: 4),
                      Text(widget.vehicle.fuelType),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // Grey background color
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Icon(Icons.settings),
                      ),
                      SizedBox(height: 4),
                      Text(widget.vehicle.transmission),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            // Use FutureBuilder to fetch vendor's full name asynchronously

            Text(
              'Vendor',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder(
              future: AuthService().getUserData(widget.vehicle.vendorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
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
                        style: TextStyle(fontSize: 15),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .grey[200], // Grey background color
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Icon(Icons.chat),
                                  ),
                                  SizedBox(height: 4),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .grey[200], // Grey background color
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: Icon(Icons.phone),
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
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
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
                Text(
                  'Price', // Label text
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.attach_money), // Icon to the left of the price
                    SizedBox(width: 8),
                    Text(
                      '${widget.vehicle.pricePerDay}/Day', // Replace with actual price value
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                // Add your booking logic here
              },
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white),
              child: Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
