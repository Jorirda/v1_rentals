import 'package:flutter/material.dart';
import 'package:v1_rentals/models/vehicle_model.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({
    Key? key,
    required this.initialFuelType,
    required this.initialTransmissionType,
    required this.initialPriceRange,
  }) : super(key: key);

  final FuelType? initialFuelType;
  final TransmissionType? initialTransmissionType;
  final RangeValues initialPriceRange;

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late FuelType? _selectedFuelType;
  late TransmissionType? _selectedTransmissionType;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();

    _selectedFuelType = widget.initialFuelType;
    _selectedTransmissionType = widget.initialTransmissionType;
    _priceRange = widget.initialPriceRange;
  }

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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fuel Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              DropdownButtonFormField<FuelType>(
                value: _selectedFuelType,
                onChanged: (FuelType? newValue) {
                  setState(() {
                    _selectedFuelType = newValue;
                  });
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
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              DropdownButtonFormField<TransmissionType>(
                value: _selectedTransmissionType,
                onChanged: (TransmissionType? newValue) {
                  setState(() {
                    _selectedTransmissionType = newValue;
                  });
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
                  color: Theme.of(context).colorScheme.primary,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Reset button functionality
                    Navigator.pop(
                        context); // Pop the FilterPage to reset filters
                  },
                  child: Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
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
                      'fuelType': _selectedFuelType,
                      'transmissionType': _selectedTransmissionType,
                      'priceRange': _priceRange,
                    }); // Pass updated filter settings back to SearchScreen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
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
