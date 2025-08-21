class CategoryModel {
  String id;
  String name;
  String image;
  String parentId;
  bool isFeatured;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.isFeatured,
    this.parentId = '',
  });

  static CategoryModel empty() => CategoryModel(id: '', image: '', name: '', isFeatured: false);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'parent_id': parentId,
      'is_featured': isFeatured ? '1' : '0', // Convert bool to string for API
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      parentId: json['parent_id']?.toString() ?? '',
      isFeatured: json['is_featured'] == '1' || // Handle string "1"
          json['is_featured'] == true || // Handle bool true
          (json['is_featured'] is int && json['is_featured'] == 1), // Handle int 1
    );
  }
}