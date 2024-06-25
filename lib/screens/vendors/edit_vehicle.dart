import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image/image.dart' as img;
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/models/enum_extensions.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/models/vehicle_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:v1_rentals/generated/l10n.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  final Function(Vehicle) onUpdate;

  const EditVehicleScreen(
      {super.key, required this.vehicle, required this.onUpdate});

  @override
  _EditVehicleScreenState createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  late TextEditingController _modelController;
  late TextEditingController _modelYearController;
  late TextEditingController _seatsController;
  late TextEditingController _pricePerDayController;
  late TextEditingController _colorController;
  late TextEditingController _overviewController;

  late CarType _selectedCarType;
  late FuelType _selectedFuelType;
  late TransmissionType _selectedTransmissionType;

  File? _pickedImage;
  bool _updating = false;
  late Vehicle _vehicle;

  late Brand _selectedBrand;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController(text: widget.vehicle.model);
    _modelYearController =
        TextEditingController(text: widget.vehicle.modelYear);
    _seatsController =
        TextEditingController(text: widget.vehicle.seats.toString());
    _pricePerDayController =
        TextEditingController(text: widget.vehicle.pricePerDay.toString());
    _colorController = TextEditingController(text: widget.vehicle.color);
    _overviewController = TextEditingController(text: widget.vehicle.overview);

    _selectedCarType = widget.vehicle.carType;
    _selectedFuelType = widget.vehicle.fuelType;
    _selectedTransmissionType = widget.vehicle.transmission;
    _vehicle = widget.vehicle;
    _selectedBrand = widget.vehicle.brand;
    if (widget.vehicle.imageUrl != null) {
      _loadImageFromUrl(widget.vehicle.imageUrl!);
    }
  }

  Future<void> _loadImageFromUrl(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_image.jpg');
        await tempFile.writeAsBytes(bytes);
        setState(() {
          _pickedImage = tempFile;
        });
      } else {
        print('Failed to load image from URL: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  Future<File> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final img.Image? image = img.decodeImage(bytes);
    if (image != null) {
      final compressed = img.encodeJpg(image, quality: 50);
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image_compressed.jpg');
      return await tempFile.writeAsBytes(compressed);
    } else {
      return imageFile;
    }
  }

  Future<void> _cacheImage(File imageFile) async {
    await DefaultCacheManager()
        .putFile(imageFile.path, await imageFile.readAsBytes());
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    final CustomUser? currentUser = await AuthService().getCurrentUser();
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('vehicle_images')
        .child('${currentUser?.userId}')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

    final UploadTask uploadTask = storageRef.putFile(imageFile);
    final TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final compressedImage = await _compressImage(File(pickedFile.path));
      setState(() {
        _pickedImage = compressedImage;
      });
      await _cacheImage(compressedImage);
    }
  }

  Future<void> _getImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final compressedImage = await _compressImage(File(pickedFile.path));
      setState(() {
        _pickedImage = compressedImage;
      });
      await _cacheImage(compressedImage);
    }
  }

  void _submitForm() async {
    setState(() {
      _updating = true;
    });

    try {
      final CustomUser? currentUser = await AuthService().getCurrentUser();

      if (currentUser != null) {
        String imageUrl = widget.vehicle.imageUrl ?? '';

        if (_pickedImage != null) {
          imageUrl = await _uploadImageToStorage(_pickedImage!);
        }

        final updatedVehicle = Vehicle(
          id: widget.vehicle.id,
          brand: Vehicle.getBrandFromString(_selectedBrand.getTranslation()),
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
          isFavorite: false,
          vendorId: currentUser.userId ?? '',
        );

        await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.vehicle.id)
            .update(updatedVehicle.toMap());

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.userId)
            .collection('vehicles')
            .doc(widget.vehicle.id)
            .update(updatedVehicle.toMap());

        widget.onUpdate(updatedVehicle);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated Successfully.'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User is not authenticated.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _updating = false;
      });
    }
  }

  void _deleteVehicle() async {
    try {
      final CustomUser? currentUser = await AuthService().getCurrentUser();
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.vehicle.id)
            .delete();

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.userId)
            .collection('vehicles')
            .doc(widget.vehicle.id)
            .delete();

        if (widget.vehicle.imageUrl != null) {
          final storageRef =
              FirebaseStorage.instance.refFromURL(widget.vehicle.imageUrl!);
          await storageRef.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vehicle Deleted Successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User is not authenticated.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
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
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteVehicle();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).delete),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _modelYearController.dispose();
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
              title: Text(S.of(context).take_photo),
              onTap: () {
                Navigator.of(context).pop();
                _getImageFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_album),
              title: Text(S.of(context).choose_from_gallery),
              onTap: () {
                Navigator.of(context).pop();
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
        title: Text(S.of(context).edit_vehicle),
        actions: [
          IconButton(
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: _showDeleteConfirmationDialog,
          ),
        ],
      ),
      body: _updating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Brand>(
                      value: _selectedBrand,
                      decoration:
                          InputDecoration(labelText: S.of(context).brand),
                      onChanged: (Brand? newValue) {
                        setState(() {
                          _selectedBrand = newValue!;
                        });
                      },
                      items: Brand.values.map((Brand type) {
                        return DropdownMenuItem<Brand>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    TextFormField(
                      controller: _modelController,
                      decoration:
                          InputDecoration(labelText: S.of(context).model),
                    ),
                    TextFormField(
                      controller: _modelYearController,
                      decoration:
                          InputDecoration(labelText: S.of(context).model_year),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _seatsController,
                      decoration:
                          InputDecoration(labelText: S.of(context).seats),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _pricePerDayController,
                      decoration: InputDecoration(
                          labelText: S.of(context).price_per_day),
                      keyboardType: TextInputType.number,
                    ),
                    TextFormField(
                      controller: _colorController,
                      decoration:
                          InputDecoration(labelText: S.of(context).color),
                    ),
                    TextFormField(
                      controller: _overviewController,
                      decoration:
                          InputDecoration(labelText: S.of(context).overview),
                      maxLines: 3,
                    ),
                    DropdownButtonFormField<CarType>(
                      value: _selectedCarType,
                      decoration:
                          InputDecoration(labelText: S.of(context).car_type),
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
                    DropdownButtonFormField<FuelType>(
                      value: _selectedFuelType,
                      decoration:
                          InputDecoration(labelText: S.of(context).fuel),
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
                      value: _selectedTransmissionType,
                      decoration: InputDecoration(
                          labelText: S.of(context).transmission),
                      onChanged: (TransmissionType? newValue) {
                        setState(() {
                          _selectedTransmissionType = newValue!;
                        });
                      },
                      items:
                          TransmissionType.values.map((TransmissionType type) {
                        return DropdownMenuItem<TransmissionType>(
                          value: type,
                          child: Text(type.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),
                    _pickedImage != null
                        ? Image.file(_pickedImage!)
                        : CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showImagePickerModal,
                            child: Text(S.of(context).change_image),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(S.of(context).update_vehicle),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
