import 'dart:io';
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
  late TextEditingController _typeController = TextEditingController();
  late TextEditingController _seatsController = TextEditingController();
  late TextEditingController _fuelTypeController = TextEditingController();
  late TextEditingController _transmissionController = TextEditingController();
  late TextEditingController _pricePerDayController = TextEditingController();
  late TextEditingController _colorController = TextEditingController();
  late TextEditingController _overviewController = TextEditingController();

  File? _pickedImage;
  bool _updating = false; // Track whether data is being updated
  late Vehicle _vehicle; // Define _vehicle variable to store the vehicle data
  @override
  void initState() {
    super.initState();

    //Initialize text controllers with the vehicle's data
    _brandController.text = widget.vehicle.brand;
    _typeController.text = widget.vehicle.type;
    _seatsController.text = widget.vehicle.seats.toString();
    _fuelTypeController.text = widget.vehicle.fuelType;
    _transmissionController.text = widget.vehicle.transmission;
    _pricePerDayController.text = widget.vehicle.pricePerDay;
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
          type: _typeController.text,
          seats: int.parse(_seatsController.text),
          fuelType: _fuelTypeController.text,
          transmission: _transmissionController.text,
          pricePerDay: _pricePerDayController.text,
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
    _typeController.dispose();
    _seatsController.dispose();
    _fuelTypeController.dispose();
    _transmissionController.dispose();
    _pricePerDayController.dispose();
    _colorController.dispose();
    _overviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Vehicle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
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
            SizedBox(height: 20),
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(labelText: 'Brand'),
            ),
            TextFormField(
              controller: _typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextFormField(
              controller: _seatsController,
              decoration: InputDecoration(labelText: 'Seats'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _fuelTypeController,
              decoration: InputDecoration(labelText: 'Fuel Type'),
            ),
            TextFormField(
              controller: _transmissionController,
              decoration: InputDecoration(labelText: 'Transmission'),
            ),
            TextFormField(
              controller: _pricePerDayController,
              decoration: InputDecoration(labelText: 'Price Per Day'),
              keyboardType: TextInputType.number,
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
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
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
                    SizedBox(width: 10), // Add space between buttons
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Deletion'),
                                content: Text(
                                    'Are you sure you want to delete this vehicle?'),
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
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white),
                        child: Text('Delete Vehicle'),
                      ),
                    )
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
