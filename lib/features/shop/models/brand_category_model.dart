class BrandCategoryModel {
  final String brandId;
  final String categoryId;

  /// Constructor
  const BrandCategoryModel({
    required this.brandId,
    required this.categoryId,
  });

  /// Convert model to JSON for API requests
  Map<String, dynamic> toJson() => {
    'brand_id': brandId, // Using snake_case for Laravel compatibility
    'category_id': categoryId,
  };

  /// Create a BrandCategoryModel from JSON received from the Laravel API
  factory BrandCategoryModel.fromJson(Map<String, dynamic> json) {
    return BrandCategoryModel(
      brandId: json['brand_id']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
    );
  }

  /// Create an empty instance for clean code
  static const BrandCategoryModel empty = BrandCategoryModel(
    brandId: '',
    categoryId: '',
  );

  /// CopyWith method for immutability
  BrandCategoryModel copyWith({
    String? brandId,
    String? categoryId,
  }) {
    return BrandCategoryModel(
      brandId: brandId ?? this.brandId,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
