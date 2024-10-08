import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v1_rentals/models/enum_extensions.dart';

enum Brand {
  suzuki,
  ford,
  toyota,
  nissan,
  bmw,
  audi,
  honda,
  hyundai,
  isuzu,
  mazda,
  kia,
}

enum CarType {
  all,
  suv,
  sedan,
  truck,
  van,
  electric,
  hybrid,
  hatchback,
  sports,
  luxury,
  convertible
}

enum TransmissionType {
  automatic,
  manual,
}

enum FuelType {
  gasoline,
  diesel,
  electric,
  hybrid,
}

class Vehicle {
  String id;
  Brand brand;
  String model;
  String modelYear;
  CarType carType;
  int seats;
  FuelType fuelType;
  TransmissionType transmission;
  int pricePerDay;
  double rating;
  String color;
  String overview;
  String imageUrl;
  bool available;
  String vendorId; // Reference to the vendor's user ID
  bool isFavorite;

  Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.carType,
    required this.seats,
    required this.fuelType,
    required this.transmission,
    required this.pricePerDay,
    required this.rating,
    required this.overview,
    required this.imageUrl,
    required this.available,
    required this.color,
    required this.vendorId,
    required this.modelYear,
    required this.isFavorite,
  });

  // Convert DocumentSnapshot to Vehicle object
  factory Vehicle.fromMap(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      brand: Brand.values
          .firstWhere((e) => e.toString() == 'Brand.${data['brand']}'),
      model: data['model'] ?? '',
      modelYear: data['modelYear'] ?? '',
      carType: CarType.values
          .firstWhere((e) => e.toString() == 'CarType.${data['carType']}'),
      seats: data['seats'] ?? 0,
      fuelType: FuelType.values
          .firstWhere((e) => e.toString() == 'FuelType.${data['fuelType']}'),
      transmission: TransmissionType.values.firstWhere(
          (e) => e.toString() == 'TransmissionType.${data['transmission']}'),
      color: data['color'] ?? '',
      pricePerDay: data['pricePerDay'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      overview: data['overview'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      available: data['available'] ?? false,
      vendorId: data['vendorId'] ?? '',
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  // Convert Vehicle object to Map
  Map<String, dynamic> toMap() {
    return {
      'brand': brand.toString().split('.').last,
      'model': model,
      'modelYear': modelYear,
      'carType': carType.toString().split('.').last,
      'seats': seats,
      'fuelType': fuelType.toString().split('.').last,
      'transmission': transmission.toString().split('.').last,
      'color': color,
      'pricePerDay': pricePerDay,
      'rating': rating,
      'overview': overview,
      'imageUrl': imageUrl,
      'available': available,
      'isFavorite': isFavorite,
      'vendorId': vendorId,
    };
  }

  String getCarTypeString() {
    return carType.getTranslation();
  }

  String getFuelTypeString() {
    return fuelType.getTranslation();
  }

  String getTransmissionTypeString() {
    return transmission.getTranslation();
  }

  // Helper method to convert a string to a Brand enum value
  static Brand getBrandFromString(String brandString) {
    switch (brandString.toLowerCase()) {
      case 'suzuki':
        return Brand.suzuki;
      case 'ford':
        return Brand.ford;
      case 'toyota':
        return Brand.toyota;
      case 'nissan':
        return Brand.nissan;
      case 'bmw':
        return Brand.bmw;
      case 'audi':
        return Brand.audi;
      case 'honda':
        return Brand.honda;
      case 'hyundai':
        return Brand.hyundai;
      case 'isuzu':
        return Brand.isuzu;
      case 'mazda':
        return Brand.mazda;
      case 'kia':
        return Brand.kia;
      default:
        throw Exception('Invalid brand string: $brandString');
    }
  }
}
