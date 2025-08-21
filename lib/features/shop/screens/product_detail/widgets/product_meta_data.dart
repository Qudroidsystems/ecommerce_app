import 'package:flutter/material.dart';
import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../common/widgets/images/t_circular_image.dart';
import '../../../../../common/widgets/texts/t_brand_title_text_with_verified_icon.dart';
import '../../../../../common/widgets/texts/t_product_price_text.dart';
import '../../../../../common/widgets/texts/t_product_title_text.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controllers/product/product_controller.dart';
import '../../../models/product_model.dart';

class TProductMetaData extends StatelessWidget {
  const TProductMetaData({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final controller = ProductController.instance;
    final salePercentage = ProductController.instance.calculateSalePercentage(product.price, product.salePrice);
    final darkMode = THelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        /// Price & Sale Price
        Row(
          children: [
            /// -- Sale Tag
            if (salePercentage != null)
              Row(
                children: [
                  TRoundedContainer(
                    backgroundColor: TColors.secondary,
                    radius: TSizes.sm,
                    padding: const EdgeInsets.symmetric(horizontal: TSizes.sm, vertical: TSizes.xs),
                    child: Text('$salePercentage',
                        style: Theme.of(context).textTheme.labelLarge!.apply(color: TColors.black)),
                  ),
                  const SizedBox(width: TSizes.spaceBtwItems)
                ],
              ),

            // Actual Price if sale price not null.
            if ((product.productVariations == null || product.productVariations!.isEmpty) && product.salePrice > 0.0)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.price.toString(), style: Theme.of(context).textTheme.titleSmall!.apply(decoration: TextDecoration.lineThrough),),
                  const SizedBox(width: TSizes.spaceBtwItems)
                ],
              ),

            // Price, Show sale price as main price if sale exist.
            Flexible(
              child: TProductPriceText(price: controller.getProductPrice(product), isLarge: true),
            ),
          ],
        ),
        const SizedBox(height: TSizes.xs), // Further reduced spacing

        // Product Title with flexible text handling
        TProductTitleText(title: product.title),
        const SizedBox(height: TSizes.xs), // Further reduced spacing

        Row(
          children: [
            const TProductTitleText(title: 'Stock : ', smallSize: true),
            Flexible(
              child: Text(controller.getProductStockStatus(product),
                  style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
        const SizedBox(height: TSizes.xs), // Further reduced spacing

        /// Brand
        Row(
          children: [
            TCircularImage(
              width: 28, // Slightly smaller
              height: 28, // Slightly smaller
              isNetworkImage: true,
              image: product.brand!.image,
              overlayColor: darkMode ? TColors.white : TColors.black,
            ),
            const SizedBox(width: TSizes.spaceBtwItems / 2), // Add spacing between image and text
            Flexible(
              child: TBrandTitleWithVerifiedIcon(
                  title: product.brand!.name,
                  brandTextSize: TextSizes.medium
              ),
            ),
          ],
        ),
      ],
    );
  }
}