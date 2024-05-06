import 'package:flutter/material.dart';
import 'package:v1_rentals/models/vehicle_model.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  CarType? _selectedCarType;
  FuelType? _selectedFuelType;
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
              const Text(
                'Price per Day Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                    Navigator.pop(context, {
                      'carType': _selectedCarType,
                      'fuelType': _selectedFuelType,
                      'minPrice': _priceRange.start,
                      'maxPrice': _priceRange.end,
                    });
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
