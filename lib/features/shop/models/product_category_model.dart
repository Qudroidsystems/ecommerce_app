class ProductCategoryModel {
  final String productId;
  final String categoryId;

  ProductCategoryModel({
    required this.productId,
    required this.categoryId,
  });

  /// Converts the model to a JSON map.
  Map<String, dynamic> toJson() => {
    'productId': productId,
    'categoryId': categoryId,
  };

  /// Creates an instance from a JSON map safely.
  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      productId: json['productId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
    );
  }

  /// Returns a copy of the instance with updated values.
  ProductCategoryModel copyWith({
    String? productId,
    String? categoryId,
  }) {
    return ProductCategoryModel(
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  String toString() => 'ProductCategoryModel(productId: $productId, categoryId: $categoryId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is ProductCategoryModel &&
              other.productId == productId &&
              other.categoryId == categoryId);

  @override
  int get hashCode => productId.hashCode ^ categoryId.hashCode;
}
