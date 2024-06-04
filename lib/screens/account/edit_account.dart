import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:provider/provider.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/providers/account_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image/image.dart' as img;

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen(this.onImagePicked, {super.key});

  final void Function(String?)? onImagePicked;

  @override
  _EditAccountScreenState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;

  late File _image = File('');
  final picker = ImagePicker();
  String? _imageURL;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();

    if (_user != null) {
      Provider.of<AccountDataProvider>(context, listen: false).fetchUserData();
      var accountDataProvider =
          Provider.of<AccountDataProvider>(context, listen: false);
      if (accountDataProvider.user != null) {
        _fullNameController.text = accountDataProvider.user!.fullname;
        _emailController.text = accountDataProvider.user!.email;
        _phoneNumberController.text = accountDataProvider.user!.phoneNum;
        _addressController.text = accountDataProvider.user!.address;
        _imageURL = accountDataProvider.user!.imageURL;
      }
    }
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _compressAndUploadImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _compressAndUploadImage() async {
    final img.Image? image = img.decodeImage(_image.readAsBytesSync());
    if (image == null) {
      print('Error decoding image.');
      return;
    }

    final img.Image resizedImage = img.copyResize(image, width: 600);
    final File compressedImageFile = File(_image.path)
      ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 85));

    try {
      await firebase_storage.FirebaseStorage.instance
          .ref('profile_pictures/${_user!.uid}.jpg')
          .putFile(compressedImageFile);
      final String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref('profile_pictures/${_user!.uid}.jpg')
          .getDownloadURL();

      setState(() {
        _imageURL = downloadURL;
        if (widget.onImagePicked != null) {
          widget.onImagePicked!(downloadURL);
        }
      });

      print('Image Uploaded');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void _saveChanges() async {
    try {
      if (_user != null) {
        Map<String, dynamic> updatedData = {
          'fullname': _fullNameController.text,
          'email': _emailController.text,
          'phoneNum': _phoneNumberController.text,
          'address': _addressController.text,
          'imageURL': _imageURL,
        };

        await Provider.of<AccountDataProvider>(context, listen: false)
            .updateUserData(updatedData);

        Navigator.of(context).pop();
      }
    } catch (e) {
      print("Error updating account: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).edit_account),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              GestureDetector(
                onTap: _getImageFromGallery,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage: _imageURL != null
                          ? CachedNetworkImageProvider(_imageURL!)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _getImageFromGallery,
                child: Text(
                  S.of(context).add_or_edit_photo,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Divider(
                indent: 60,
                endIndent: 60,
              ),
              const SizedBox(
                height: 20,
              ),
              _buildTextField(
                  S.of(context).full_name, _fullNameController, Icons.person),
              _buildTextField(
                  S.of(context).email, _emailController, Icons.email),
              _buildTextField(S.of(context).phone_number,
                  _phoneNumberController, Icons.phone),
              _buildTextField(S.of(context).address, _addressController,
                  Icons.location_city),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  child: Text(S.of(context).save_changes),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String hintText, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: hintText,
              hintText: hintText,
              border: InputBorder.none,
              icon: Icon(icon),
              labelStyle: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).please_enter_your(hintText);
              }
              return null;
            },
          ),
        ),
      ),
    );
  }
}
