class BrandModel {
  String id;
  String name;
  String image;
  bool isFeatured;
  int productsCount;

  /// Constructor
  BrandModel({
    required this.id,
    required this.image,
    required this.name,
    this.isFeatured = false,
    this.productsCount = 0,
  });

  /// Empty Helper Function
  static BrandModel empty() => BrandModel(id: '', image: '', name: '');

  /// Convert model to JSON for API requests
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'is_featured': isFeatured,
    'products_count': productsCount,
  };

  /// Create a BrandModel from JSON received from the Laravel API
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      isFeatured: json['is_featured'] ?? false,
      productsCount: json['products_count'] != null
          ? (json['products_count'] is String
          ? int.tryParse(json['products_count']) ?? 0
          : json['products_count'] as int)
          : 0,
    );
  }

  /// CopyWith method for immutability
  BrandModel copyWith({
    String? id,
    String? name,
    String? image,
    bool? isFeatured,
    int? productsCount,
  }) {
    return BrandModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      isFeatured: isFeatured ?? this.isFeatured,
      productsCount: productsCount ?? this.productsCount,
    );
  }
}
