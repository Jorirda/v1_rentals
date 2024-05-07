import 'package:flutter/material.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/screens/main/search_page.dart';

class FilterPage extends StatefulWidget {
  const FilterPage(
    this.vehicles, {
    super.key,
  });
  final List<Vehicle> vehicles;
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  CarType? _selectedCarType;

  FuelType? _selectedFuelType;
  TransmissionType? _selectedTransmissionType;
  RangeValues _priceRange = const RangeValues(0, 1000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Car Brand',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a brand';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Model Year',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a brand';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Car Type',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              DropdownButtonFormField<CarType>(
                value: _selectedCarType,
                onChanged: (CarType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCarType = newValue;
                    });
                  }
                },
                items: CarType.values.map((CarType value) {
                  return DropdownMenuItem<CarType>(
                    value: value,
                    child: Text(value.toString().split('.').last),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Fuel Type',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              DropdownButtonFormField<FuelType>(
                value: _selectedFuelType,
                onChanged: (FuelType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedFuelType = newValue;
                    });
                  }
                },
                items: FuelType.values.map((FuelType value) {
                  return DropdownMenuItem<FuelType>(
                    value: value,
                    child: Text(value.toString().split('.').last),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Transmission Type',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              DropdownButtonFormField<TransmissionType>(
                value: _selectedTransmissionType,
                onChanged: (TransmissionType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedTransmissionType = newValue;
                    });
                  }
                },
                items: TransmissionType.values.map((TransmissionType value) {
                  return DropdownMenuItem<TransmissionType>(
                    value: value,
                    child: Text(value.toString().split('.').last),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Price per Day Range',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('\$${_priceRange.start.toStringAsFixed(2)}'),
                  Text('\$${_priceRange.end.toStringAsFixed(2)}'),
                ],
              ),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000,
                onChanged: (RangeValues values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
                divisions: 100,
                labels: RangeLabels(
                  _priceRange.start.toStringAsFixed(2),
                  _priceRange.end.toStringAsFixed(2),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        height: 100,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Reset button functionality
                  },
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Apply button functionality
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(
                          widget.vehicles.where((vehicle) {
                            // Apply filtering logic here based on selected filters

                            return vehicle.carType == _selectedCarType &&
                                vehicle.pricePerDay >= _priceRange.start &&
                                vehicle.pricePerDay <= _priceRange.end;
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
