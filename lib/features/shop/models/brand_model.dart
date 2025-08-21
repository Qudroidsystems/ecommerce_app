class BrandModel {
  String id;
  String name;
  String image;
  bool isFeatured;
  int productsCount;

  BrandModel({
    required this.id,
    required this.image,
    required this.name,
    this.isFeatured = false,
    this.productsCount = 0,
  });

  static BrandModel empty() => BrandModel(id: '', image: '', name: '');

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'image': image,
    'is_featured': isFeatured,
    'products_count': productsCount,
  };

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    print('Parsing Brand: ${json['name']}, isFeatured: ${json['is_featured']}');
    return BrandModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      image: json['logo'] as String? ?? '', // Use 'logo' to match API
      isFeatured: json['is_featured'] as bool? ?? false,
      productsCount: json['products_count'] != null
          ? (json['products_count'] is String
          ? int.tryParse(json['products_count'] as String) ?? 0
          : json['products_count'] as int)
          : 0,
    );
  }

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