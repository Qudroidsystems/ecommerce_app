import '../../../utils/constants/enums.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../personalization/models/address_model.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final OrderStatus status;
  final double totalAmount;
  final double shippingCost;
  final double taxCost;
  final DateTime orderDate;
  final String paymentMethod;
  final AddressModel? shippingAddress;
  final AddressModel? billingAddress;
  final DateTime? deliveryDate;
  final List<CartItemModel> items;
  final bool billingAddressSameAsShipping;

  const OrderModel({
    required this.id,
    this.userId = '',
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.shippingCost,
    required this.taxCost,
    required this.orderDate,
    this.paymentMethod = 'Cash on Delivery',
    this.billingAddress,
    this.shippingAddress,
    this.deliveryDate,
    this.billingAddressSameAsShipping = true,
  });

  /// Returns an empty order instance
  static  OrderModel empty = OrderModel(
    id: '',
    status: OrderStatus.pending,
    items: [],
    totalAmount: 0.0,
    shippingCost: 0.0,
    taxCost: 0.0,
    orderDate: DateTime.now(),
  );

  /// Formatted order date
  String get formattedOrderDate => THelperFunctions.getFormattedDate(orderDate);

  /// Formatted delivery date
  String get formattedDeliveryDate =>
      deliveryDate != null ? THelperFunctions.getFormattedDate(deliveryDate!) : '';

  /// Order status text
  String get orderStatusText {
    switch (status) {
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.shipped:
        return 'Shipment on the way';
      default:
        return 'Processing';
    }
  }

  /// Convert model to JSON for API requests
  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'status': status.name, // Use enum name directly
    'total_amount': totalAmount,
    'shipping_cost': shippingCost,
    'tax_cost': taxCost,
    'order_date': orderDate.toIso8601String(),
    'payment_method': paymentMethod,
    'shipping_address': shippingAddress?.toJson(),
    'billing_address': billingAddress?.toJson(),
    'delivery_date': deliveryDate?.toIso8601String(),
    'billing_address_same_as_shipping': billingAddressSameAsShipping,
    'items': items.map((item) => item.toJson()).toList(),
  };

  /// Create an OrderModel from JSON received from the Laravel API
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      status: _parseOrderStatus(json['status']),
      totalAmount: _parseDouble(json['total_amount']),
      shippingCost: _parseDouble(json['shipping_cost']),
      taxCost: _parseDouble(json['tax_cost']),
      orderDate: _parseDate(json['order_date']) ?? DateTime.now(),
      paymentMethod: json['payment_method'] ?? 'Cash on Delivery',
      shippingAddress: json['shipping_address'] != null
          ? AddressModel.fromJson(json['shipping_address'] as Map<String, dynamic>)
          : null,
      billingAddress: json['billing_address'] != null
          ? AddressModel.fromJson(json['billing_address'] as Map<String, dynamic>)
          : null,
      deliveryDate: _parseDate(json['delivery_date']),
      billingAddressSameAsShipping: json['billing_address_same_as_shipping'] ?? true,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  /// Copy method to create a new instance with modified values
  OrderModel copyWith({
    String? id,
    String? userId,
    OrderStatus? status,
    double? totalAmount,
    double? shippingCost,
    double? taxCost,
    DateTime? orderDate,
    String? paymentMethod,
    AddressModel? shippingAddress,
    AddressModel? billingAddress,
    DateTime? deliveryDate,
    List<CartItemModel>? items,
    bool? billingAddressSameAsShipping,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingCost: shippingCost ?? this.shippingCost,
      taxCost: taxCost ?? this.taxCost,
      orderDate: orderDate ?? this.orderDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      items: items ?? this.items,
      billingAddressSameAsShipping:
      billingAddressSameAsShipping ?? this.billingAddressSameAsShipping,
    );
  }

  /// Custom parsing for OrderStatus from JSON
  static OrderStatus _parseOrderStatus(dynamic value) {
    return OrderStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }

  /// Safe parsing for double values
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Safe parsing for DateTime values
  static DateTime? _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, userId: $userId, status: $status, totalAmount: $totalAmount, '
        'shippingCost: $shippingCost, taxCost: $taxCost, orderDate: $orderDate, '
        'paymentMethod: $paymentMethod, deliveryDate: $deliveryDate, items: ${items.length})';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is OrderModel &&
              other.id == id &&
              other.userId == userId &&
              other.status == status &&
              other.totalAmount == totalAmount &&
              other.shippingCost == shippingCost &&
              other.taxCost == taxCost &&
              other.orderDate == orderDate &&
              other.paymentMethod == paymentMethod &&
              other.billingAddressSameAsShipping == billingAddressSameAsShipping &&
              other.deliveryDate == deliveryDate &&
              _listEquals(other.items, items));

  @override
  int get hashCode => Object.hash(id, userId, status, totalAmount, shippingCost, taxCost, orderDate, paymentMethod, billingAddressSameAsShipping, deliveryDate, items);

  static bool _listEquals<T>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
}
