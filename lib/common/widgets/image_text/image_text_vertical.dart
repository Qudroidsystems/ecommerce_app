import 'package:flutter/material.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../images/t_circular_image.dart';
import '../texts/t_brand_title_text.dart';

class TVerticalImageAndText extends StatelessWidget {
  const TVerticalImageAndText({
    super.key,
    this.onTap,
    required this.image,
    required this.title,
    this.backgroundColor,
    this.isNetworkImage = true,
    this.textColor = TColors.white,
  });

  final String image;
  final String title;
  final Color textColor;
  final bool isNetworkImage;
  final Color? backgroundColor;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    print('TVerticalImageAndText: Loading image: $image'); // Debug
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: TSizes.spaceBtwItems),
        child: Column(
          children: [
            TCircularImage(
              image: image,
              fit: BoxFit.contain,
              padding: TSizes.sm * 1.4,
              isNetworkImage: isNetworkImage,
              backgroundColor: backgroundColor,
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),
            SizedBox(width: 55, child: TBrandTitleText(title: title, color: textColor)),
          ],
        ),
      ),
    );
  }
}