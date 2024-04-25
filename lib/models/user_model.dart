enum UserType { client, vendor }

class CustomUser {
  String? userId;
  String fullname;
  String email;
  String password;
  String phoneNum;
  String address;
  UserType userType;
  DateTime createdAt;
  String? imageURL; // Add imageURL

  // Client fields
  String? dateOfBirth;
  String? driverLicenseNumber;
  String? issuingCountryState;
  String? expiryDate;

  // Vendor fields
  String? businessName;
  String? regNum;
  String? tinNum;

  CustomUser({
    required this.userId,
    required this.fullname,
    required this.email,
    required this.password,
    required this.phoneNum,
    required this.address,
    required this.userType,
    required this.createdAt,
    this.dateOfBirth,
    this.driverLicenseNumber,
    this.issuingCountryState,
    this.expiryDate,
    this.businessName,
    this.regNum,
    this.tinNum,
    this.imageURL, // Initialize imageURL
  });

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'userId': userId,
      'fullname': fullname,
      'email': email,
      'password': password,
      'phoneNum': phoneNum,
      'address': address,
      'userType': userType == UserType.client ? 'client' : 'vendor',
      'createdAt': createdAt.toIso8601String(), // Convert to ISO 8601 format
      'imageURL': imageURL, // Add imageURL
    };

    if (userType == UserType.client) {
      data.addAll(_clientToMap());
    } else {
      data.addAll(_vendorToMap());
    }

    return data;
  }

  Map<String, dynamic> _clientToMap() {
    return {
      'dateOfBirth': dateOfBirth,
      'driverLicenseNumber': driverLicenseNumber,
      'issuingCountryState': issuingCountryState,
      'expiryDate': expiryDate,
    };
  }

  Map<String, dynamic> _vendorToMap() {
    return {
      'businessName': businessName,
      'regNum': regNum,
      'tinNum': tinNum,
    };
  }

  factory CustomUser.fromMap(Map<String, dynamic> map) {
    return CustomUser(
      userId: map['userId'],
      fullname: map['fullname'],
      email: map['email'],
      password: map['password'],
      phoneNum: map['phoneNum'],
      address: map['address'],
      userType: map['userType'] == 'client' ? UserType.client : UserType.vendor,
      createdAt: DateTime.parse(map['createdAt']), // Parse ISO 8601 format
      dateOfBirth: map['dateOfBirth'],
      driverLicenseNumber: map['driverLicenseNumber'],
      issuingCountryState: map['issuingCountryState'],
      expiryDate: map['expiryDate'],
      businessName: map['businessName'],
      regNum: map['regNum'],
      tinNum: map['tinNum'],
      imageURL: map['imageURL'], // Initialize imageURL
    );
  }
}
