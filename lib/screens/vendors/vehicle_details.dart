import 'package:flutter/material.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/vendors/edit_vehicle.dart';

class VehicleDetailsPage extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailsPage({Key? key, required this.vehicle}) : super(key: key);

  @override
  _VehicleDetailsPageState createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  late Vehicle _vehicle; // Define _vehicle variable to store the vehicle data

  @override
  void initState() {
    super.initState();
    _vehicle =
        widget.vehicle; // Initialize _vehicle with the provided vehicle data
  }

  void _updateVehicle(Vehicle updatedVehicle) {
    setState(() {
      _vehicle = updatedVehicle; // Update _vehicle with the edited values
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: _vehicle.imageUrl != null
                  ? Image.network(
                      _vehicle.imageUrl,
                      fit: BoxFit.contain,
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
            ),
            ListTile(
              title: Text('Brand'),
              subtitle: Text(_vehicle.brand),
            ),
            ListTile(
              title: Text('Type'),
              subtitle: Text(_vehicle.type),
            ),
            ListTile(
              title: Text('Seats'),
              subtitle: Text(_vehicle.seats.toString()),
            ),
            ListTile(
              title: Text('Fuel Type'),
              subtitle: Text(_vehicle.fuelType),
            ),
            ListTile(
              title: Text('Transmission'),
              subtitle: Text(_vehicle.transmission),
            ),
            ListTile(
              title: Text('Price Per Day'),
              subtitle: Text(_vehicle.pricePerDay),
            ),
            ListTile(
              title: Text('Color'),
              subtitle: Text(_vehicle.color),
            ),
            ListTile(
              title: Text('Overview'),
              subtitle: Text(_vehicle.overview),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Navigate to the edit vehicle page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditVehicleScreen(
                vehicle: _vehicle, // Pass _vehicle to the EditVehicleScreen
                onUpdate: _updateVehicle,
              ),
            ),
          );
        },
        child: Icon(
          Icons.edit,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
