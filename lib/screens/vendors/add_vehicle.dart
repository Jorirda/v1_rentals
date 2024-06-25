import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:v1_rentals/generated/l10n.dart';

class AddVehicleForm extends StatefulWidget {
  const AddVehicleForm({super.key});

  @override
  _AddVehicleFormState createState() => _AddVehicleFormState();
}

class _AddVehicleFormState extends State<AddVehicleForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _modelYearController;
  late TextEditingController _seatsController;
  late TextEditingController _pricePerDayController;
  late TextEditingController _colorController;
  late TextEditingController _overviewController;
  late TextEditingController _imageUrlController;

  late CarType _selectedCarType;
  late FuelType _selectedFuelType;
  late TransmissionType _selectedTransmissionType;
  Brand? _selectedBrand;
  final String _defaultImagePath = 'assets/images/car_model_default.png';

  File? _pickedImage;
  late List<int> _yearsList;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _yearsList = _generateYearsList(1980); // Example: Start from 1980
    _brandController = TextEditingController();
    _modelController = TextEditingController();
    _modelYearController = TextEditingController();
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
    _modelController.dispose();
    _modelYearController.dispose();
    _seatsController.dispose();
    _pricePerDayController.dispose();
    _colorController.dispose();
    _overviewController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  List<int> _generateYearsList(int startYear) {
    int currentYear = DateTime.now().year;
    return List<int>.generate(
            currentYear - startYear + 1, (index) => startYear + index)
        .reversed
        .toList();
  }

  Future<File> _compressImage(File imageFile) async {
    final img.Image originalImage =
        img.decodeImage(imageFile.readAsBytesSync())!;
    final img.Image compressedImage =
        img.copyResize(originalImage, width: 800); // Adjust the width as needed
    final Directory tempDir = await getTemporaryDirectory();
    final String tempPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File compressedFile = File(tempPath)
      ..writeAsBytesSync(img.encodeJpg(compressedImage,
          quality: 50)); // Adjust the quality as needed
    return compressedFile;
  }

  // Function to upload image to Firebase Storage
  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      // Compress the image
      File compressedFile = await _compressImage(imageFile);

      // Cache the image
      await DefaultCacheManager().putFile(
        compressedFile.path,
        compressedFile.readAsBytesSync(),
        fileExtension: 'jpg',
      );

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('vehicle_images')
          .child(DateTime.now().millisecondsSinceEpoch.toString() + '.jpg');
      final uploadTask = storageRef.putFile(compressedFile);
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
      setState(() {
        _isSubmitting = true;
      });

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

          // Check if an image is selected, if not use the default image
          if (_pickedImage == null) {
            // Load the default image from assets
            final ByteData bytes = await rootBundle.load(_defaultImagePath);
            final Uint8List list = bytes.buffer.asUint8List();
            final tempDir = await getTemporaryDirectory();
            final tempFile = File('${tempDir.path}/default_vehicle.jpg');
            await tempFile.writeAsBytes(list, flush: true);
            _pickedImage = tempFile;
          }

          // Upload image to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('vehicle_images')
              .child(currentUser.userId!)
              .child('$vehicleId.jpg');
          await storageRef.putFile(_pickedImage!);

          // Get the image URL
          final imageUrl = await storageRef.getDownloadURL();

          // Determine the brand
          String brand = _selectedBrand != null
              ? _selectedBrand.toString().split('.').last
              : _brandController.text;

          // Create Vehicle object with image URL and assigned document ID
          final newVehicle = Vehicle(
            id: vehicleId, // Assign the same document ID
            brand: _selectedBrand!,
            model: _modelController.text,
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
            isFavorite: false, // Assuming the new vehicle is available
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
      } finally {
        setState(() {
          _isSubmitting = false;
        });
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
        title: Text(S.of(context).add_vehicle),
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
                              title: Text(S.of(context).take_photo),
                              onTap: () {
                                Navigator.pop(context);
                                _getImageFromCamera();
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo),
                              title: Text(S.of(context).choose_from_gallery),
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
                  child: Text(S.of(context).add_image),
                ),
                DropdownButtonFormField<Brand>(
                  decoration: InputDecoration(labelText: S.of(context).brand),
                  value: _selectedBrand,
                  onChanged: (Brand? newValue) {
                    setState(() {
                      _selectedBrand = newValue;
                      if (newValue != null) {
                        _brandController.text = ''; // Clear the text field
                      }
                    });
                  },
                  items: Brand.values.map((Brand brand) {
                    return DropdownMenuItem<Brand>(
                      value: brand,
                      child: Text(brand.toString().split('.').last),
                    );
                  }).toList(),
                  validator: (value) {
                    if (_selectedBrand == null) {
                      return S.of(context).please_select_brand;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(
                    labelText: S.of(context).brand_alt,
                  ),
                ),
                TextFormField(
                  controller: _modelController,
                  decoration: InputDecoration(labelText: S.of(context).model),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).enter_model;
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<int>(
                  decoration:
                      InputDecoration(labelText: S.of(context).model_year),
                  value: int.tryParse(_modelYearController.text),
                  onChanged: (int? newValue) {
                    setState(() {
                      _modelYearController.text = newValue.toString();
                    });
                  },
                  items: _yearsList.map((int year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return S.of(context).enter_model_year;
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<CarType>(
                  decoration:
                      InputDecoration(labelText: S.of(context).car_type),
                  value: _selectedCarType,
                  onChanged: (CarType? newValue) {
                    setState(() {
                      _selectedCarType = newValue!;
                    });
                  },
                  items: CarType.values.map((CarType type) {
                    return DropdownMenuItem<CarType>(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                ),
                TextFormField(
                  controller: _seatsController,
                  decoration: InputDecoration(labelText: S.of(context).seats),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).enter_num_seats;
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<FuelType>(
                  decoration: InputDecoration(labelText: S.of(context).fuel),
                  value: _selectedFuelType,
                  onChanged: (FuelType? newValue) {
                    setState(() {
                      _selectedFuelType = newValue!;
                    });
                  },
                  items: FuelType.values.map((FuelType type) {
                    return DropdownMenuItem<FuelType>(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                ),
                DropdownButtonFormField<TransmissionType>(
                  decoration:
                      InputDecoration(labelText: S.of(context).transmission),
                  value: _selectedTransmissionType,
                  onChanged: (TransmissionType? newValue) {
                    setState(() {
                      _selectedTransmissionType = newValue!;
                    });
                  },
                  items: TransmissionType.values.map((TransmissionType type) {
                    return DropdownMenuItem<TransmissionType>(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                ),
                TextFormField(
                  controller: _pricePerDayController,
                  decoration:
                      InputDecoration(labelText: S.of(context).price_per_day),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return S.of(context).enter_price_per_day;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(labelText: S.of(context).color),
                ),
                TextFormField(
                  controller: _overviewController,
                  decoration:
                      InputDecoration(labelText: S.of(context).overview),
                ),
                SizedBox(height: 20),
                _isSubmitting
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(S.of(context).submit),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
