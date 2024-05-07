import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:v1_rentals/auth/auth_service.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  final Function(Vehicle) onUpdate;

  const EditVehicleScreen(
      {super.key, required this.vehicle, required this.onUpdate});

  @override
  _EditVehicleScreenState createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  late TextEditingController _brandController = TextEditingController();
  late TextEditingController _modelYearController = TextEditingController();
  late TextEditingController _seatsController = TextEditingController();
  late TextEditingController _pricePerDayController = TextEditingController();
  late TextEditingController _colorController = TextEditingController();
  late TextEditingController _overviewController = TextEditingController();

  late CarType _selectedCarType;
  late FuelType _selectedFuelType;
  late TransmissionType _selectedTransmissionType;

  File? _pickedImage;
  bool _updating = false; // Track whether data is being updated
  late Vehicle _vehicle; // Define _vehicle variable to store the vehicle data
  @override
  void initState() {
    super.initState();

    //Initialize text controllers with the vehicle's data
    _brandController.text = widget.vehicle.brand;
    _modelYearController.text = widget.vehicle.modelYear;
    _selectedCarType = widget.vehicle.carType;
    _seatsController.text = widget.vehicle.seats.toString();
    _selectedFuelType = widget.vehicle.fuelType;
    _selectedTransmissionType = widget.vehicle.transmission;
    _pricePerDayController.text = widget.vehicle.pricePerDay.toString();
    _colorController.text = widget.vehicle.color;
    _overviewController.text = widget.vehicle.overview;
    _vehicle = widget.vehicle;

    // Check if the vehicle already has an image URL
    if (widget.vehicle.imageUrl != null) {
      // Load the existing image if it exists
      _loadImageFromUrl(widget.vehicle.imageUrl!);
    }
    print(widget.vehicle.id);
    print(widget.vehicle.imageUrl);
  }

  void _loadImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
      } else {
        // Handle error loading image
        print('Failed to load image from URL: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exception
      print('Error loading image: $e');
    }
  }

  // Function to upload the selected image to Firebase Storage and update the vehicle
  void _submitForm() async {
    setState(() {
      _updating = true;
    });

    try {
      CustomUser? currentUser = await AuthService().getCurrentUser();

      if (currentUser != null) {
        String imageUrl = widget.vehicle.imageUrl ??
            ''; // Use existing image URL if available

        if (_pickedImage != null) {
          // Upload new image to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('vehicle_images')
              .child(currentUser.userId ?? '')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putFile(_pickedImage!);

          // Get the new image URL
          imageUrl = await storageRef.getDownloadURL();
        }

        // Create Vehicle object with updated values
        final updatedVehicle = Vehicle(
          id: widget.vehicle.id,
          brand: _brandController.text,
          modelYear: _modelYearController.text,
          carType: _selectedCarType,
          seats: int.parse(_seatsController.text),
          fuelType: _selectedFuelType,
          transmission: _selectedTransmissionType,
          pricePerDay: int.parse(_pricePerDayController.text),
          rating: 4.8,
          color: _colorController.text,
          overview: _overviewController.text,
          imageUrl: imageUrl,
          available: true,
          vendorId: currentUser.userId ?? '',
        );

        // Update the vehicle document in the centralized collection
        await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.vehicle.id)
            .update(updatedVehicle.toMap());

        // Update the vehicle document in the vendor's fleet subcollection
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.userId)
            .collection('vehicles')
            .doc(widget.vehicle.id)
            .update(updatedVehicle.toMap());

        // Update the vehicle details in the UI
        widget.onUpdate(updatedVehicle);

        //Show a message for successfully updating the data.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated Successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to the previous screen
        Navigator.of(context).pop();
      } else {
        // Show an error message or handle the case where the current user is not authenticated
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User is not authenticated.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      // Handle error uploading image or updating vehicle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteVehicle() async {
    try {
      // Log the document ID before attempting to delete it
      print('Deleting vehicle document with ID: ${widget.vehicle.id}');

      // Delete the vehicle document from the centralized collection
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicle.id)
          .delete();

      // Delete the vehicle document from the vendor's fleet subcollection
      AuthService().getCurrentUser().then((CustomUser? currentUser) async {
        if (currentUser != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.userId)
              .collection('vehicles')
              .doc(widget.vehicle.id)
              .delete();

          // Optionally, you can delete the vehicle image from Firebase Storage if it exists
          // This depends on your requirements
          if (widget.vehicle.imageUrl != null) {
            final storageRef =
                FirebaseStorage.instance.refFromURL(widget.vehicle.imageUrl!);
            await storageRef.delete();
          }

          //Show a message for successfully updating the data.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vehicle Deleted Successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to the fleet screen
          Navigator.of(context).pop();
        } else {
          // Handle the case where the current user is not authenticated
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User is not authenticated.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }).catchError((error) {
        // Handle error retrieving user data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      });
    } catch (error) {
      // Handle error deleting vehicle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting vehicle: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this vehicle?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteVehicle();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('vehicle_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file to Firebase Storage
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      // Get the download URL from the uploaded file
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      // Handle any errors that occur during the upload process
      print('Error uploading image to Firebase Storage: $e');
      return ''; // Return an empty string or null if upload fails
    }
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _brandController.dispose();

    _seatsController.dispose();

    _pricePerDayController.dispose();
    _colorController.dispose();
    _overviewController.dispose();
    super.dispose();
  }

  void _showImagePickerModal() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Vehicle'),
        actions: [
          IconButton(
              onPressed: () {
                _showDeleteConfirmationDialog();
              },
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _showImagePickerModal,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _pickedImage != null
                    ? Image.file(
                        _pickedImage!,
                        fit: BoxFit.contain,
                      )
                    : (widget.vehicle.imageUrl != null
                        ? Image.network(
                            widget.vehicle.imageUrl!,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: Colors.grey,
                          )),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showImagePickerModal,
              child: Text('Edit Photo'),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                  labelText: 'Brand',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  hintStyle: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _modelYearController,
              decoration: InputDecoration(
                  labelText: 'Model Year',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  hintStyle: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DropdownButtonFormField<CarType>(
              decoration: InputDecoration(
                  labelText: 'Car Type',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
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
              decoration: InputDecoration(
                  labelText: 'Seats',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                  hintStyle: TextStyle(fontWeight: FontWeight.bold)),
              keyboardType: TextInputType.number,
            ),
            // Fuel Type Dropdown
            DropdownButtonFormField<FuelType>(
              decoration: InputDecoration(
                  labelText: 'Fuel Type',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
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
                  labelText: 'Transmission Type',
                  labelStyle: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .primary) // Label for the dropdown field
                  ),

              value: _selectedTransmissionType, // The current selected value
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
              decoration: InputDecoration(
                labelText: 'Price Per Day',
                labelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _colorController,
              decoration: InputDecoration(
                labelText: 'Color',
                labelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            TextFormField(
              controller: _overviewController,
              decoration: InputDecoration(
                labelText: 'Overview',
                labelStyle:
                    TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10), // Add some space between the buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cancel'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Changes'),
                                content: Text(
                                    'Are you sure you want to apply new changes to this vehicle?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _submitForm();
                                    },
                                    child: Text('Save'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
