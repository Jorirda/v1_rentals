import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1_rentals/models/user_model.dart';

class Vehicle {
  String id;
  String brand;
  String type;
  int seats;
  String fuelType;
  String transmission;
  String pricePerDay;
  String color;
  String overview;
  String imageUrl;
  bool available;
  String vendorId; // Reference to the vendor's user ID

  Vehicle({
    required this.id,
    required this.brand,
    required this.type,
    required this.seats,
    required this.fuelType,
    required this.transmission,
    required this.pricePerDay,
    required this.overview,
    required this.imageUrl,
    required this.available,
    required this.color,
    required this.vendorId, // Change to vendorId
  });

  // Convert DocumentSnapshot to Vehicle object
  factory Vehicle.fromMap(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      brand: data['brand'] ?? '',
      type: data['type'] ?? '',
      seats: data['seats'] ?? 0,
      fuelType: data['fuelType'] ?? '',
      transmission: data['transmission'] ?? '',
      color: data['color'] ?? '',
      pricePerDay: data['pricePerDay'] ?? '',
      overview: data['overview'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      available: data['available'] ?? false,
      vendorId: data['vendorId'] ?? '', // Update to vendorId
    );
  }

  // Convert Vehicle object to Map
  Map<String, dynamic> toMap() {
    return {
      'brand': brand,
      'type': type,
      'seats': seats,
      'fuelType': fuelType,
      'transmission': transmission,
      'color': color,
      'pricePerDay': pricePerDay,
      'overview': overview,
      'imageUrl': imageUrl,
      'available': available,
      'vendorId': vendorId, // Update to vendorId
    };
  }
}
