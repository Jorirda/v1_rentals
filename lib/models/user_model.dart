enum UserType { client, vendor }

class CustomUser {
  String? userId;

  final String fullname;
  final String email;
  final String password;
  final String phoneNum;
  final String address;
  final UserType userType;
  final DateTime createdAt;

  CustomUser({
    required this.userId,
    required this.fullname,
    required this.email,
    required this.password,
    required this.phoneNum,
    required this.address,
    required this.userType,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullname': fullname,
      'email': email,
      'password': password,
      'phoneNum': phoneNum,
      'address': address,
      'userType': userType == UserType.client ? 'client' : 'vendor',
      'createdAt': createdAt.toIso8601String(), // Convert to ISO 8601 format
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
    );
  }
}

class Client extends CustomUser {
  final String dateOfBirth;
  final String driverLicenseNumber;
  final String issuingCountryState;
  final String expiryDate;

  Client({
    required String userId,
    required String email,
    required String password,
    required UserType userType,
    required String fullname,
    required String phoneNum,
    required String address,
    required DateTime createdAt,
    required this.dateOfBirth,
    required this.driverLicenseNumber,
    required this.issuingCountryState,
    required this.expiryDate,
  }) : super(
          userId: userId,
          email: email,
          password: password,
          userType: userType,
          fullname: fullname,
          phoneNum: phoneNum,
          address: address,
          createdAt: createdAt,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'dateOfBirth': dateOfBirth,
      'driverLicenseNumber': driverLicenseNumber,
      'issuingCountryState': issuingCountryState,
      'expiryDate': expiryDate,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      userId: map['userId'],
      email: map['email'],
      password: map['password'],
      userType: UserType.client,
      fullname: map['fullname'],
      phoneNum: map['phoneNum'],
      address: map['address'],
      dateOfBirth: map['dateOfBirth'],
      driverLicenseNumber: map['driverLicenseNumber'],
      issuingCountryState: map['issuingCountryState'],
      expiryDate: map['expiryDate'],
      createdAt: DateTime.parse(map['createdAt']), // Parse ISO 8601 format
    );
  }
}

class Vendor extends CustomUser {
  final String businessName;
  final String regNum;
  final String tinNum;

  Vendor({
    required String userId,
    required String fullname,
    required String email,
    required String password,
    required String phoneNum,
    required String address,
    required UserType userType,
    required DateTime createdAt,
    required this.businessName,
    required this.regNum,
    required this.tinNum,
  }) : super(
          userId: userId,
          fullname: fullname,
          email: email,
          password: password,
          phoneNum: phoneNum,
          address: address,
          userType: userType,
          createdAt: createdAt,
        );

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'businessName': businessName,
      'regNum': regNum,
      'tinNum': tinNum,
    };
  }

  factory Vendor.fromMap(Map<String, dynamic> map) {
    return Vendor(
        userId: map['userId'],
        fullname: map['fullname'],
        email: map['email'],
        password: map['password'],
        phoneNum: map['phoneNum'],
        address: map['address'],
        userType: UserType.vendor,
        createdAt: DateTime.parse(map['createdAt']), // Parse ISO 8601 format
        businessName: map['businessName'],
        regNum: map['regNum'],
        tinNum: map['tinNum']);
  }
}
