import 'package:v1_rentals/models/vehicle_model.dart'; // Ensure this import is present to access the Brand enum

class RecommendModel {
  Brand brand; // Change type to Brand enum
  String iconPath;

  RecommendModel({
    required this.brand, // Change to Brand enum
    required this.iconPath,
  });

  static List<RecommendModel> getRecommendedBrands() {
    List<RecommendModel> recommendBrands = [];

    recommendBrands.add(RecommendModel(
      brand: Brand.suzuki, // Use Brand enum
      iconPath: 'assets/rec-images/suzuki-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      brand: Brand.ford, // Use Brand enum
      iconPath: 'assets/rec-images/ford-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      brand: Brand.toyota, // Use Brand enum
      iconPath: 'assets/rec-images/toyota-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      brand: Brand.nissan, // Use Brand enum
      iconPath: 'assets/rec-images/nissan-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      brand: Brand.bmw, // Use Brand enum
      iconPath: 'assets/rec-images/bmw-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      brand: Brand.audi, // Use Brand enum
      iconPath: 'assets/rec-images/audi-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      brand: Brand.honda, // Use Brand enum
      iconPath: 'assets/rec-images/honda-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      brand: Brand.hyundai, // Use Brand enum
      iconPath: 'assets/rec-images/hyundai-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      brand: Brand.isuzu, // Use Brand enum
      iconPath: 'assets/rec-images/isuzu-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      brand: Brand.mazda, // Use Brand enum
      iconPath: 'assets/rec-images/mazda-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      brand: Brand.kia, // Use Brand enum
      iconPath: 'assets/rec-images/kia-logo.png',
    ));

    return recommendBrands;
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
