import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v1_rentals/providers/theme_provider.dart';
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
  bool _isAuthenticating = false;
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
      setState(() {
        _isAuthenticating = true;
      });

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
          ;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            themeProvider.themeMode == ThemeMode.dark
                ? Icons.dark_mode
                : Icons.light_mode,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            themeProvider.setThemeMode(
              themeProvider.themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark,
            );
          },
        ),
        title: Text(
          S.of(context).sign_up,
          style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<Locale>(
            icon: Icon(
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
                  style: TextStyle(
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
                _isAuthenticating
                    ? CircularProgressIndicator()
                    : Container(), // Show CircularProgressIndicator if _isAuthenticating is true
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
                  style: TextStyle(fontWeight: FontWeight.bold),
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
      child: Column(
        children: <Widget>[
          // Full Name TextField
          buildTextFormField(
            keyboardType: TextInputType.text,
            hintText: S.of(context).full_name,
            controller: _fullnameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).full_name_required;
              }
              return null;
            },
            icon: Icons.person,
          ),
          const SizedBox(height: 10),
          // Email TextField
          buildTextFormField(
            keyboardType: TextInputType.emailAddress,
            hintText: S.of(context).email,
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).email_required;
              }
              return null;
            },
            icon: Icons.email,
          ),
          const SizedBox(height: 10),
          // Password TextField
          buildTextFormField(
            keyboardType: TextInputType.text,
            hintText: S.of(context).password,
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).password_required;
              }
              return null;
            },
            icon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 10),
          // Phone Number TextField
          buildTextFormField(
            keyboardType: TextInputType.phone,
            hintText: S.of(context).phone_number,
            controller: _phoneNumController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).phone_required;
              }
              return null;
            },
            icon: Icons.phone,
          ),
          const SizedBox(height: 10),
          // Address TextField
          buildTextFormField(
            keyboardType: TextInputType.text,
            hintText: S.of(context).address,
            controller: _addressController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).address_required;
              }
              return null;
            },
            icon: Icons.location_on,
          ),
          const SizedBox(height: 10),
          // Date of Birth Text Field
          buildDatePickerField(
            context: context,
            hintText: S.of(context).date_of_birth,
            value: _dateOfBirthController.text,
            icon: Icons.calendar_today,
            onChanged: (value) {
              setState(() {
                _dateOfBirthController.text = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).dob_required;
              }
              return null;
            },
            firstDate:
                DateTime(1900), // Example: Allowing dates from the year 1900
          ),

          const SizedBox(height: 10),
          // Driver License Number TextField
          buildTextFormField(
            keyboardType: TextInputType.number,
            hintText: S.of(context).driver_license_number,
            controller: _driverLicenseNumberController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).license_required;
              }
              return null;
            },
            icon: Icons.card_membership,
          ),
          const SizedBox(height: 10),
          // Expiry Date Textfield
          buildDatePickerField(
            context: context,
            hintText: S.of(context).expiry_date,
            value: _expiryDateController.text,
            icon: Icons.calendar_today,
            onChanged: (value) {
              setState(() {
                _expiryDateController.text = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).expiry_date_required;
              }
              return null;
            },
            firstDate: DateTime(
                DateTime.now().year), // Allowing dates from the current year
          ),
          const SizedBox(height: 10),
          // Issuing Country TextField
          buildTextFormField(
            keyboardType: TextInputType.text,
            hintText: S.of(context).issuing_country,
            controller: _issuingCountryController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).country_required;
              }
              return null;
            },
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildVendorForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          // Full Name TextField
          buildTextFormField(
            keyboardType: TextInputType.text,
            hintText: S.of(context).full_name,
            controller: _fullnameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).full_name_required;
              }
              return null;
            },
            icon: Icons.person,
          ),
          const SizedBox(height: 10),

          // Email TextField
          buildTextFormField(
            keyboardType: TextInputType.emailAddress,
            hintText: S.of(context).email,
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).email_required;
              }
              return null;
            },
            icon: Icons.email,
          ),
          const SizedBox(height: 10),
          // Password TextField
          buildTextFormField(
            keyboardType: TextInputType.text,
            hintText: S.of(context).password,
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).password_required;
              }
              return null;
            },
            icon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 10),
          // Phone Number TextField
          buildTextFormField(
            keyboardType: TextInputType.phone,
            hintText: S.of(context).phone_number,
            controller: _phoneNumController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).phone_required;
              }
              return null;
            },
            icon: Icons.phone,
          ),
          const SizedBox(height: 10),
          // Address TextField
          buildTextFormField(
            keyboardType: TextInputType.text,
            hintText: S.of(context).address,
            controller: _addressController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).address_required;
              }
              return null;
            },
            icon: Icons.location_on,
          ),
          const SizedBox(height: 10),
          // Business Name TextField
          buildTextFormField(
            keyboardType: TextInputType.text,
            hintText: S.of(context).business_name,
            controller: _businessNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).business_name_required;
              }
              return null;
            },
            icon: Icons.business,
          ),
          const SizedBox(height: 10),
          // Business Registration Number TextField
          buildTextFormField(
            keyboardType: TextInputType.number,
            hintText: S.of(context).business_reg_number,
            controller: _businessRegNumController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).business_reg_required;
              }
              return null;
            },
            icon: Icons.app_registration,
          ),
          const SizedBox(height: 10),
          // Tax Identification Number TextField
          buildTextFormField(
            keyboardType: TextInputType.number,
            hintText: S.of(context).tax_identification_number,
            controller: _taxIdentificationNumController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).tax_identification_required;
              }
              return null;
            },
            icon: Icons.credit_card,
          ),
          const SizedBox(height: 10),
          // Expiry Date Textfield
          buildDatePickerField(
            context: context,
            hintText: S.of(context).expiry_date,
            value: _expiryDateController.text,
            icon: Icons.calendar_today,
            onChanged: (value) {
              setState(() {
                _expiryDateController.text = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return S.of(context).expiry_date_required;
              }
              return null;
            },
            firstDate: DateTime(
                DateTime.now().year), // Allowing dates from the current year
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget buildTextFormField({
    required String hintText,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
    required TextInputType keyboardType,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
      child: TextFormField(
        keyboardType: keyboardType,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon),
          prefixIconColor: Theme.of(context).colorScheme.primary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget buildDatePickerField({
    required BuildContext context,
    required String hintText,
    required String value,
    required IconData icon,
    required String? Function(String?) validator,
    required void Function(String) onChanged,
    required DateTime firstDate,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
      child: TextFormField(
        controller: TextEditingController(text: value),
        readOnly: true,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon),
          prefixIconColor: Theme.of(context).colorScheme.primary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        validator: validator,
        keyboardType: TextInputType.datetime,
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: firstDate,
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            String formattedDate =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            onChanged(formattedDate);
          }
        },
      ),
    );
  }
}
