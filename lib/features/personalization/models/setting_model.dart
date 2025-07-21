/// Model class representing application settings.
class SettingsModel {
  final String? id;
  final double taxRate;
  final double shippingCost;
  final double? freeShippingThreshold;
  final String appName;
  final String appLogo;

  /// Constructor for `SettingsModel`.
  SettingsModel({
    this.id,
    this.taxRate = 0.0,
    this.shippingCost = 0.0,
    this.freeShippingThreshold,
    this.appName = '',
    this.appLogo = '',
  });

  /// Convert model to JSON structure for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taxRate': taxRate,
      'shippingCost': shippingCost,
      'freeShippingThreshold': freeShippingThreshold,
      'appName': appName,
      'appLogo': appLogo,
    };
  }

  /// Factory method to create a `SettingsModel` from a JSON response.
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      id: json['id'] as String?,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      freeShippingThreshold: (json['freeShippingThreshold'] as num?)?.toDouble(),
      appName: json['appName'] ?? '',
      appLogo: json['appLogo'] ?? '',
    );
  }

  /// Create a copy of the current model with updated fields.
  SettingsModel copyWith({
    String? id,
    double? taxRate,
    double? shippingCost,
    double? freeShippingThreshold,
    String? appName,
    String? appLogo,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      taxRate: taxRate ?? this.taxRate,
      shippingCost: shippingCost ?? this.shippingCost,
      freeShippingThreshold: freeShippingThreshold ?? this.freeShippingThreshold,
      appName: appName ?? this.appName,
      appLogo: appLogo ?? this.appLogo,
    );
  }
}
