import 'brand_model.dart';
import 'product_attribute_model.dart';
import 'product_variation_model.dart';

class ProductModel {
  String id;
  int stock;
  String? sku;
  double price;
  String title;
  DateTime? date;
  int soldQuantity;
  double salePrice;
  String thumbnail;
  bool? isFeatured;
  BrandModel? brand;
  String? categoryId;
  String productType;
  String? description;
  List<String>? images;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;

  ProductModel({
    required this.id,
    required this.title,
    required this.stock,
    required this.price,
    required this.thumbnail,
    required this.productType,
    this.soldQuantity = 0,
    this.sku,
    this.brand,
    this.date,
    this.images,
    this.salePrice = 0.0,
    this.isFeatured,
    this.categoryId,
    this.description,
    this.productAttributes,
    this.productVariations,
  });

  /// Create an empty instance for clean code
  static ProductModel empty() => ProductModel(
    id: '',
    title: '',
    stock: 0,
    price: 0,
    thumbnail: '',
    productType: '',
    soldQuantity: 0,
  );

  /// Convert model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'title': title,
      'stock': stock,
      'price': price,
      'images': images ?? [],
      'thumbnail': thumbnail,
      'sale_price': salePrice,
      'is_featured': isFeatured,
      'category_id': categoryId,
      'brand': brand?.toJson(),
      'description': description,
      'product_type': productType,
      'sold_quantity': soldQuantity,
      'product_attributes': productAttributes != null
          ? productAttributes!.map((e) => e.toJson()).toList()
          : [],
      'product_variations': productVariations != null
          ? productVariations!.map((e) => e.toJson()).toList()
          : [],
    };
  }

  /// Create a ProductModel from JSON received from the Laravel API
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'].toString(), // Ensure ID is a string
      title: json['title'] ?? '',
      price: (json['price'] is String
          ? double.tryParse(json['price']) ?? 0.0
          : json['price']?.toDouble() ?? 0.0),
      sku: json['sku'],
      stock: json['stock'] ?? 0,
      soldQuantity: json['sold_quantity'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      salePrice: (json['sale_price'] is String
          ? double.tryParse(json['sale_price']) ?? 0.0
          : json['sale_price']?.toDouble() ?? 0.0),
      thumbnail: json['thumbnail'] ?? '',
      categoryId: json['category_id']?.toString(),
      description: json['description'],
      productType: json['product_type'] ?? '',
      brand: json['brand'] != null ? BrandModel.fromJson(json['brand']) : null,
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      productAttributes: json['product_attributes'] != null
          ? (json['product_attributes'] as List<dynamic>)
          .map((e) => ProductAttributeModel.fromJson(e))
          .toList()
          : [],
      productVariations: json['product_variations'] != null
          ? (json['product_variations'] as List<dynamic>)
          .map((e) => ProductVariationModel.fromJson(e))
          .toList()
          : [],
    );
  }
}