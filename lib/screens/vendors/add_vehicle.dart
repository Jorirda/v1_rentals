import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';

class AddVehicleForm extends StatefulWidget {
  const AddVehicleForm({super.key});

  @override
  _AddVehicleFormState createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<AddVehicleForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _brandController;

  late TextEditingController _seatsController;

  late TextEditingController _pricePerDayController;
  late TextEditingController _colorController;
  late TextEditingController _overviewController;
  late TextEditingController _imageUrlController;

  late CarType _selectedCarType;
  late FuelType _selectedFuelType;
  late TransmissionType _selectedTransmissionType;

  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _brandController = TextEditingController();
    _selectedCarType = CarType.sedan;
    _seatsController = TextEditingController();
    _selectedFuelType = FuelType.gasoline;
    _selectedTransmissionType = TransmissionType.automatic;
    _pricePerDayController = TextEditingController();
    _colorController = TextEditingController();
    _overviewController = TextEditingController();
    _imageUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _brandController.dispose();

    _seatsController.dispose();

    _pricePerDayController.dispose();
    _colorController.dispose();
    _overviewController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Function to upload image to Firebase Storage
  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('vehicle_images')
          .child(DateTime.now().millisecondsSinceEpoch.toString() + '.jpg');
      final uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        CustomUser? currentUser = await AuthService()
            .getCurrentUser(); // Await the Future to get the actual CustomUser object

        if (currentUser != null &&
            currentUser.userType == UserType.vendor &&
            currentUser.userId != null) {
          // Generate a unique document ID
          String vehicleId =
              FirebaseFirestore.instance.collection('vehicles').doc().id;

          print('Vehicle Document ID:  $vehicleId');
          // Upload image to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('vehicle_images')
              .child(currentUser.userId!)
              .child('$vehicleId.jpg');
          await storageRef.putFile(_pickedImage!);

          // Get the image URL
          final imageUrl = await storageRef.getDownloadURL();

          // Create Vehicle object with image URL and assigned document ID
          final newVehicle = Vehicle(
            id: vehicleId, // Assign the same document ID
            brand: _brandController.text,
            carType: CarType.suv,
            seats: int.parse(_seatsController.text),
            fuelType: FuelType.gasoline,
            transmission: TransmissionType.automatic,
            pricePerDay: double.parse(_pricePerDayController.text),
            rating: 4.8,
            color: _colorController.text,
            overview: _overviewController.text,
            imageUrl: imageUrl,
            available: true, // Assuming the new vehicle is available
            vendorId: currentUser
                .userId!, // Set the current user's ID as the vendor ID
          );

          // Add the new vehicle document to the centralized collection
          await FirebaseFirestore.instance
              .collection('vehicles')
              .doc(vehicleId) // Use the same document ID
              .set(newVehicle.toMap());

          // Add the new vehicle document to the vendor's fleet subcollection
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.userId)
              .collection('vehicles')
              .doc(vehicleId) // Use the same document ID
              .set(newVehicle.toMap());

          // Navigate back to the previous screen
          Navigator.of(context).pop();
        } else {
          // Show an error message or handle the case where the current user is not a vendor
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Only vendors can add vehicles.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        // Handle error uploading image or adding vehicle
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        _imageUrlController.text = pickedFile.path;
      });
    }
  }

  Future<void> _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
        _imageUrlController.text = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vehicle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _getImageFromGallery,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _pickedImage == null
                        ? Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.grey,
                          )
                        : Image.file(
                            _pickedImage!,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.camera),
                              title: Text('Take Photo'),
                              onTap: () {
                                Navigator.pop(context);
                                _getImageFromCamera();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo),
                              title: Text('Choose from Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _getImageFromGallery();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Add Image'),
                ),
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(labelText: 'Brand'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a brand';
                    }
                    return null;
                  },
                ),
                // Car Type Dropdown

                DropdownButtonFormField<CarType>(
                  decoration: InputDecoration(
                    labelText: 'Car Type', // Label for the dropdown field
                  ),
                  value: _selectedCarType, // The current selected value
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
                      child: Text(value
                          .toString()
                          .split('.')
                          .last), // Display the enum value
                    );
                  }).toList(),
                ),
                TextFormField(
                  controller: _seatsController,
                  decoration: InputDecoration(labelText: 'Seats'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of seats';
                    }
                    return null;
                  },
                ),

                // Fuel Type Dropdown
                DropdownButtonFormField<FuelType>(
                  decoration: InputDecoration(
                    labelText: 'Fuel Type', // Label for the dropdown field
                  ),
                  value: _selectedFuelType, // The current selected value
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
                      child: Text(value
                          .toString()
                          .split('.')
                          .last), // Display the enum value
                    );
                  }).toList(),
                ),

                // Transmission Type Dropdown
                DropdownButtonFormField<TransmissionType>(
                  decoration: InputDecoration(
                    labelText:
                        'Transmission Type', // Label for the dropdown field
                  ),
                  value:
                      _selectedTransmissionType, // The current selected value
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
                      child: Text(value
                          .toString()
                          .split('.')
                          .last), // Display the enum value
                    );
                  }).toList(),
                ),
                TextFormField(
                  controller: _pricePerDayController,
                  decoration: InputDecoration(labelText: 'Price Per Day'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the price per day';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(labelText: 'Color'),
                ),
                TextFormField(
                  controller: _overviewController,
                  decoration: InputDecoration(labelText: 'Overview'),
                  maxLines: null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
