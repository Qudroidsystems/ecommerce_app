import 'package:cwt_ecommerce_app/features/shop/controllers/product/checkout_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/constants/sizes.dart';

class TBillingAmountSection extends StatelessWidget {
  const TBillingAmountSection({super.key, required this.subTotal});

  final double subTotal;

  @override
  Widget build(BuildContext context) {
    final controller = CheckoutController.instance;
    return Column(
      children: [
        /// -- Sub Total
        Row(
          children: [
            Expanded(child: Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium)),
            _buildPriceText(
              '₦${subTotal.toStringAsFixed(2)}',
              Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),

        /// -- Shipping Fee
        Row(
          children: [
            Expanded(child: Text('Shipping Fee', style: Theme.of(context).textTheme.bodyMedium)),
            Obx(
                  () => _buildPriceText(
                controller.isShippingFree(subTotal)
                    ? 'Free'
                    : '₦${(controller.getShippingCost(subTotal)).toStringAsFixed(2)}',
                Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems / 2),

        /// -- Tax Fee
        Row(
          children: [
            Expanded(child: Text('Tax Fee', style: Theme.of(context).textTheme.bodyMedium)),
            Obx(
                  () => _buildPriceText(
                '₦${controller.getTaxAmount(subTotal).toStringAsFixed(2)}',
                Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: TSizes.spaceBtwItems),

        /// -- Order Total
        Row(
          children: [
            Expanded(child: Text('Order Total', style: Theme.of(context).textTheme.titleMedium)),
            _buildPriceText(
              '₦${controller.getTotal(subTotal)}',
              Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }

  /// Helper method to build price text with proper Naira symbol font
  Widget _buildPriceText(String text, TextStyle? baseStyle) {
    return Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: baseStyle?.fontSize,
        fontWeight: baseStyle?.fontWeight,
        color: baseStyle?.color,
        height: baseStyle?.height,
        letterSpacing: baseStyle?.letterSpacing,
      ),
    );
  }
}