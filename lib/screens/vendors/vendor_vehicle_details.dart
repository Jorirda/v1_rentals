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
        padding: const EdgeInsets.all(.0),
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
            SizedBox(
              height: 20,
            ),
            Divider(),
            ListTile(
              title: Text('Overview',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.overview),
            ),
            Divider(),
            ListTile(
              title: Text(
                'Brand',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              subtitle: Text(
                _vehicle.brand,
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Type',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.type),
            ),
            Divider(),
            ListTile(
              title: Text('Seats',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.seats.toString()),
            ),
            Divider(),
            ListTile(
              title: Text('Color',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.color),
            ),
            Divider(),
            ListTile(
              title: Text('Fuel Type',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.fuelType),
            ),
            Divider(),
            ListTile(
              title: Text('Transmission',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.transmission),
            ),
            Divider(),
            ListTile(
              title: Text('Price Per Day',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.pricePerDay.toString()),
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
