import 'dart:convert';
import 'package:cwt_ecommerce_app/features/shop/models/brand_model.dart';
import 'package:cwt_ecommerce_app/features/shop/models/product_attribute_model.dart';
import 'package:cwt_ecommerce_app/features/shop/models/product_variation_model.dart';

class ProductModel {
  String id;
  String title;
  int stock;
  String? sku;
  double price;
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

  static ProductModel empty() => ProductModel(
    id: '',
    title: '',
    stock: 0,
    price: 0.0,
    thumbnail: '',
    productType: '',
  );

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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    dynamic attributesData = json['product_attributes'];
    List<dynamic> parsedAttributes = [];

    if (attributesData is String && attributesData.isNotEmpty) {
      try {
        parsedAttributes = jsonDecode(attributesData) as List<dynamic>;
      } catch (e) {
        print('ProductModel: Error decoding product_attributes: $e');
        parsedAttributes = [];
      }
    } else if (attributesData is List<dynamic>) {
      parsedAttributes = attributesData;
    }

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      price: (json['price'] is String
          ? double.tryParse(json['price'] as String) ?? 0.0
          : (json['price'] as num?)?.toDouble() ?? 0.0),
      sku: json['sku'] as String?,
      stock: (json['stock'] is String
          ? int.tryParse(json['stock'] as String) ?? 0
          : (json['stock'] as num?)?.toInt() ?? 0),
      soldQuantity: (json['sold_quantity'] is String
          ? int.tryParse(json['sold_quantity'] as String) ?? 0
          : (json['sold_quantity'] as num?)?.toInt() ?? 0),
      isFeatured: json['is_featured'] == '1' ||
          json['is_featured'] == true ||
          (json['is_featured'] is int && json['is_featured'] == 1),
      salePrice: (json['sale_price'] is String
          ? double.tryParse(json['sale_price'] as String) ?? 0.0
          : (json['sale_price'] as num?)?.toDouble() ?? 0.0),
      thumbnail: json['thumbnail'] as String? ?? '',
      categoryId: (json['category_id'] ?? '').toString(),
      description: json['description'] as String?,
      productType: json['product_type'] as String? ?? '',
      brand: json['brand'] != null
          ? BrandModel.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      images: json['images'] != null
          ? (json['images'] as List<dynamic>).cast<String>()
          : <String>[],
      productAttributes: parsedAttributes
          .where((e) => e != null && e is Map<String, dynamic>)
          .map((e) => ProductAttributeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      productVariations: json['product_variations'] != null
          ? (json['product_variations'] as List<dynamic>)
          .where((e) => e != null && e is Map<String, dynamic>)
          .map((e) => ProductVariationModel.fromJson(e as Map<String, dynamic>))
          .toList()
          : <ProductVariationModel>[],
    );
  }
}