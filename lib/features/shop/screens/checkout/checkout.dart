import 'package:cwt_ecommerce_app/features/shop/controllers/product/checkout_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../common/widgets/products/cart/billing_amount_section.dart';
import '../../../../common/widgets/products/cart/coupon_code.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/controllers/address_controller.dart';
import '../../controllers/product/cart_controller.dart';
import '../../controllers/product/order_controller.dart';
import '../cart/widgets/cart_items.dart';
import 'widgets/billing_address_section.dart';
import 'widgets/billing_payment_section.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final checkoutController = CheckoutController.instance;
    final cartController = CartController.instance;
    final addressController = AddressController.instance;
    final subTotal = cartController.totalCartPrice.value;
    final orderController = Get.put(OrderController());
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: const TAppBar(title: Text('Order Review'), showBackArrow: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// -- Items in Cart
              const TCartItems(showAddRemoveButtons: false),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// -- Coupon TextField
              const TCouponCode(),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// -- Billing Section
              TRoundedContainer(
                showBorder: true,
                padding: const EdgeInsets.all(TSizes.md),
                backgroundColor: dark ? TColors.black : TColors.white,
                child: Column(
                  children: [
                    /// Pricing
                    TBillingAmountSection(subTotal: subTotal),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Divider
                    const Divider(),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Payment Methods
                    const TBillingPaymentSection(),
                    const SizedBox(height: TSizes.spaceBtwSections),

                    /// Address
                    const TAddressSection(isBillingAddress: false),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Divider
                    const Divider(),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Address Checkbox
                    Obx(
                          () => CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Billing Address is Same as Shipping Address'),
                        value: addressController.billingSameAsShipping.value,
                        onChanged: (value) => addressController.billingSameAsShipping.value = value ?? true,
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),

                    /// Divider
                    Obx(() => !addressController.billingSameAsShipping.value ? const Divider() : const SizedBox.shrink()),

                    /// Shipping Address
                    Obx(() => !addressController.billingSameAsShipping.value
                        ? const TAddressSection(isBillingAddress: true)
                        : const SizedBox.shrink()),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
            ],
          ),
        ),
      ),

      /// -- Checkout Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: subTotal > 0
                ? () => orderController.processOrder(subTotal)
                : () => TLoaders.warningSnackBar(title: 'Empty Cart', message: 'Add items in the cart in order to proceed.'),
            child: _buildCheckoutButtonText(context, checkoutController, subTotal),
          ),
        ),
      ),
    );
  }

  /// Helper method to build checkout button text with proper Naira symbol
  Widget _buildCheckoutButtonText(BuildContext context, CheckoutController controller, double subTotal) {
    final buttonTextStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: Colors.white, // Assuming white text on button
      fontWeight: FontWeight.w600,
    );

    return Text(
      'Checkout ₦${controller.getTotal(subTotal).toStringAsFixed(2)}',
      style: GoogleFonts.roboto(
        fontSize: buttonTextStyle?.fontSize,
        fontWeight: buttonTextStyle?.fontWeight,
        color: buttonTextStyle?.color,
        letterSpacing: buttonTextStyle?.letterSpacing,
      ),
    );
  }
}