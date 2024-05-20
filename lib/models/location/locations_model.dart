class Locations {
  final String locationName;
  final String address;
  final double latitude;
  final double longitude;

  Locations({
    required this.locationName,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory Locations.fromMap(Map<String, dynamic> map) {
    return Locations(
      locationName: map['locationName'],
      address: map['address'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'locationName': locationName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
