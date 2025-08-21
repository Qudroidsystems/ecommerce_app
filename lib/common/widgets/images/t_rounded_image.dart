import 'package:flutter/material.dart';
import '../../../utils/constants/sizes.dart';
import '../shimmers/shimmer.dart';

class TRoundedImage extends StatelessWidget {
  const TRoundedImage({
    super.key,
    this.border,
    this.padding,
    this.onPressed,
    this.width,
    this.height,
    this.applyImageRadius = true,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.isNetworkImage = true,
    this.borderRadius = TSizes.md,
  });

  final double? width, height;
  final String imageUrl;
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color? backgroundColor;
  final BoxFit? fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onPressed;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    print('TRoundedImage: Loading image: $imageUrl'); // Debug
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          border: border,
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: applyImageRadius ? BorderRadius.circular(borderRadius) : BorderRadius.zero,
          child: isNetworkImage
              ? Image.network(
            imageUrl,
            fit: fit,
            width: width,
            height: height,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              print('TRoundedImage: Progress for $imageUrl: ${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}');
              return TShimmerEffect(
                width: width ?? double.infinity,
                height: height ?? 158,
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('TRoundedImage: Image load error for $imageUrl: $error');
              return SizedBox(
                width: width ?? double.infinity,
                height: height ?? 158,
                child: const Icon(Icons.error, color: Colors.red),
              );
            },
          )
              : Image(
            fit: fit,
            image: AssetImage(imageUrl),
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              print('TRoundedImage: Asset load error for $imageUrl: $error');
              return SizedBox(
                width: width ?? double.infinity,
                height: height ?? 158,
                child: const Icon(Icons.error, color: Colors.red),
              );
            },
          ),
        ),
      ),
    );
  }
}