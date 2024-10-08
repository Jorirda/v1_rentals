import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/services/auth_service.dart';
import 'package:v1_rentals/l10n/locale_provider.dart';
import 'package:v1_rentals/models/user_model.dart';
import 'package:v1_rentals/generated/l10n.dart';
import 'package:v1_rentals/models/enum_extensions.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen(this.showLogin, {super.key});

  final VoidCallback showLogin;

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  UserType _selectedUserType = UserType.client;

  late TextEditingController _fullnameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneNumController;
  late TextEditingController _addressController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _expiryDateController;
  late TextEditingController _driverLicenseNumberController;
  late TextEditingController _issuingCountryController;
  late TextEditingController _businessNameController;
  late TextEditingController _businessRegNumController;
  late TextEditingController _taxIdentificationNumController;

  @override
  void initState() {
    super.initState();
    _fullnameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneNumController = TextEditingController();
    _addressController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _expiryDateController = TextEditingController();
    _driverLicenseNumberController = TextEditingController();
    _issuingCountryController = TextEditingController();
    _businessNameController = TextEditingController();
    _businessRegNumController = TextEditingController();
    _taxIdentificationNumController = TextEditingController();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    _expiryDateController.dispose();
    _driverLicenseNumberController.dispose();
    _issuingCountryController.dispose();
    _businessNameController.dispose();
    _businessRegNumController.dispose();
    _taxIdentificationNumController.dispose();

    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      CustomUser user = CustomUser(
        userId: '', // Set to empty string initially
        email: _emailController.text,
        password: _passwordController.text,
        userType: _selectedUserType,
        fullname: _fullnameController.text,
        phoneNum: _phoneNumController.text,
        address: _addressController.text,
        dateOfBirth: _dateOfBirthController.text,
        driverLicenseNumber: _driverLicenseNumberController.text,
        issuingCountryState: _issuingCountryController.text,
        expiryDate: _expiryDateController.text,
        businessName: _businessNameController.text,
        regNum: _businessRegNumController.text,
        tinNum: _taxIdentificationNumController.text,
        createdAt: DateTime.now(),
      );

      try {
        String userId = await AuthService().signUp(user);
        if (userId.isNotEmpty) {
          user.userId = userId;
          // Update userId with the actual value
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign up successful'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).sign_up,
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(
              Icons.language,
              color: Colors.blue,
            ),
            onSelected: (Locale locale) {
              localeProvider.setLocale(locale);
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: const Locale('en'),
                  child: Text(S.of(context).english),
                ),
                PopupMenuItem(
                  value: const Locale('zh'),
                  child: Text(S.of(context).chinese),
                ),
              ];
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image Container
                Container(
                  margin: const EdgeInsets.only(
                    top: 30,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  width: 200,
                  child: Image.asset('assets/images/v1-rentals-logo.png'),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  S.of(context).create_account,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                // Welcome Text
                Text(
                  S.of(context).select_user_type,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),

                ToggleButtons(
                  isSelected: UserType.values.map((UserType userType) {
                    return userType == _selectedUserType;
                  }).toList(),
                  onPressed: (int index) {
                    setState(() {
                      _selectedUserType = UserType.values[index];
                    });
                  },
                  constraints:
                      const BoxConstraints.expand(width: 150, height: 50),
                  selectedColor: Colors.white,
                  selectedBorderColor: Theme.of(context).colorScheme.primary,
                  fillColor: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(15),
                  children: UserType.values.map((UserType userType) {
                    // Use the getTranslation method for localization
                    return Text(userType.getTranslation());
                  }).toList(),
                ),
                const SizedBox(
                  height: 20,
                ),
                // Render different forms based on user type
                _selectedUserType == UserType.client
                    ? _buildClientForm(context)
                    : _buildVendorForm(context),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                child: Text(S.of(context).sign_up),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).already_member,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  width: 4,
                ),
                // Switch to Login page
                GestureDetector(
                  onTap: widget.showLogin,
                  child: Text(
                    S.of(context).login,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Full Name Text Field
            FormTextField(
              hintText: S.of(context).full_name,
              keyboardType: TextInputType.text,
              iconValue: Icons.person,
              controller: _fullnameController,
            ),
            const SizedBox(
              height: 10,
            ),
            // Email Textfield
            FormTextField(
              hintText: S.of(context).email,
              keyboardType: TextInputType.emailAddress,
              iconValue: Icons.email,
              controller: _emailController,
            ),
            const SizedBox(
              height: 10,
            ),
            // Password Textfield
            FormTextField(
              hintText: S.of(context).password,
              iconValue: Icons.password,
              keyboardType: TextInputType.text,
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 10),
            // Expiry Date Textfield
            buildDatePickerField(
              hintText: S.of(context).date_of_birth,
              value: _dateOfBirthController.text,
              icon: Icons.calendar_today,
              onChanged: (value) {
                setState(() {
                  _dateOfBirthController.text = value;
                });
              },
            ),
            const SizedBox(height: 10),
            // Phone No. Textfield
            FormTextField(
              hintText: S.of(context).phone_number,
              iconValue: Icons.phone,
              keyboardType: TextInputType.number,
              controller: _phoneNumController,
            ),
            const SizedBox(height: 10),
            // Address Textfield
            FormTextField(
              hintText: S.of(context).address,
              iconValue: Icons.add_location_alt_rounded,
              keyboardType: TextInputType.text,
              controller: _addressController,
            ),
            const SizedBox(height: 10),
            // Driver License Textfield
            FormTextField(
              hintText: S.of(context).driver_license_number,
              iconValue: Icons.car_rental,
              keyboardType: TextInputType.text,
              controller: _driverLicenseNumberController,
            ),
            const SizedBox(height: 10),
            // Issuing Country State Textfield
            FormTextField(
              hintText: S.of(context).issuing_country,
              iconValue: Icons.language,
              keyboardType: TextInputType.text,
              controller: _issuingCountryController,
            ),
            const SizedBox(height: 10),
            // Expiry Date Textfield
            buildDatePickerField(
              hintText: S.of(context).expiry_date,
              value: _expiryDateController.text,
              icon: Icons.calendar_today,
              onChanged: (value) {
                setState(() {
                  _expiryDateController.text = value;
                });
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildVendorForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Full Name Text Field
            FormTextField(
              hintText: S.of(context).full_name,
              keyboardType: TextInputType.text,
              iconValue: Icons.person,
              controller: _fullnameController,
            ),
            const SizedBox(height: 10),
            // Email Textfield
            FormTextField(
              hintText: S.of(context).email,
              keyboardType: TextInputType.emailAddress,
              iconValue: Icons.email,
              controller: _emailController,
            ),
            const SizedBox(
              height: 10,
            ),
            // Password Textfield
            FormTextField(
              hintText: S.of(context).password,
              iconValue: Icons.password,
              keyboardType: TextInputType.text,
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 10),
            // Phone # Textfield
            FormTextField(
              hintText: S.of(context).phone_number,
              iconValue: Icons.phone,
              keyboardType: TextInputType.number,
              controller: _phoneNumController,
            ),
            const SizedBox(height: 10),
            // Business Name Textfield
            FormTextField(
              hintText: S.of(context).business_name,
              iconValue: Icons.business_center,
              keyboardType: TextInputType.text,
              controller: _businessNameController,
            ),
            const SizedBox(height: 10),
            // Address Textfield
            FormTextField(
              hintText: S.of(context).address,
              iconValue: Icons.add_location_alt_rounded,
              keyboardType: TextInputType.text,
              controller: _addressController,
            ),
            const SizedBox(height: 10),
            // Business Registration Number Textfield
            FormTextField(
              hintText: S.of(context).business_registration_number,
              iconValue: Icons.numbers,
              keyboardType: TextInputType.text,
              controller: _businessRegNumController,
            ),
            const SizedBox(height: 10),
            // Tax Identification Number Textfield
            FormTextField(
              hintText: S.of(context).tax_identification_number,
              iconValue: Icons.numbers,
              keyboardType: TextInputType.text,
              controller: _taxIdentificationNumController,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildDatePickerField({
    required String hintText,
    required String value,
    required IconData icon,
    required void Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
      child: TextFormField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon),
          prefixIconColor: Theme.of(context).colorScheme.primary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        keyboardType: TextInputType.datetime,
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            onChanged(
                "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}");
          }
        },
      ),
    );
  }
}

class FormTextField extends StatelessWidget {
  final String hintText;
  final IconData iconValue;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final bool obscureText;

  const FormTextField({
    super.key,
    required this.hintText,
    required this.iconValue,
    required this.keyboardType,
    this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(iconValue),
          prefixIconColor: Theme.of(context).colorScheme.primary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }
}
