class ProductAttributeModel {
  final String name;
  final List<String> values;

  ProductAttributeModel({this.name = '', this.values = const []});

  /// Returns an empty instance for clean initialization
  static ProductAttributeModel empty() => ProductAttributeModel();

  /// Convert model to JSON for API requests
  Map<String, dynamic> toJson() => {
    'name': name,
    'values': values,
  };

  /// Create a ProductAttributeModel from JSON received from the Laravel API
  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeModel(
      name: json['name'] as String? ?? '',
      values: json['values'] != null ? List<String>.from(json['values']) : [],
    );
  }

  /// Returns a copy of the instance with updated values
  ProductAttributeModel copyWith({String? name, List<String>? values}) {
    return ProductAttributeModel(
      name: name ?? this.name,
      values: values ?? this.values,
    );
  }

  @override
  String toString() => 'ProductAttributeModel(name: $name, values: $values)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is ProductAttributeModel && other.name == name && other.values == values);

  @override
  int get hashCode => name.hashCode ^ values.hashCode;
}
