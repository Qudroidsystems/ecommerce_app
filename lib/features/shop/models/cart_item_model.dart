class CartItemModel {
  final String productId;
  final String title;
  final double price;
  int quantity; // Removed 'final' to allow updates in CartController
  final String variationId;
  final String image;
  final String brandName;
  final Map<String, String>? selectedVariation; // Changed to Map<String, String>

  CartItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.variationId,
    required this.image,
    required this.brandName,
    this.selectedVariation,
  });

  /// Convert model to JSON for storage or API requests
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'title': title,
      'price': price,
      'quantity': quantity,
      'variation_id': variationId,
      'image': image,
      'brand_name': brandName,
      'selected_variation': selectedVariation,
    };
  }

  /// Create a CartItemModel from JSON received from API or local storage
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['product_id'] ?? '',
      title: json['title'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      variationId: json['variation_id'] ?? '',
      image: json['image'] ?? '',
      brandName: json['brand_name'] ?? '',
      selectedVariation: json['selected_variation'] != null
          ? Map<String, String>.from(json['selected_variation']) // Fix: Convert JSON map
          : null,
    );
  }

  /// Create an empty instance
  static CartItemModel empty() => CartItemModel(
    productId: '',
    title: '',
    price: 0.0,
    quantity: 0,
    variationId: '',
    image: '',
    brandName: '',
    selectedVariation: null,
  );
}
