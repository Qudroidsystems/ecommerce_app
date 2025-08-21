import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../common/widgets/custom_shapes/containers/circular_container.dart';
import '../../../../../common/widgets/images/t_rounded_image.dart';
import '../../../../../common/widgets/shimmers/shimmer.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/product/banner_controller.dart';

class TPromoSlider extends StatelessWidget {
  const TPromoSlider({
    super.key,
    this.height = 200,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.enableInfiniteScroll = true,
  });

  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enableInfiniteScroll;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BannerController());

    return Obx(() {
      // Loading state
      if (controller.bannersLoading.value) {
        return TShimmerEffect(
          width: double.infinity,
          height: height,
        );
      }

      // Empty state
      if (controller.banners.isEmpty) {
        return SizedBox(
          height: height,
          child: const Center(
            child: Text(
              'No promotional banners available',
              style: TextStyle(color: TColors.grey),
            ),
          ),
        );
      }

      // Main carousel content
      return Column(
        children: [
          _buildCarousel(controller),
          if (controller.banners.length > 1) ...[
            const SizedBox(height: TSizes.spaceBtwItems),
            _buildIndicators(controller),
          ],
        ],
      );
    });
  }

  Widget _buildCarousel(BannerController controller) {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 1.0,
        height: height,
        autoPlay: autoPlay,
        autoPlayInterval: autoPlayInterval,
        enableInfiniteScroll: enableInfiniteScroll,
        enlargeCenterPage: false,
        onPageChanged: (index, reason) {
          controller.updatePageIndicator(index);
        },
      ),
      items: controller.banners.map((banner) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: TRoundedImage(
                imageUrl: banner.imageUrl,
                isNetworkImage: true,
                width: double.infinity,
                height: height,
                fit: BoxFit.cover,
                onPressed: () => _handleBannerTap(banner),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildIndicators(BannerController controller) {
    return Center(
      child: Obx(() => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          controller.banners.length,
              (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: controller.carousalCurrentIndex.value == index ? 24 : 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: controller.carousalCurrentIndex.value == index
                  ? TColors.primary
                  : TColors.grey.withOpacity(0.5),
            ),
          ),
        ),
      )),
    );
  }

  void _handleBannerTap(banner) {
    try {
      if (banner.targetScreen.isNotEmpty) {
        Get.toNamed(banner.targetScreen);
      }
    } catch (e) {
      // Handle navigation error gracefully
      debugPrint('Navigation error: $e');
    }
  }
}