class BannerModel {
  final String imageUrl;
  final String targetScreen;
  final bool active;

  /// Constructor
  const BannerModel({
    required this.imageUrl,
    required this.targetScreen,
    required this.active,
  });

  /// Convert model to JSON for API requests
  Map<String, dynamic> toJson() => {
    'image_url': imageUrl, // Using snake_case for Laravel compatibility
    'target_screen': targetScreen,
    'active': active,
  };

  /// Create a BannerModel from JSON received from the Laravel API
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      imageUrl: json['image_url'] ?? '',
      targetScreen: json['target_screen'] ?? '',
      active: json['active'] ?? false,
    );
  }

  /// Create an empty instance for clean code
  static const BannerModel empty = BannerModel(
    imageUrl: '',
    targetScreen: '',
    active: false,
  );

  /// CopyWith method for immutability
  BannerModel copyWith({
    String? imageUrl,
    String? targetScreen,
    bool? active,
  }) {
    return BannerModel(
      imageUrl: imageUrl ?? this.imageUrl,
      targetScreen: targetScreen ?? this.targetScreen,
      active: active ?? this.active,
    );
  }
}
