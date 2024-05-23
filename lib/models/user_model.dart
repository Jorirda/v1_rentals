enum UserType { client, vendor }

class CustomUser {
  String? userId; // Make userId nullable
  String fullname;
  String email;
  String password;
  String phoneNum;
  String address;
  UserType userType;
  DateTime createdAt;
  String? imageURL; // Add imageURL
  String? fcmToken; // Add fcmToken

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
    this.imageURL,
    this.fcmToken, // Initialize fcmToken
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
      'imageURL': imageURL,
      'fcmToken': fcmToken, // Add fcmToken to map
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

  factory CustomUser.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      throw ArgumentError('Map cannot be null');
    }

    return CustomUser(
      userId: map['userId'] as String?,
      fullname: map['fullname'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phoneNum: map['phoneNum'] as String,
      address: map['address'] as String,
      userType: map['userType'] == 'client' ? UserType.client : UserType.vendor,
      createdAt:
          DateTime.parse(map['createdAt'] as String), // Parse ISO 8601 format
      dateOfBirth: map['dateOfBirth'] as String?,
      driverLicenseNumber: map['driverLicenseNumber'] as String?,
      issuingCountryState: map['issuingCountryState'] as String?,
      expiryDate: map['expiryDate'] as String?,
      businessName: map['businessName'] as String?,
      regNum: map['regNum'] as String?,
      tinNum: map['tinNum'] as String?,
      imageURL: map['imageURL'] as String?,
      fcmToken: map['fcmToken'] as String?, // Initialize fcmToken
    );
  }
}
