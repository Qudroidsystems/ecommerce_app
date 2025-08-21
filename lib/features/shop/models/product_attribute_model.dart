import 'dart:convert';

class ProductAttributeModel {
  final String name;
  final List<String> values;

  ProductAttributeModel({this.name = '', this.values = const []});

  static ProductAttributeModel empty() => ProductAttributeModel();

  Map<String, dynamic> toJson() => {
    'name': name,
    'values': values,
  };

  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    dynamic valuesData = json['values'];
    List<String> parsedValues = [];

    if (valuesData is String) {
      try {
        // Handle JSON-encoded string (e.g., "[\"Red\",\"Blue\"]")
        final decoded = jsonDecode(valuesData) as List<dynamic>;
        parsedValues = decoded.cast<String>();
      } catch (e) {
        // Handle comma-separated string (e.g., "Red,Blue")
        parsedValues = valuesData.split(',').map((s) => s.trim()).toList();
      }
    } else if (valuesData is List<dynamic>) {
      parsedValues = List<String>.from(valuesData);
    }

    return ProductAttributeModel(
      name: json['name'] as String? ?? '',
      values: parsedValues.isNotEmpty ? parsedValues : [],
    );
  }

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