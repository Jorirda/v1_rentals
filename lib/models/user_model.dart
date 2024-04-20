enum UserType { client, vendor }

class CustomUser {
  final String userId;
  final String email;
  final String password;
  final UserType userType;

  CustomUser({
    required this.userId,
    required this.email,
    required this.password,
    required this.userType,
  });
}

class Client extends CustomUser {
  final String clientId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String address;

  Client({
    required super.userId,
    required super.email,
    required super.password,
    required super.userType,
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.address,
  });
}

class Vendor extends CustomUser {
  final String vendorId;
  final String companyName;
  final String phoneNumber;
  final String address;

  Vendor({
    required super.userId,
    required super.email,
    required super.password,
    required super.userType,
    required this.vendorId,
    required this.companyName,
    required this.phoneNumber,
    required this.address,
  });
}
