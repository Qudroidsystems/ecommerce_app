import 'dart:convert';

class ProductVariationModel {
  final String id;
  String sku;
  String image;
  String? description;
  double price;
  double salePrice;
  int stock;
  int soldQuantity;
  Map<String, String> attributeValues;

  ProductVariationModel({
    required this.id,
    this.sku = '',
    this.image = '',
    this.description,
    this.price = 0.0,
    this.salePrice = 0.0,
    this.stock = 0,
    this.soldQuantity = 0,
    required this.attributeValues,
  });

  static ProductVariationModel empty() => ProductVariationModel(id: '', attributeValues: {});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'image': image,
      'description': description,
      'price': price,
      'sale_price': salePrice,
      'stock': stock,
      'sold_quantity': soldQuantity,
      'attributes': attributeValues,
    };
  }

  factory ProductVariationModel.fromJson(Map<String, dynamic> json) {
    dynamic attributesData = json['attributes'];
    Map<String, String> parsedAttributes = {};

    if (attributesData is String && attributesData.isNotEmpty) {
      try {
        parsedAttributes = Map<String, String>.from(jsonDecode(attributesData) as Map);
      } catch (e) {
        print('ProductVariationModel: Error decoding attributes: $e');
        parsedAttributes = {};
      }
    } else if (attributesData is Map) {
      parsedAttributes = Map<String, String>.from(attributesData);
    }

    return ProductVariationModel(
      id: (json['id'] ?? '').toString(),
      sku: json['sku'] as String? ?? '',
      image: json['image'] as String? ?? '',
      description: json['description'] as String?,
      price: (json['price'] is String
          ? double.tryParse(json['price'] as String) ?? 0.0
          : (json['price'] as num?)?.toDouble() ?? 0.0),
      salePrice: (json['sale_price'] is String
          ? double.tryParse(json['sale_price'] as String) ?? 0.0
          : (json['sale_price'] as num?)?.toDouble() ?? 0.0),
      stock: (json['stock'] is String
          ? int.tryParse(json['stock'] as String) ?? 0
          : (json['stock'] as num?)?.toInt() ?? 0),
      soldQuantity: (json['sold_quantity'] is String
          ? int.tryParse(json['sold_quantity'] as String) ?? 0
          : (json['sold_quantity'] as num?)?.toInt() ?? 0),
      attributeValues: parsedAttributes,
    );
  }
}