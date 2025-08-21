import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../shimmers/shimmer.dart';

class TCircularImage extends StatelessWidget {
  const TCircularImage({
    super.key,
    this.width = 56,
    this.height = 56,
    this.overlayColor,
    this.backgroundColor,
    required this.image,
    this.fit = BoxFit.contain,
    this.padding = TSizes.sm,
    this.isNetworkImage = true,
  });

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overlayColor;
  final Color? backgroundColor;
  final double width, height, padding;

  @override
  Widget build(BuildContext context) {
    print('TCircularImage: Attempting to load image: $image'); // Debug
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor ?? (THelperFunctions.isDarkMode(context) ? TColors.black : TColors.white),
        borderRadius: BorderRadius.circular(100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Center(
          child: isNetworkImage
              ? CachedNetworkImage(
            fit: fit,
            imageUrl: image,
            progressIndicatorBuilder: (context, url, downloadProgress) {
              print('TCircularImage: Loading progress for $image: ${downloadProgress.progress}'); // Debug
              return const TShimmerEffect(width: 56, height: 56);
            },
            errorWidget: (context, url, error) {
              print('TCircularImage: Image load error for $image: $error'); // Debug
              return Image.asset(
                'assets/images/fallback_category.png', // Fallback asset
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  print('TCircularImage: Fallback asset load error: $error');
                  return const Icon(Icons.error, color: TColors.error);
                },
              );
            },
          )
              : Image(
            fit: fit,
            image: AssetImage(image),
            color: overlayColor,
            errorBuilder: (context, error, stackTrace) {
              print('TCircularImage: Asset load error for $image: $error'); // Debug
              return const Icon(Icons.error, color: TColors.error);
            },
          ),
        ),
      ),
    );
  }
}