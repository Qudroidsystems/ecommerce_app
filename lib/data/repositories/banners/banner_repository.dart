import 'dart:io';
import 'package:cwt_ecommerce_app/utils/constants/enums.dart';
import 'package:get/get.dart';
import 'package:cwt_ecommerce_app/utils/http/http_client.dart'; // Adjust path to your THttpHelper
import 'package:cwt_ecommerce_app/utils/exceptions/exceptions.dart'; // Adjust path to your TExceptions
import 'package:cwt_ecommerce_app/features/shop/models/banner_model.dart'; // Adjust path to your BannerModel

class BannerRepository extends GetxController {
  static BannerRepository get instance => Get.find();

  /* ---------------------------- FUNCTIONS ---------------------------------*/

  /// Fetch all active banners from the Laravel API (limited to 3)
  Future<List<BannerModel>> fetchBanners() async {
    try {
      final response = await THttpHelper.get('/banners?active=true&limit=3');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => BannerModel.fromJson(json)).toList();
    } catch (e) {
      throw TExceptions('Something went wrong while fetching banners: $e');
    }
  }

  /// Upload banners dummy data to the Laravel API
  Future<void> uploadBannersDummyData(List<BannerModel> banners) async {
    try {
      for (var banner in banners) {
        String updatedImageUrl = banner.imageUrl;

        if (File(banner.imageUrl).existsSync()) {
          final uploadResponse = await THttpHelper.uploadFile('/upload', File(banner.imageUrl), 'image');
          updatedImageUrl = uploadResponse['url'] ?? banner.imageUrl;
        }

        // Create a new instance with the updated imageUrl
        BannerModel updatedBanner = banner.copyWith(imageUrl: updatedImageUrl);

        // Store banner in the API
        await THttpHelper.post('api/banners', updatedBanner.toJson());
      }
    } catch (e) {
      throw TExceptions('Failed to upload banners: $e');
    }
  }

}