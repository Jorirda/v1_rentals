class RecommendModel {
  // String name;
  String iconPath;

  RecommendModel({
    required this.iconPath,
  });

  static List<RecommendModel> getRecommendedBrands() {
    List<RecommendModel> recommendBrands = [];

    recommendBrands.add(RecommendModel(
      iconPath: 'assets/rec-images/suzuki-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      iconPath: 'assets/rec-images/ford-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      iconPath: 'assets/rec-images/toyota-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      iconPath: 'assets/rec-images/nissan-logo.png',
    ));
    recommendBrands.add(RecommendModel(
      iconPath: 'assets/rec-images/bmw-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      iconPath: 'assets/rec-images/audi-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      iconPath: 'assets/rec-images/honda-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      iconPath: 'assets/rec-images/hyundai-logo.png',
    ));
    recommendBrands.add(RecommendModel(
      iconPath: 'assets/rec-images/isuzu-logo.png',
    ));

    recommendBrands.add(RecommendModel(
      iconPath: 'assets/rec-images/mazda-logo.png',
    ));
    recommendBrands.add(RecommendModel(
      iconPath: 'assets/rec-images/kia-logo.png',
    ));

    return recommendBrands;
  }
}
