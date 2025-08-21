import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../features/shop/controllers/product/product_controller.dart';
import '../../../../features/shop/models/product_model.dart';
import '../../../../features/shop/screens/product_detail/product_detail.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../styles/shadows.dart';
import '../../custom_shapes/containers/rounded_container.dart';
import '../../images/t_rounded_image.dart';
import '../../texts/t_brand_title_text_with_verified_icon.dart';
import '../../texts/t_product_title_text.dart';
import '../favourite_icon/favourite_icon.dart';
import 'widgets/add_to_cart_button.dart';
import 'widgets/product_card_pricing_widget.dart';
import 'widgets/product_sale_tag.dart';

class TProductCardVertical extends StatelessWidget {
  const TProductCardVertical({
    super.key,
    required this.product,
    this.isNetworkImage = true,
    this.width = 180,
    this.showAddToCart = true,
    this.showFavourite = true,
    this.onTap,
  });

  final ProductModel product;
  final bool isNetworkImage;
  final double width;
  final bool showAddToCart;
  final bool showFavourite;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final productController = ProductController.instance;
    final salePercentage = productController.calculateSalePercentage(product.price, product.salePrice);
    final dark = THelperFunctions.isDarkMode(context);

    return Semantics(
      label: 'Product card: ${product.title}',
      hint: 'Tap to view product details',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap ?? () => _navigateToProductDetail(),
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          splashColor: TColors.primary.withOpacity(0.1),
          highlightColor: TColors.primary.withOpacity(0.05),
          child: Container(
            width: width,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              boxShadow: [TShadowStyle.verticalProductShadow],
              borderRadius: BorderRadius.circular(TSizes.productImageRadius),
              color: dark ? TColors.darkerGrey : TColors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Take minimum space needed
              children: [
                _buildImageSection(context, dark, salePercentage),
                const SizedBox(height: TSizes.xs), // Reduced spacing
                _buildProductDetails(),
                const SizedBox(height: TSizes.xs), // Add small spacing before bottom section
                Padding(
                  padding: const EdgeInsets.only(left: TSizes.sm, bottom: TSizes.xs),
                  child: _buildBottomSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, bool dark, String? salePercentage) {
    return TRoundedContainer(
      height: 180,
      width: 180,
      padding: const EdgeInsets.all(TSizes.sm),
      backgroundColor: dark ? TColors.dark : TColors.light,
      child: Stack(
        children: [
          /// -- Thumbnail Image
          Center(
            child: Hero(
              tag: 'product-${product.id}',
              child: TRoundedImage(
                imageUrl: product.thumbnail,
                applyImageRadius: true,
                isNetworkImage: isNetworkImage,
              ),
            ),
          ),

          /// -- Sale Tag
          if (salePercentage != null && salePercentage.isNotEmpty)
            ProductSaleTagWidget(salePercentage: salePercentage),

          /// -- Favourite Icon Button
          if (showFavourite)
            Positioned(
              top: 0,
              right: 0,
              child: TFavouriteIcon(productId: product.id),
            ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Take minimum space needed
        children: [
          TProductTitleText(
            title: product.title,
            smallSize: true,
            maxLines: 1, // Limit to 1 line to save more space
          ),
          const SizedBox(height: TSizes.xs / 2), // Even smaller spacing

          if (product.brand != null)
            TBrandTitleWithVerifiedIcon(
              title: product.brand!.name,
              brandTextSize: TextSizes.small,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        /// Pricing - Use Expanded to take available space
        Expanded(
          child: PricingWidget(product: product),
        ),

        const SizedBox(width: TSizes.xs), // Add small spacing

        /// Add to cart
        if (showAddToCart)
          ProductCardAddToCartButton(product: product),
      ],
    );
  }

  void _navigateToProductDetail() {
    try {
      Get.to(
            () => ProductDetailScreen(product: product),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Fallback navigation
      Get.to(() => ProductDetailScreen(product: product));
    }
  }
}