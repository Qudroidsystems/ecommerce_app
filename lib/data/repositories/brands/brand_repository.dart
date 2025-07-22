import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../features/shop/models/brand_category_model.dart';
import '../../../features/shop/models/brand_model.dart';
import '../../../utils/http/http_client.dart';

class BrandRepository extends GetxController {
  static BrandRepository get instance => Get.find();



  /// Get all brands
  Future<List<BrandModel>> getAllBrands() async {
    try {
      final response = await THttpHelper.get('/brands');
      return (response as List).map((e) => BrandModel.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get single brand by ID
  Future<BrandModel?> getSingleBrand(String id) async {
    try {
      final response = await THttpHelper.get('/brands/$id');
      return BrandModel.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get featured brands
  Future<List<BrandModel>> getFeaturedBrands() async {
    try {
      final response = await THttpHelper.get('/brands?isFeatured=true&limit=4');
      return (response as List).map((e) => BrandModel.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get brands for a specific category
  Future<List<BrandModel>> getBrandsForCategory(String categoryId) async {
    try {
      final response = await THttpHelper.get('/brands/category/$categoryId');
      return (response as List).map((e) => BrandModel.fromJson(e)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload dummy brands data
  Future<void> uploadDummyData(List<BrandModel> brands) async {
    try {
      for (var brand in brands) {
        await THttpHelper.post('/brands', brand.toJson());
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload dummy brand-category data
  Future<void> uploadBrandCategoryDummyData(List<BrandCategoryModel> brandCategory) async {
    try {
      for (var entry in brandCategory) {
        await THttpHelper.post('/brand-categories', entry.toJson());
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Error handling method
  String _handleError(dynamic e) {
    if (e is SocketException) {
      return 'No Internet connection. Please try again.';
    } else if (e is PlatformException) {
      return e.message ?? 'Platform error occurred.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}
