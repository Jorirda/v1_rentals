import 'package:flutter/material.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/vendors/edit_vehicle.dart';
import 'package:v1_rentals/generated/l10n.dart';

class VehicleDetailsPage extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailsPage({super.key, required this.vehicle});

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
        title: Text(S.of(context).vehicle_details),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
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
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Divider(),
            ListTile(
              title: Text(S.of(context).overview,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.overview),
            ),
            const Divider(),
            ListTile(
              title: Text(
                S.of(context).brand,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              subtitle: Text(
                _vehicle.brand.getTranslation(),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(
                S.of(context).model,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              subtitle: Text(
                _vehicle.model,
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(
                S.of(context).model_year,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              subtitle: Text(
                _vehicle.modelYear,
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(S.of(context).type,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.carType.toString().split('.').last),
            ),
            const Divider(),
            ListTile(
              title: Text(S.of(context).seats,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.seats.toString()),
            ),
            const Divider(),
            ListTile(
              title: Text(S.of(context).color,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.color),
            ),
            const Divider(),
            ListTile(
              title: Text(S.of(context).fuel,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.fuelType.toString().split('.').last),
            ),
            const Divider(),
            ListTile(
              title: Text(S.of(context).transmission,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text(_vehicle.transmission.toString().split('.').last),
            ),
            const Divider(),
            ListTile(
              title: Text(S.of(context).price_per_day,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              subtitle: Text('\$${_vehicle.pricePerDay.toString()}'),
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
