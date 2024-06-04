class SearchHistory {
  final String? id; // Optional id
  final String locationName;
  final String address;
  final double latitude;
  final double longitude;

  SearchHistory({
    this.id,
    required this.locationName,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  // Add a method to convert from a Map
  factory SearchHistory.fromMap(Map<String, dynamic> data, String documentId) {
    return SearchHistory(
      id: documentId,
      locationName: data['locationName'],
      address: data['address'],
      latitude: data['latitude'],
      longitude: data['longitude'],
    );
  }

  // Convert to Map if needed
  Map<String, dynamic> toMap() {
    return {
      'locationName': locationName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
