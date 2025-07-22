import 'package:cwt_ecommerce_app/common/widgets/success_screen/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../data/repositories/order/order_repository.dart';
import '../../../../home_menu.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/controllers/address_controller.dart';
import '../../models/order_model.dart';
import 'cart_controller.dart';
import 'checkout_controller.dart';
import 'product_controller.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  /// Dependencies
  final _cartController = CartController.instance;
  final _addressController = AddressController.instance;
  final _checkoutController = CheckoutController.instance;
  final _orderRepository = OrderRepository.instance;

  /// Fetch user's order history
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      return await _orderRepository.fetchUserOrders();
    } catch (e) {
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Process an order
  void processOrder(double subTotal) async {
    try {
      // Start Loader
      TFullScreenLoader.openLoadingDialog('Processing your order', TImages.pencilAnimation);

      // Get user authentication ID
      final userId = AuthenticationRepository.instance.getUserID;
      if (userId.isEmpty) return;

      // Check for billing address requirement
      if (_addressController.billingSameAsShipping.isFalse &&
          _addressController.selectedBillingAddress.value.id.isEmpty) {
        TLoaders.warningSnackBar(
            title: 'Billing Address Required',
            message: 'Please add a Billing Address to proceed.');
        return;
      }

      // Create order model
      final order = OrderModel(
        id: UniqueKey().toString(), // Generate a unique ID
        userId: userId,
        status: OrderStatus.pending,
        totalAmount: _checkoutController.getTotal(subTotal),
        orderDate: DateTime.now(),
        shippingAddress: _addressController.selectedAddress.value,
        billingAddress: _addressController.selectedBillingAddress.value,
        paymentMethod: _checkoutController.selectedPaymentMethod.value.name,
        billingAddressSameAsShipping: _addressController.billingSameAsShipping.value,
        deliveryDate: DateTime.now().add(Duration(days: 7)), // Estimated delivery date
        items: _cartController.cartItems.toList(),
        shippingCost: _checkoutController.getShippingCost(subTotal),
        taxCost: _checkoutController.getTaxAmount(subTotal),
      );

      // Save order through repository
      await _orderRepository.saveOrder(order);

      // Update stock for each purchased item
      final productController = Get.put(ProductController());
      for (var product in _cartController.cartItems) {
        await productController.updateProductStock(
            product.productId, product.quantity, product.variationId);
      }

      // Clear the cart
      _cartController.clearCart();

      // Show success screen
      Get.off(() => SuccessScreen(
        image: TImages.orderCompletedAnimation,
        title: 'Payment Success!',
        subTitle: 'Your item will be shipped soon!',
        onPressed: () => Get.offAll(() => const HomeMenu()),
      ));
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
