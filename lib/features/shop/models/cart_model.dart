import 'cart_item_model.dart';

class CartModel {
  final String cartId;
  final List<CartItemModel> items;

  CartModel({
    required this.cartId,
    required this.items,
  });

  /// **Calculate total price of cart**
  double get totalPrice =>
      items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  /// **Convert CartModel to JSON**
  Map<String, dynamic> toJson() {
    return {
      'cart_id': cartId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  /// **Create CartModel from JSON**
  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartId: json['cart_id'] ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CartItemModel.fromJson(item))
          .toList() ??
          [],
    );
  }

  /// **Empty Cart**
  static CartModel empty() => CartModel(cartId: '', items: []);
}
